import json
from contextlib import redirect_stdout
import pandas as pd
import faker
import uuid
import numpy as np
import random

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.set_option('display.width', None)

faker.Faker.seed(0)
fake = faker.Faker()

pd.options.display.max_colwidth = 90

df_old = pd.read_csv("data/metalIdsAdded.csv", sep=",", encoding='utf8')

print(df_old.head())

dfSong = pd.DataFrame(columns=["id", "title", "artistId", "albumId", "year", "lyrics"])

dfGroupedArtist = (df_old
                   .groupby(['Artist']).size().reset_index(name='songCount')
                   .drop(columns=['songCount']))
dfGroupedArtist.rename(columns={'Artist': 'artistName'}, inplace=True)
dfGroupedArtist['id'] = dfGroupedArtist.apply(lambda _: uuid.uuid4().hex, axis=1)
dfGroupedArtist['formedIn'] = dfGroupedArtist.apply(lambda _: fake.country(), axis=1)
dfGroupedArtist['status'] = dfGroupedArtist.apply(lambda _: fake.random_element(elements=("Active",
                                                                                          "Inactive",
                                                                                          "On hold",
                                                                                          "Split-up",
                                                                                          "Changed name",
                                                                                          "Unknown")), axis=1)
dfGroupedArtist['country'] = dfGroupedArtist.apply(lambda _: fake.country(), axis=1)
dfGroupedArtist['biography'] = dfGroupedArtist.apply(lambda _: fake.text(max_nb_chars=80), axis=1)

print(dfGroupedArtist.head())
# Export csv
dfGroupedArtist.to_csv("data/split/artists.csv", index=False, encoding='utf8')

dfGroupedAlbum = (df_old.groupby(['Album']).size().reset_index(name='numberOfSongs'))
dfGroupedAlbum.rename(columns={'Album': 'albumName'}, inplace=True)
dfGroupedAlbum['id'] = dfGroupedAlbum.apply(lambda _: uuid.uuid4().hex, axis=1)
dfGroupedAlbum['releaseDate'] = dfGroupedAlbum.apply(lambda _: fake.year(), axis=1)
dfGroupedAlbum['type'] = dfGroupedAlbum.apply(lambda _: fake.random_element(elements=("Full-length",
                                                                                      "EP",
                                                                                      "Single",
                                                                                      "Compilation",
                                                                                      "Live",
                                                                                      "Demo",
                                                                                      "Other")), axis=1)
dfGroupedAlbum['genre'] = dfGroupedAlbum.apply(lambda _: fake.random_element(elements=("Black Metal",
                                                                                       "Death Metal",
                                                                                       "Doom Metal",
                                                                                       "Folk Metal",
                                                                                       "Gothic Metal",
                                                                                       "Grindcore",
                                                                                       "Heavy Metal",
                                                                                       "Metalcore",
                                                                                       "Power Metal",
                                                                                       "Progressive Metal",
                                                                                       "Speed Metal",
                                                                                       "Stoner Metal",
                                                                                       "Symphonic Metal",
                                                                                       "Thrash Metal")), axis=1)
print(dfGroupedAlbum.head())
# Export csv
dfGroupedAlbum.to_csv("data/split/albums.csv", index=False, encoding='utf8')

# Generate themes and make a dataframe
dfThemes = pd.DataFrame(columns=["id", "themeName"])
themes = ["Apocalypse",
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
          "Philosophy"]
for i in range(17):
    dfThemes = dfThemes._append({"id": uuid.uuid4().hex, "themeName": themes[i]}, ignore_index=True)

print(dfThemes.head())

dfThemes.to_csv("data/split/themes.csv", index=False, encoding='utf8')
# Make joint Dataframe
# Merge albums into dfSongEnriched
dfGroupedArtist.rename(columns={'id': 'artistId'}, inplace=True)
#dfGroupedArtist['jsonArtist'] = dfGroupedArtist.apply(lambda x: x.to_json(), axis=1)
#dfGroupedArtist.drop(columns=['artistId', 'formedIn', 'status', 'country', 'biography'], inplace=True)
dfSongEnriched = pd.merge(df_old, dfGroupedArtist, how='left', left_on='Artist', right_on='artistName')
dfSongEnriched.rename(columns={'_id': 'id'}, inplace=True)

dfGroupedAlbum.rename(columns={'id': 'albumId'}, inplace=True)
#dfGroupedAlbum['jsonAlbum'] = dfGroupedAlbum.apply(lambda x: x.to_json(), axis=1)
#dfGroupedAlbum.drop(columns=['albumId', 'releaseDate', 'type', 'genre'], inplace=True)
dfSongEnriched = pd.merge(dfSongEnriched, dfGroupedAlbum, how='left', left_on='Album', right_on='albumName')

# Drop redundant columns if necessary (e.g., 'name_artist' and 'name_album' if they exist)
#dfSongEnriched.drop(columns=['name_artist', 'name_album'], inplace=True, errors='ignore')

# Step 1: Generate random indices for each song
random_indices = np.random.randint(0, len(dfThemes), size=len(dfSongEnriched))

# Step 2: Map these indices to theme IDs from dfThemes
random_theme_ids = dfThemes.iloc[random_indices]['id'].values

# Step 3: Add these theme IDs as a new column to dfSongEnriched
dfSongEnriched['themeId'] = random_theme_ids

dfThemes.rename(columns={'id': 'themeId'}, inplace=True)
dfThemes['userRating'] = dfThemes.apply(lambda _: random.randint(1, 10), axis=1)
#dfThemes['jsonThemes'] = dfThemes.apply(lambda x: x.to_json(), axis=1)
#dfThemes.drop(columns=['userRating', 'themeName'], inplace=True)
# Step 4: Join with themes to get the theme names
dfSongEnriched = pd.merge(dfSongEnriched, dfThemes, how='left', left_on='themeId', right_on='themeId')
# dfSongEnriched.drop(columns=['Album', 'Artist', 'albumName', 'artistName', 'numberOfSongs', 'themeId'], inplace=True)
#dfSongEnriched.rename(columns={'jsonArtist': 'artist', 'jsonAlbum': 'album', 'jsonThemes': 'themes', 'Song': 'title', 'SongNum': 'songNum', 'Year': 'year', 'Lyric': 'lyrics', 'id':'_id'}, inplace=True)
dfSongEnriched.rename(
    columns={'Song': 'title', 'SongNum': 'songNum', 'Year': 'year', 'Lyric': 'lyrics', 'Album': 'album',
             'Artist': 'artist'}, inplace=True)
dfSongEnriched.drop(columns=['numberOfSongs'])

# Now dfSongEnriched has a random themeId from dfThemes for each song
print(dfSongEnriched.head(50))

dfSongEnriched.to_csv("data/split/songsMerged.csv", encoding='utf8', index=False)
# Drop everything, except for id, title, artistId, albumId, year, lyrics, themeId

# Iterate and make json
count = 0
length = dfSongEnriched.shape[0]
final = []
for index, row in dfSongEnriched.iterrows():
    print("\r" + str(count / length) + "% done", end='')
    artistName = row['artist']
    albumName = row['album']
    songTitle = row['title']
    songLyrics = row['lyrics']
    songNum = row['songNum']
    year = row['year']
    id = row['id']
    artistId = row['artistId']
    formedIn = row['formedIn']
    status = row['status']
    country = row['country']
    biography = row['biography']
    albumId = row['albumId']
    releaseDate = row['releaseDate']
    typeAlb = row['type']
    genre = row['genre']
    themeId = row['themeId']
    userRating = row['userRating']
    themeName = row['themeName']

    artist = {
        "id": artistId,
        "name": artistName,
        "formedIn": formedIn,
        "status": status,
        "country": country,
        "biography": biography
    }
    album = {
        "id": albumId,
        "name": albumName,
        "releaseDate": releaseDate,
        "type": typeAlb,
        "genre": genre
    }
    lyrics = {
        "lyricId": uuid.uuid4().hex,
        "lyricText": songLyrics,
        "annotations": [
            {
                "annotationId" : uuid.uuid4().hex,
                "characterStart": fake.random_int(min=1, max=10),
                "characterEnd": fake.random_int(min=11, max=20),
                "content": fake.text(max_nb_chars=80),
                "userRating": fake.random_int(min=1, max=5)
            },
            {
                "annotationId": uuid.uuid4().hex,
                "characterStart": fake.random_int(min=1, max=10),
                "characterEnd": fake.random_int(min=11, max=20),
                "content": fake.text(max_nb_chars=80),
                "userRating": fake.random_int(min=1, max=5)
            },
            {
                "annotationId": uuid.uuid4().hex,
                "characterStart": fake.random_int(min=1, max=10),
                "characterEnd": fake.random_int(min=11, max=20),
                "content": fake.text(max_nb_chars=80),
                "userRating": fake.random_int(min=1, max=5)
            }
        ]
    }
    finalSong = {
        "id": id,
        "title": songTitle,
        "artist": artist,
        "album": album,
        "year": year,
        "lyrics": lyrics,
        "themes": [
            {
                "id": themeId,
                "name": themeName,
                "userRating": userRating
            }
        ]

    }
    final.append(finalSong)
print("\n100% done")


with open('data/split/songsMerged.json', 'w', encoding="utf-8") as f:
    json.dump(final, f, ensure_ascii=False, indent=4)

dfSongEnriched.drop(columns=["artist","album","artistName","formedIn","status","country","biography","albumName","numberOfSongs","releaseDate","type","genre","themeName","userRating"], inplace=True)
dfSongEnriched.to_csv("data/split/songs.csv", encoding='utf8', index=False)