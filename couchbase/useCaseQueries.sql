-- FTS, return song title, number, album name, artist name and song year
SELECT SEARCH_SCORE(), title, a.songNumber, album.name as albName, artist.name as artName, year
FROM default a where SEARCH(a, {
    "query": {
        "query": "Death",
        "field": "*"
    }
});

-- Filtering by min(year), max(year), alphabetically(theme name)

-- Get Song details, return song title, song number, albumb name, artist name, song year, lyrics, theme list, annotation start, annotation end

SELECT META().id, title, songNumber, album.name as albName, artist.name as artName, year, lyrics.lyricText as lyrics, themes, lyrics.annotations as annotations
FROM default WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";

-- Get annotation details, return annotation content, annotation rating
SELECT META(d).id AS song_id, a.content, a.userRating
FROM `default` d
UNNEST d.lyrics.annotations AS a
WHERE META(d).id = "25ab75a2f5ff437baf0f2e7e79a7600c";

-- Get band details, return band name, country, status, formed in, biography and albums
-- does not work rn because of data inconsistency
SELECT artist.name, artist.country, artist.status, artist.formedIn, artist.biography
FROM default WHERE artist.name = "QUIET RIOT"
GROUP BY artist.name;

--Workaround, query any song from the band and get the band details
SELECT META().id, artist.name, artist.country, artist.status, artist.formedIn, artist.biography
FROM default WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";

-- Get all albums for a band, return album name, release date
SELECT DISTINCT album.name as albName, album.releaseDate from default WHERE artist.name = "QUIET RIOT";


-- get top 5 themes for a song
SELECT t.name, t.userRating, t.description from default d UNNEST d.themes as t
WHERE META(d).id = "25ab75a2f5ff437baf0f2e7e79a7600c"
ORDER BY t.userRating DESC LIMIT 10;

-- get top 5 annotations for a song
SELECT a.content, a.userRating from default d UNNEST d.lyrics.annotations as a
WHERE META(d).id = "25ab75a2f5ff437baf0f2e7e79a7600c"
ORDER BY a.userRating DESC LIMIT 10;

-- add a theme to a song, content: theme, description
UPDATE `default`
SET themes = ARRAY_APPEND(themes, {"name": "Rebellion", "description": "Rebellion is a theme"})
WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";
UPDATE `default`
SET themes = ARRAY t FOR t IN themes WHEN t.name != "Rebellion" END
WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";
-- add an annotation to a song, body: content, start, end, rating
UPDATE `default`
SET lyrics.annotations = ARRAY_APPEND(lyrics.annotations, {"characterEnd": 50, "characterStart": 45, "content": "Is Very good", "userRating": 1})
WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";

-- edit an annotation, body: content, start, end, rating
UPDATE `default`
SET lyrics.annotations[0].content = "This is also very cool, but I changed my interpretation"
WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";

SELECT lyrics.annotations from default WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";


-- add a song, body: artist, album, song, (lyrics), song number, year, (themes)
INSERT INTO `default` (KEY, VALUE)
VALUES (
    UUID(), -- Unique identifier for the new song
    {
        "title": "Sinners of the Seven Seas",
        "artist": {
            "name": "Powerwolf",
            "country": "Germany",
            "status": "Active",
            "formedIn": 2003,
            "biography": "POWERWOLF - a name that fills every disciple of traditional melodic heavy metal with joy and stands for a successful quintet that needs no more introduction after 15 years of steep ascent. The anniversary was celebrated with a best-of release in 2020, which united the highlights of all six studio albums released to date - including both long-running hits from early works, and more recent hits from the gold-awarded records Blessed & Possessed and The Sacrament Of Sin, such as the platinum hit single “Demons Are A Girl''s Best Friend”. Now, only about 12 months later, arguably the most successful pack of the contemporary German metal fauna is ready with bared fangs for the next bloody foray. The new album Call of the Wild is surprising and delighting at every stage of this wild 11-track ride, with stylistic advancements on an unprecedented scale! “Faster Than The Flame” - an opening blast that ignites the bonfire in purest POWERWOLF manner as a fiery distillation of such fulminant album openers as “Amen & Attack” or “Fire & Forgive” - bears the distinctive signature of the creative minds around main songwriter Matthew Greywolf even in the first chords, and impressively demonstrates that the five-piece has undoubtedly succeeded in creating its very own, unmistakable sound over the course of the last one and a half decades. Beyond all promotional platitudes – Call of the Wild is a hot contender for the top position among this years metal releases!"
        },
        "album": {
            "name": "Wake up the Wicked",
            "type": "Unreleased"
        },
        "lyrics": {
            "lyricText": "[Verse 1] \nSails in the wind and the word of God in mind \nHailed by the sin left our morals all behind \nBlessed by the crown and to shores ahead we ride \nTrails in the waves by the cross we are allied \nChrist in our hearts but for mercy we are blind \nRestless and damned we are knights of sacred might \nWe fight the Bible by our side \n \n[Chorus] \nSailors with no God no glory \nHeroes of our story \nSinners of the seven seas \nTraitors, may the flood await us \nBless the navigators \nSinners of the sea \n \n[Verse 2] \nWest with the tides and the Bible up the mast \nOnward we sail under heavens overcast \nPray to the lord that the guiding storm may last \nArmed with belief and the force of the sacrament \nWe brave the storm, put our faith in the promised land \nSoldiers of God and the conquest is our fate \nIrate we sail on our crusade \nSee Powerwolf Live \nGet tickets as low as $25 \nYou might also like \n1589 \nPowerwolf \nHoudini \nEminem \nСелфхарм (Selfharm) \nМонеточка (Monetochka) \n[Chorus] \nSailors with no God no glory \nHeroes of our story \nSinners of the seven seas \nTraitors, may the flood await us \nBless the navigators \nSinners of the sea \n \n[Non-Lyrical Vocals] \n \n[Guitar Solo] \n \n[Bridge] \nRaise your prayers to the sanctity \nFight conquistadors as one \nPraise the Father on the raging seas \nLord, the conquest has begun \nDominus navigare nos \nNe nos gloriemur \nDominus navigare nos \nNe nos gloriemur \n \n[Chorus] \nSailors, bringers of salvation \nHorror and damnation \nSinners of the seven seas \nTraitors, hounds and fornicators \nSainted desecrators \nSinners of the sea \nSinners, sinners of the sea",
            "annotations": [
                {
                    "characterStart": 10,
                    "characterEnd": 15,
                    "content": "Sails are often used in sea faring activities xD",
                    "userRating": 99
                }
            ]
        },
        "songNumber": 2,
        "year": 2024,
        "themes": [
            {
                "name": "Religion",
                "description": "In this case, the song is about god and how sailors are sinners in the worst way possible and its great",
                "userRating": 5
            }
        ]
    }
);
SELECT META().id, title, artist, album, songNumber, year, lyrics.lyricText FROM default where META().id = "f65e9653-728b-4d98-984a-0211bf566e40";

UPDATE default
unset song where artist.name = "Powerwolf";

UPDATE default
SET title = "Sinners of the Seven Seas" where artist.name = "Powerwolf";

-- edit song lyrics, body: song id, lyrics
UPDATE default
SET lyrics.lyricText = "This is a new lyric text" where META().id = "f65e9653-728b-4d98-984a-0211bf566e40";
SELECT lyrics.lyricText from default WHERE META().id = "f65e9653-728b-4d98-984a-0211bf566e40";

-- rate an annotation, body: annotation id, rating
UPDATE `default`
SET lyrics.annotations[0].userRating = 5
WHERE META().id = "f65e9653-728b-4d98-984a-0211bf566e40" and lyrics.annotations is not missing;

SELECT lyrics.annotations from default WHERE META().id = "f65e9653-728b-4d98-984a-0211bf566e40";

-- rate a song theme, body: theme name, rating
UPDATE `default`
SET themes[0].userRating = 5
WHERE META().id = "f65e9653-728b-4d98-984a-0211bf566e40" and themes is not missing;

-- get all songs from a band, return song title, song number, album name, song year
SELECT title, songNumber, album.name as albName, year from default WHERE artist.name = "QUIET RIOT";

CREATE INDEX idx_artist_name ON default(artist.name) USING GSI;
DROP INDEX default.idx_artist_name;

-- register user lol

-- Update all rows with random int, 164,288 rows took 16 s 16 ms
UPDATE `default`
SET songNumber = FLOOR(RANDOM()*10)+1;

DELETE FROM default where META().id = "f65e9653-728b-4d98-984a-0211bf566e40"


-- remove theme rebellion from all songs
UPDATE `default`
SET themes = ARRAY t FOR t IN themes WHEN t.name != "Rebellion" END
WHERE ANY t IN themes SATISFIES t.name = "Rebellion" END;

-- check distinct themes
SELECT DISTINCT t.name from default UNNEST themes as t;