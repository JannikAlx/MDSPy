import pandas as pd
import faker
import uuid
import json

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.set_option('display.width', None)

pd.options.display.max_colwidth = 90
# Load the old hierarchy data
# df_old = pd.read_parquet("data/metalIds.parquet")

df_old = pd.read_csv("data/metalIdsAdded.csv", sep=",", encoding='utf8')

print(df_old.head())

# Create a new DataFrame with the structure of the new hierarchy
df_new = pd.DataFrame(columns=['_id', 'title', 'artist', 'album', 'year', 'lyrics', 'themes'])

series_new = dict()

df_rowcount = df_old.shape[0]

# Create a Faker instance
fake = faker.Faker()


def generate_metal_theme():
    return fake.random_element(elements=("Apocalypse",
                                         "War",
                                         "Betrayal",
                                         "Nature's Fury",
                                         "Inner Demons",
                                         "Mythology",
                                         "Lost Love",
                                         "Rebellion",
                                         "Madness",
                                         "Ancient Civilizations",
                                         "Dystopia",
                                         "Mortality",
                                         "Revenge",
                                         "Fantasy Battles",
                                         "Isolation",
                                         "Whales",
                                         "Philosophy"))


count = 0
# Iterate over the old DataFrame
for index, row in df_old.iterrows():
    percentDone = (count / df_rowcount) * 100
    print("\r"+ str(percentDone) + "% done", end='')
    # Generate the missing fields
    artist_id = str(uuid.uuid4().hex)
    album_id = str(uuid.uuid4().hex)
    song_id = row['_id']
    artist_name = row['Artist']
    album_name = row['Album']
    song_title = row['Song']
    song_lyrics = row['Lyric']
    year = row['Year']
    artist = {
        "id": artist_id,
        "name": artist_name,
        "formedIn": fake.year(),
        "status": fake.random_element(elements=("ACTIVE", "SPLIT-UP", "ON HOLD", "UNKNOWN")),
        "country": fake.country(),
        "biography": fake.text()
    }
    album = {
        "id": album_id,
        "name": album_name,
        "releaseDate": year,
        "type": fake.random_element(elements=("STUDIO", "LIVE", "COMPILATION", "EP", "SINGLE")),
        "genre": fake.random_element(
            elements=("HEAVY METAL", "DEATH METAL", "BLACK METAL", "THRASH METAL", "POWER METAL")),
    }
    if count > 100000:
        lyrics = {
            "songId": song_id,
            "lyricText": song_lyrics,
            "annotations": [
                {
                    "characterStart": fake.random_int(min=1, max=10),
                    "characterEnd": fake.random_int(min=11, max=20),
                    "content": fake.text(),
                    "userRating": fake.random_int(min=1, max=5)
                },
                {
                    "characterStart": fake.random_int(min=1, max=10),
                    "characterEnd": fake.random_int(min=11, max=20),
                    "content": fake.text(),
                    "userRating": fake.random_int(min=1, max=5)
                },
                {
                    "characterStart": fake.random_int(min=1, max=10),
                    "characterEnd": fake.random_int(min=11, max=20),
                    "content": fake.text(),
                    "userRating": fake.random_int(min=1, max=5)
                }

            ]
        }
        themes = [
            {
                "name": generate_metal_theme(),
                "userRating": fake.random_int(min=1, max=5)
            },
            {
                "name": generate_metal_theme(),
                "userRating": fake.random_int(min=1, max=5)
            },
            {
                "name": generate_metal_theme(),
                "userRating": fake.random_int(min=1, max=5)
            }
        ]
    else:
        lyrics = {
            "songId": song_id,
            "lyricText": song_lyrics,
            "annotations": []
        }
        themes = []

    # '_id', 'title', 'artist', 'album', 'year',  'lyrics'
    song = {
        song_id: {
            "title": song_title,
            "artist": artist,
            "album": album,
            "year": year,
            "lyrics": lyrics,
            "themes": themes
        }
    }

    series_new.update(song)
    count += 1

print("\n")
print("Done!")

series = pd.Series(series_new)

series.to_json("data/final.json", orient="index")