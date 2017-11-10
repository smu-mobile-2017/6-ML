nohup mongod --dbpath ../../lab6_db > ../mongo.log &
pipenv run nohup python3 tornado_scikit_learn.py > ../server.log &
