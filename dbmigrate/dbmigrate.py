from pymongo import MongoClient
import pickle
import numpy as np

client = MongoClient(serverSelectionTimeoutMS=50)
db = client.sklearndatabase

X = []
y = []

for obj in db.labeledinstances.find({'dsid': 1}):
	X.append(pickle.loads(obj['feature']))
	y.append(obj['label'])
		
Xm = np.vstack(X)
ym = np.array(y)

print(Xm.shape)
print(ym.shape)

np.savetxt('X.csv', Xm.astype(int), fmt='%i')
np.savetxt('y.csv', ym.astype(int), fmt='%i')

