import pycouchdb as couchdb
import uuid
import pandas as pd

couch = couchdb.Server('http://MDS:supersecure@localhost:5984/')

db = couch.database("songs")

df = pd.read_csv("data/metal.csv", sep=",")
df = df.drop(columns=["DetectedLanguage", "Certainty"])

print(df.head())

df['uuid'] = df.apply(lambda _: uuid.uuid4().hex, axis=1)

print(df.head())

df['json'] = df.apply(lambda x: x.to_json(), axis=1)

test = df.at[0, 'json']
print(test)

db.save(test)

columns = df.loc[1:10, 'json']

for song in columns:
    print(song)
    try:
        db.save(song)
    except Exception as e:
        print("Error" + str(e))
