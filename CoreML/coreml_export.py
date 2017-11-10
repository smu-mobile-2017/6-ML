from sklearn.neighbors import KNeighborsClassifier
from pymongo import MongoClient
import pickle
import numpy as np
import coremltools

client = MongoClient(serverSelectionTimeoutMS=50)
db = self.client.sklearndatabase

X = []
y = []

for obj in db.labeledinstances.find({'dsid': 1}):
	X.append(pickle.loads(obj['feature']))
	y.append(obj['label'])

clf = KNeighborsClassifier(n_neighbors=1)
clf.fit(X,y)

coreml_model = coremltools.converters.sklearn.convert(clf)
coreml_model.save('DigitRecognizer.mlmodel')