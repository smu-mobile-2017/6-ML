Jake Rowland
Justin Wilson
Paul Herz

# Web Server

- Expects a folder named lab6_db outside of the project directory, containing a MongoDB persistence.
- You must have python 3 and `pipenv` installed globally (`pip3 install pipenv`) before you start.
- Run `pipenv install` while in the Server folder, then run `./run.sh` to start MongoDB and Tornado in the background. You will need to kill these manually later (`ps ax|grep tornado` or `mongod` and then `kill ####`).

# iOS App

The iOS app uses Cocoapods but compiles without any further steps if you open `Lab6_ios.xcworkspace` in the latest Xcode. It compiles to an iOS 11.0 target.

# DB Migration Tool

Run `pipenv install` then `pipenv run dbmigrate.py` while in this folder.

The DB migration tool runs in Python 3 to dump the data entries in MongoDB, pickled in the pickle protocol v3, into two CSVs: X (data) and y (labels). This is a necessary step because Python 2 (for CoreML) cannot interact with pickle v3.

# CoreML Tool

Run `pipenv install` then `pipenv run coreml_export.py` while in this folder.

This tool loads `X.csv` and `y.csv`, which it expects in the same folder, and trains a Linear SVC, trying to export it to a CoreML model. In our experience, this always crashed due to a cryptic error. We could not get CoreML to work.

The error was as follows:
```
Fatal Python error: PyThreadState_Get: no current thread
[1]    29249 abort      python2 coreml_export.py
```

