-- Song
-- Detail
SELECT Artist.name, album, Song.song, songNumber, year, lyrics, characterStart, characterEnd, theme
FROM Song
JOIN Artist ON song.artist = Artist.id
LEFT JOIN lyricsannotation ON LyricsAnnotation.song = Song.id
LEFT JOIN (
    SELECT * FROM SongThemes
    LEFT JOIN themes ON SongThemes.themeId = Themes.id
) t1 on t1.songId = song.id
WHERE Song.id = '3ad73d93-08f9-4c7e-898b-aebca674a549';

-- New Song
INSERT INTO Song(artist, album, song, lyrics, songNumber, year)
VALUES('<artist>', '<album>', '<song>', '<lyrics>', '<songNumber>', '<year>');

-- Update
UPDATE Song,
SET lyrics = '<new lyrics>'
WHERE id = '<id>';

-- Add Theme to Song
INSERT INTO SongThemes(songId, themeId, comment)
VALUES('<songId>', '<themeId>', '<comment>');
-- Increase Song Theme Rating
Update SongThemes
SET userRating = userRating + 1
WHERE songId = '<songId>' AND themeId = '<themeId>';
-- Decrease Song Theme Rating
Update SongThemes
SET userRating = userRating - 1
WHERE songId = '<songId>' AND themeId = '<themeId>';
-- Theme
-- Insert
INSERT INTO themes(theme, description)
VALUES('<theme>', '<description>');

-- Lyric Annotations
-- Select
SELECT Content, UserRating, Name
FROM LyricsAnnotation JOIN AppUser on AppUser.id = LyricsAnnotation.appUser
WHERE song = '3ad73d93-08f9-4c7e-898b-aebca674a549'
AND characterStart = '<characterStart>'
AND characterEnd = '<characterEnd>';
-- Insert
INSERT INTO LyricsAnnotation(appUser, song, characterStart, characterEnd, content)
VALUES('<userId>', '<songId>', '<characterStart>', '<characterEnd>', '<content>');
-- Update content
UPDATE LyricsAnnotation
SET content = '<content>'
WHERE id = '<id>';
-- Increase Rating
UPDATE LyricsAnnotation
SET userRating = userRating + 1
WHERE id = '<id>';
-- Decrease Rating
UPDATE LyricsAnnotation
SET userRating = userRating - 1
WHERE id = '<id>';

-- User
-- Create
INSERT INTO AppUser(name, email)
VALUES ('<name>', '<email>');

-- Filter
SELECT Country, Status, Max(formedIn), MIN(formedIN), theme
FROM Artist, Themes
GROUP BY Country, Status, Theme;


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
