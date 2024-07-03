
-- Some query for all bands that end with RIOT
SELECT META().id, title, album from default where artist.name like "%RIOT";

-- Full record
SELECT * FROM default WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";
SELECT META().* FROM default WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";

SELECT lyrics.lyricText FROM default WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";
SELECT lyrics.lyricText, META().id, artist.name FROM default WHERE SEARCH(lyrics.lyricText, {
    "query": {
        "match": "I am the joker",
        "field": "lyrics.lyricText"
    }
    });

-- Drops the index
DROP INDEX default.adaptive_default USING GSI;
-- Rebuilds it (takes time, like 45 seconds on my machine, and 2.7GB of disk space)
-- GSI is global secondary index (MDS slides somewhere)
CREATE INDEX adaptive_default ON default (DISTINCT (PAIRS(self))) USING GSI;

/*
 This query uses the ANY...SATISFIES...END construct to filter documents based on the userRating
 field in the themes array. The adaptive_default index allows Couchbase to efficiently filter
 and return these documents.
 */
 -- 1s 813 ms without index, 564 ms with index
SELECT META().id, title, artist, album, themes
FROM `default`
WHERE artist.name LIKE "%RIOT" AND album.type = "LIVE" AND ANY v IN themes SATISFIES v.userRating = 5 END;


--52 ms lol
UPDATE `default`
SET lyrics.annotations = ARRAY_APPEND(lyrics.annotations, {"characterEnd": 30, "characterStart": 20, "content": "No but its trash", "userRating": 20})
WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";

-- 12 ms lol
UPDATE `default`
SET lyrics.annotations[5].userRating = 1
WHERE META().id = "25ab75a2f5ff437baf0f2e7e79a7600c";

SELECT META().id, title, artist.name, album.name as aName, lyrics.lyricText
FROM `default`
WHERE SEARCH(lyrics.lyricText, {
    "query": {
        "query": "death",
        "field": "*"
    }
});

SELECT META().id, title, artist.name, album.name as aName, lyrics.lyricText, SEARCH_SCORE() AS score
FROM `default`
WHERE SEARCH(lyrics.lyricText, {
    "query": {
        "query": "death",
        "field": "*"
    }
})
ORDER BY score DESC;

SELECT lyrics.lyricText, artist.name from default where artist.country = "Germany";

SELECT title FROM default WHERE artist.country = "Germany";

CREATE INDEX idx_song_title ON default(title) USING GSI;
DROP INDEX default.idx_song_title USING GSI;

