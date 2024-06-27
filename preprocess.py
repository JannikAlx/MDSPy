import uuid
import pandas as pd
import pycouchdb as couchdb

couch = couchdb.Server('http://MDS:supersecure@localhost:5984/')

db = couch.database("songs")

df = pd.read_csv("data/metal.csv", sep=",")
df = df.drop(columns=["DetectedLanguage", "Certainty"])

print(df.head())

df['_id'] = df.apply(lambda _: uuid.uuid4().hex, axis=1)

print(df.head())

outId = df.to_parquet("data/metalIds.parquet", index=False)

df['json'] = df.apply(lambda x: x.to_json(), axis=1)

#out = df[['json']].to_parquet("data/metal.parquet", index=False)