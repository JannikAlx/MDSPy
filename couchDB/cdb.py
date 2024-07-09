import pycouchdb as couchdb
import json
import pandas as pd
import datetime

couch = couchdb.Server('http://MDS:supersecure@localhost:5984/')

db = couch.database("songs")
print("Loading data...")
df = pd.read_parquet("../data/4/metalGenerated.parquet")

print(df.head())
print("Converting to JSON...")
subset = df.loc[0:100000].apply(lambda x: x.to_json(), axis=1)
jsonDicts = []
count = 0
print("Loading Json...")
for song in subset:
    # print percentage done
    print("\r" + str(count / subset.shape[0] * 100) + "% done", end='')
    try:
        song = json.loads(song)
        jsonDicts.append(song)
    except Exception as e:
        print(e)
    count += 1
a = datetime.datetime.now()
try:
    db.save_bulk(jsonDicts)
except Exception as e:
    print(e)
b = datetime.datetime.now()
c = b - a
print("Took " + str(c.seconds) + " seconds and " + str(c.microseconds) +
      " microseconds to save " + str(subset.shape[0]) + " documents")
