from sklearn.svm import LinearSVC
import numpy as np
import coremltools

X = np.loadtxt(open("X.csv", "rb")).astype(int)
y = np.loadtxt(open("y.csv", "rb")).astype(int)

clf = LinearSVC()
clf.fit(X,y)

coreml_model = coremltools.converters.sklearn.convert(clf)
coreml_model.save('DigitRecognizer.mlmodel')