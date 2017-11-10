#!/usr/bin/python

from pymongo import MongoClient
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from basehandler import BaseHandler

from sklearn.neighbors import KNeighborsClassifier
#from sklearn import svm
from sklearn.linear_model import SGDClassifier
import pickle
import base64
import io
from bson.binary import Binary
import json
import pickle
import numpy as np
from PIL import Image

DSID = 1 #constant database id for samples, multiple sets could be used later

def base64ToImageArray(base64_image):
	binary_image = base64.b64decode(base64_image) #convert to binary
	image = Image.open(io.BytesIO(binary_image)) #load from binary
	#image.save("testImage", "PNG") #debug save image
	data = np.asarray(image.getdata()) #convert to numpy array
	#print(data) #debug print numoy array of image
	return data

class PrintHandlers(BaseHandler):
    def get(self):
        '''Write out to screen the handlers used
        This is a nice debugging example!
        '''
        self.set_header("Content-Type", "application/json")
        self.write(self.application.handlers_string.replace('),','),\n'))

class UploadLabeledDatapointHandler(BaseHandler):
    def post(self):
        '''Save data point and class label to database
        '''
        rx_data = json.loads(self.request.body.decode("utf-8")) #decode into JSON
        base64_image = rx_data['image'] #get image data in base64
        image_np = base64ToImageArray(base64_image) #convert to a np matrix from base64
        label = rx_data['label']

        image_np_bytes = pickle.dumps(image_np) #serialize to bytes

		#insert into mongoDb
        dbid = self.db.labeledinstances.insert(
            {
             "feature":Binary(image_np_bytes),
             "label":label,
             "dsid":DSID
            }
        )

        #Send back message to client
        self.write_json({"id":str(dbid), 
         	"feature":[str(image_np.size) + " Grey scale pixels received", 
         		"min of: " + str(image_np.min()), 
         		"max of: " + str(image_np.max())], 
             "label":label})

''' Keep this incase we need to use this on the projet 
'''
# class RequestNewDatasetId(BaseHandler):
#     def get(self):
#         '''Get a new dataset ID for building a new dataset
#         '''
#         a = self.db.labeledinstances.find_one(sort=[("dsid", -1)])
#         if a == None:
#             newSessionId = 1
#         else:
#             newSessionId = float(a['dsid'])+1
#         self.write_json({"dsid":newSessionId})

def newModel(self, dsid, parameter):
    # create feature vectors from database
    f=[]
    for a in self.db.labeledinstances.find({"dsid":dsid}):
        f.append(pickle.loads(a['feature'])) #retrieve the pickled image from the dict., JSON, and convert back

    # create label vector from database
    l=[]
    for a in self.db.labeledinstances.find({"dsid":dsid}):
        l.append(a['label']) #retrieve labels

    #fit the model to the data 
    #print(self.clf_type) #debug message
    if self.clf_type == 'KNN':
        if parameter == None: 
            parameter = 5
        c1 = KNeighborsClassifier(n_neighbors = parameter)
        print("parameter: " + str(parameter))
    else:
        if parameter == None: 
            parameter = .0001
        c1 = SGDClassifier(loss='log', alpha = parameter)
        print("parameter: " + str(parameter))
    acc = -1
    if l:
        c1.fit(f,l) # training
        lstar = c1.predict(f) #predicting using training data
        self.clf[self.clf_type] = c1 #set current classifier for clf_type

        acc = sum(lstar==l)/float(len(l))
        bytes = pickle.dumps(c1)

        self.db.models.update(
            {"type": self.clf_type},
            {"$set":
                {
                    "model": Binary(bytes)
                }
            },
            upsert=True
        )
    return acc

class UpdateModelForDatasetId(BaseHandler):
    def get(self):
        '''Train a new model (or update) for given dataset ID
        '''

        self.clf_type = self.get_string_arg("classifier")
        if(self.clf_type == 'KNN'):
            param = self.get_int_arg('parameter', 5)
        else:
            param = self.get_float_arg('parameter', .0001)

        acc = newModel(self, DSID, param)

        # send back the resubstitution accuracy
        # if training takes a while, we are blocking tornado!! No!!
        self.write_json({"resubAccuracy":acc})
        print("Model Updated, type " + self.clf_type)

class PredictOneFromDatasetId(BaseHandler):
    def post(self):
        '''Predict the class of a sent feature vector
        '''
        rx_data = json.loads(self.request.body.decode("utf-8")) #decode into JSON
        base64_image = rx_data['image'] #get image data in base64
        sample_image_np = base64ToImageArray(base64_image) #convert to a np matrix from base64

        self.clf_type = rx_data['classifier'] #string flag for the model the user wants to use
        sample_image_np = np.array(sample_image_np).reshape(1, -1) #reshape the array

        #Set default value
        param = None

        #Get passed values if they exist
        if 'parameter' in rx_data:
            param = rx_data['parameter'] #get parameter data

        # if model does not exist load the model from the database or build new model
        # Only use parameter when creating a new model, otherwise use existing model
        # we are blocking tornado!! no!!
        if self.clf_type not in self.clf:
            modelPersistence = self.db.models.find_one({"type":self.clf_type})
            if modelPersistence:
                print('Loading model from DB ' + self.clf_type)
                self.clf[self.clf_type] = pickle.loads(modelPersistence['model'])
            else:
                print('Building new model, type ' + self.clf_type)
                newModel(self, DSID, param) #if model does not exist creat new model with parameter passed.

        predictionArray = self.clf[self.clf_type].predict(sample_image_np)
        predLabel = int(predictionArray[0])
        print(str(predLabel) + ", model " + self.clf_type)
        self.write_json({"prediction":predLabel})
