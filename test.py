import couchdb
import uuid
import pandas as pd

couch = couchdb.Server('http://MDS:supersecure@localhost:5984/')

db = couch["songs"]

doc = {
    "_id": "3ef7b250-8893-4380-871d-8615892822b6",
    "name": "John Doe",
    "age": 25,
    "email": "john@doe.com"
}


doc = db[doc["_id"]]

db.delete(doc)

pd.read_csv("")