# Compatibility
# absolute_import required for keras: uses `from . import np_utils`
from __future__ import print_function

try:
	input = raw_input
except NameError:
	pass

# ML Tools
from sklearn.linear_model import LogisticRegression
import numpy as np
import coremltools

# Loading homegrown data (mongodb dumps from db migration script)
#X = np.loadtxt(open("X.csv", "rb")).astype(int)
#y = np.loadtxt(open("y.csv", "rb")).astype(int)

# Loading MNIST
flat = lambda x: x.reshape((x.shape[0], x.shape[1] * x.shape[2]))

print('Importing MNIST...')
import mnist
x_train = flat(mnist.train_images())
y_train = mnist.train_labels()

x_test = flat(mnist.test_images())
y_test = mnist.test_labels()

print(x_train[6])

# # Training
# print('Training the model...')
# # [CITE] http://scikit-learn.org/stable/auto_examples/linear_model/plot_sparse_logistic_regression_mnist.html
# clf = LogisticRegression(
# 	verbose=1,
# 	C=50. / len(x_train),
# 	multi_class='ovr', # coreml does not support multinomial
# 	penalty='l1', solver='saga', tol=0.1
# )
# clf.fit(x_train, y_train)

# # Testing
# from sklearn.metrics import accuracy_score
# acc = accuracy_score(y_test, clf.predict(x_test))
# print(acc,'accuracy.')

# # Exporting
# coreml_model = coremltools.converters.sklearn.convert(clf)
# coreml_model.save('DigitRecognizer.mlmodel')
