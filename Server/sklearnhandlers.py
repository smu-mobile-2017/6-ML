#!/usr/bin/python

from pymongo import MongoClient
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from basehandler import BaseHandler

from sklearn.neighbors import KNeighborsClassifier
import pickle
import base64
import io
from bson.binary import Binary
import json
import pickle
import numpy as np
from PIL import Image

DSID = 1

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

def newModel(self, dsid):
    # create feature vectors from database
    f=[]
    for a in self.db.labeledinstances.find({"dsid":dsid}):
        f.append(pickle.loads(a['feature'])) #retrieve the pickled image from the dict., JSON, and convert back

    # create label vector from database
    l=[]
    for a in self.db.labeledinstances.find({"dsid":dsid}):
        l.append(a['label']) #retrieve labels

    # fit the model to the data
    c1 = KNeighborsClassifier(n_neighbors=3)
    acc = -1
    if l:
        c1.fit(f,l) # training
        lstar = c1.predict(f) #predicting using training data
        self.clf[dsid] = c1 #set current classifier

        acc = sum(lstar==l)/float(len(l))
        bytes = pickle.dumps(c1)

        self.db.models.update(
            {"dsid": dsid},
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
        #dsid = self.get_int_arg("dsid",default=0)

        acc = newModel(self, DSID)

        # send back the resubstitution accuracy
        # if training takes a while, we are blocking tornado!! No!!
        self.write_json({"resubAccuracy":acc})
        print("Model Updated")

class PredictOneFromDatasetId(BaseHandler):
    def post(self):
        '''Predict the class of a sent feature vector
        '''
        rx_data = json.loads(self.request.body.decode("utf-8")) #decode into JSON
        base64_image = rx_data['image'] #get image data in base64
        model_selection = rx_data['classifier']
        sample_image_np = base64ToImageArray(base64_image) #convert to a np matrix from base64

        #vals = data['feature'];
        #fvals = [float(val) for val in vals];
        sample_image_np = np.array(sample_image_np).reshape(1, -1)

        # load the model from the database (using pickle)
        # we are blocking tornado!! no!!

        if DSID not in self.clf:
            print('Loading Model From DB')
            modelPersistence = self.db.models.find_one({"dsid":DSID})
            if modelPersistence:
                self.clf[DSID] = pickle.loads(modelPersistence['model'])
            else:
                newModel(self, DSID)

        predictionArray = self.clf[DSID].predict(sample_image_np)
        predLabel = int(predictionArray[0])
        print(predLabel)
        self.write_json({"prediction":predLabel})
