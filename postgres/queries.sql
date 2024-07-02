-- Full Text Search
SELECT name, album, song, lyrics FROM song AS s
                                          JOIN artist AS a on s.artist = a.id
WHERE to_tsvector('english', coalesce(song, '') || '' || coalesce(album, '') || '' || coalesce(lyrics, '')) @@ to_tsquery('english', 'death');

SELECT artistName, album, songName, lyrics, ts_rank_cd(
        setweight(to_tsvector('english', coalesce(songName,'')), 'A') ||
        setweight(to_tsvector('english', coalesce(artistName, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(album,'')), 'C') ||
        setweight(to_tsvector('english', coalesce(lyrics,'')), 'D'),
        websearch_to_tsquery('"Morbid Angel"')) as rank
FROM fts
WHERE
    setweight(to_tsvector('english', coalesce(songName,'')), 'A') ||
    setweight(to_tsvector('english', coalesce(artistName, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(album,'')), 'C') ||
    setweight(to_tsvector('english', coalesce(lyrics,'')), 'D')
              @@ websearch_to_tsquery('"Morbid Angel"')
ORDER BY rank DESC;

-- Full Filter
SELECT name, album, song, lyrics FROM song AS s
                                          JOIN artist AS a on s.artist = a.id
WHERE to_tsvector('english', coalesce(song, '') || '' || coalesce(album, '') || '' || coalesce(lyrics, '')) @@ to_tsquery('english', 'death');

SELECT DISTINCT artistName, album, songName, lyrics, ts_rank_cd(
        setweight(to_tsvector('english', coalesce(songName,'')), 'A') ||
        setweight(to_tsvector('english', coalesce(artistName, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(album,'')), 'C') ||
        setweight(to_tsvector('english', coalesce(lyrics,'')), 'D'),
        websearch_to_tsquery('"Morbid Angel"')) as rank
FROM fts
         LEFT JOIN songThemes ON songThemes.songId = fts.songId
         LEFT JOIN artist ON artist.id = fts.artistid
         LEFT JOIN (
    SELECT id, year FROM SONG
) as t1 ON t1.id = fts.songId
WHERE
    setweight(to_tsvector('english', coalesce(songName,'')), 'A') ||
    setweight(to_tsvector('english', coalesce(artistName, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(album,'')), 'C') ||
    setweight(to_tsvector('english', coalesce(lyrics,'')), 'D')
              @@ websearch_to_tsquery('"Morbid Angel"')
AND year = 1995
AND formedIn = 1989
AND songThemes.themeId IN ('b1772822-8f5a-4caf-a6a6-e4bd1a75b072')
AND artist.country IN ('country')
ORDER BY rank DESC;

-- Song Details
SELECT Artist.name, album, Song.song, songNumber, year, lyrics
FROM Song
JOIN Artist ON song.artist = Artist.id
WHERE Song.id = '3ad73d93-08f9-4c7e-898b-aebca674a549';

SELECT theme
FROM SongThemes
JOIN Theme ON songThemes.themeId = Theme.id
WHERE songThemes.songId = '<id>';

SELECT characterStart, characterEnd
FROM lyricsAnnotation
WHERE songID = '<id>';;

-- Annotation Details
SELECT Content, UserRating, Name
FROM LyricsAnnotation JOIN AppUser on AppUser.id = LyricsAnnotation.appUser
WHERE song = '3ad73d93-08f9-4c7e-898b-aebca674a549'
AND characterStart = '<characterStart>'
AND characterEnd = '<characterEnd>';

-- Band Details
SELECT Name, formedId, status, biography
FROM Artist
WHERE id = '<id>';

SELECT DISTINCT album, year, MAX(SongNumber) as songs
FROM Song
WHERE artist = 'ab7ae839-b630-4b49-99d9-a1b3047bf5bd'
GROUP BY album, year;

-- Adding Themes
INSERT INTO themes(theme, description)
VALUES('<theme>', '<description>');
-- (to Song)
INSERT INTO SongThemes(songId, themeId)
VALUES('15083cc6-edf0-42c3-985c-b3066db35982', 'b1772822-8f5a-4caf-a6a6-e4bd1a75b072');

-- Adding Annotations
INSERT INTO LyricsAnnotation(appUser, song, characterStart, characterEnd, content)
VALUES('<userId>', '<songId>', '<characterStart>', '<characterEnd>', '<content>');

-- Edit Annotations
UPDATE LyricsAnnotation
SET content = '<content>'
WHERE id = '<id>';

-- Adding Songs
-- Without lyrics
INSERT INTO Song(artist, album, song, songNumber, year)
VALUES('<artist>', '<album>', '<song>', '<songNumber>', '<year>');

-- With lyrics
INSERT INTO Song(artist, album, song, lyrics, songNumber, year)
VALUES('<artist>', '<album>', '<song>', '<lyrics>', '<songNumber>', '<year>');

-- Edit Songs lyrics
UPDATE Song, year
SET lyrics = '<new lyrics>'
WHERE id = '<id>';

-- Rate Annotation
-- Increase Rating
UPDATE LyricsAnnotation
SET userRating = userRating + 1
WHERE id = '<id>';
-- Decrease Rating
UPDATE LyricsAnnotation
SET userRating = userRating - 1
WHERE id = '<id>';

-- Rate Song Theme
-- Increase Rating
Update SongThemes
SET userRating = userRating + 1
WHERE songId = '<songId>' AND themeId = '<themeId>';
-- Decrease Song Theme Rating
Update SongThemes
SET userRating = userRating - 1
WHERE songId = '<songId>' AND themeId = '<themeId>';

-- Filter
SELECT Country, Status, Max(formedIn), MIN(formedIN), Max(year), Min(year)
FROM Artist, Song
GROUP BY Country, Status;

SELECT DISTINCT theme
FROM themes;

-- Register Users
INSERT INTO AppUser(name, email)
VALUES ('<name>', '<email>');
