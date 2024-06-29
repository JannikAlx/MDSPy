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

-- Add Theme to Song
INSERT INTO SongThemes(songId, themeId, comment)
VALUES('<songId>', '<themeId>', '<comment>');


-- Update
UPDATE Song,
SET lyrics = '<new lyrics>'
WHERE id = '<id>';

-- Theme
-- Insert
INSERT INTO themes(theme, description)
VALUES('<theme>', '<description>');

-- Lyric Annotations
-- Insert
INSERT INTO LyricsAnnotation(appUser, song, characterStart, characterEnd, content)
VALUES('<userId>', '<songId>', '<characterStart>', '<characterEnd>', '<content>');
-- Update

-- Select
SELECT Content, UserRating, Name
FROM LyricsAnnotation JOIN AppUser on AppUser.id = '83d8d103-45fd-49fa-9af0-e95efae8b5a1'
WHERE song = '3ad73d93-08f9-4c7e-898b-aebca674a549'
    AND characterStart = '<characterStart>'
    AND characterEnd = '<characterEnd>';

-- User
-- Create
INSERT INTO AppUser(name, email)
VALUES ('<name>', '<email>');

-- Filter
SELECT Country, Status, Max(formedIn), MIN(formedIN), theme
FROM Artist, Themes
GROUP BY Country, Status, Theme;


-- Full Text Search

SELECT name, song, lyrics FROM song AS s
JOIN artist AS a on s.artist = a.id
WHERE to_tsvector('english', lyrics) @@ to_tsquery('english', 'blood & gore');
