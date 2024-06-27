import pycouchdb as couchdb
import json
import pandas as pd

couch = couchdb.Server('http://MDS:supersecure@localhost:5984/')

db = couch.database("songs")

df = pd.read_parquet("data/metal.parquet")

print(df.head())

subset = df.loc[20001:100000, 'json']
jsonDicts = []
for song in subset:
    try:
        song = json.loads(song)
        jsonDicts.append(song)
    except Exception as e:
        print(e)

db.save_bulk(jsonDicts)

# for song in df.loc[1:10000, 'json']:
#     try:
#         song = json.loads(song)
#         db.save(song)
#         print(song)
#     except Exception as e:
#         print(e)
#