import uuid
import pandas as pd

df = pd.read_csv("data/metal.csv", sep=",", encoding='utf8')
df = df.drop(columns=["DetectedLanguage", "Certainty"])

print(df.head())

df['_id'] = df.apply(lambda _: uuid.uuid4().hex, axis=1)

print(df.head())

out = df.to_csv("data/metalIdsAdded.csv", index=False, encoding='utf8')
