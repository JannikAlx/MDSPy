-- Filter
SELECT *
FROM bench('SELECT Max(formedIn) as maxFormedIn, MIN(formedIN) as minFromedIn
FROM Artist;

SELECT Max(year) as maxSongYear, Min(year) as minSongYear
FROM song;

SELECT DISTINCT Country from artist;

SELECT DISTINCT status from artist;

SELECT DISTINCT theme
FROM themes;');

-- Full Text Search
SELECT * FROM bench('SELECT artistName, album, songName, t1.year, t1.songnumber, ts_rank_cd(
        setweight(to_tsvector(''english'', coalesce(songName,'''')), ''A'') ||
        setweight(to_tsvector(''english'', coalesce(artistName, '''')), ''B'') ||
        setweight(to_tsvector(''english'', coalesce(album,'''')), ''C'') ||
        setweight(to_tsvector(''english'', coalesce(lyrics,'''')), ''D''),
        websearch_to_tsquery(''Death'')) as rank
FROM fts
LEFT JOIN (
    SELECT id, year, songnumber FROM SONG
) as t1 ON t1.id = fts.songId
WHERE
    setweight(to_tsvector(''english'', coalesce(songName,'''')), ''A'') ||
    setweight(to_tsvector(''english'', coalesce(artistName, '''')), ''B'') ||
    setweight(to_tsvector(''english'', coalesce(album,'''')), ''C'') ||
    setweight(to_tsvector(''english'', coalesce(lyrics,'''')), ''D'')
              @@ websearch_to_tsquery(''Death'')
ORDER BY rank DESC;');

-- Full Filter
SELECT * FROM BENCH ('SELECT DISTINCT artistName, album, songName, t1.year, t1.songnumber, ts_rank_cd(
        setweight(to_tsvector(''english'', coalesce(songName,'''')), ''A'') ||
        setweight(to_tsvector(''english'', coalesce(artistName, '''')), ''B'') ||
        setweight(to_tsvector(''english'', coalesce(album,'''')), ''C'') ||
        setweight(to_tsvector(''english'', coalesce(lyrics,'''')), ''D''),
        websearch_to_tsquery(''Death'')) as rank
FROM fts
         LEFT JOIN songThemes ON songThemes.songId = fts.songId
         LEFT JOIN artist ON artist.id = fts.artistid
         LEFT JOIN (
    SELECT id, year, songnumber FROM SONG
) as t1 ON t1.id = fts.songId
WHERE
    setweight(to_tsvector(''english'', coalesce(songName,'''')), ''A'') ||
    setweight(to_tsvector(''english'', coalesce(artistName, '''')), ''B'') ||
    setweight(to_tsvector(''english'', coalesce(album,'''')), ''C'') ||
    setweight(to_tsvector(''english'', coalesce(lyrics,'''')), ''D'')
              @@ websearch_to_tsquery(''Death'')
AND year = 1987
AND formedIn = 1987
AND songThemes.themeId IN (''9a263075-31a1-4a39-8aae-739fbb203f29'')
AND artist.country IN (''Greenland'')
ORDER BY rank DESC;') ;

-- Song Details
SELECT * FROM bench('SELECT Artist.name, album, Song.song, songNumber, year, lyrics
FROM Song
JOIN Artist ON song.artist = Artist.id
WHERE Song.id = ''f6f3975f-b47a-43f7-8bd3-459be4851808'';

SELECT theme
FROM SongThemes
JOIN Themes ON songThemes.themeId = Themes.id
WHERE songThemes.songId = ''f6f3975f-b47a-43f7-8bd3-459be4851808'';

SELECT characterStart, characterEnd
FROM lyricsAnnotation
WHERE song = ''f6f3975f-b47a-43f7-8bd3-459be4851808'';');

-- Annotation Details
SELECT * FROM bench('SELECT Content, UserRating, Name
FROM LyricsAnnotation JOIN AppUser on AppUser.id = LyricsAnnotation.appUser
WHERE song = ''f6f3975f-b47a-43f7-8bd3-459be4851808''
AND characterStart = ''1''
AND characterEnd = ''5'';');

-- Band Details
SELECT * FROM bench('SELECT Name, formedIn, status, biography
FROM Artist
WHERE id = ''10873cce-8b9f-4dc5-9f95-b4088ad44bc1'';

SELECT DISTINCT album, year, MAX(SongNumber) as songs
FROM Song
WHERE artist = ''10873cce-8b9f-4dc5-9f95-b4088ad44bc1''
GROUP BY album, year
ORDER BY year ASC;');

-- Adding Themes
SELECT *
FROM bench('INSERT INTO themes(theme, description)
VALUES(''Violence'', ''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque nec massa laoreet, tincidunt eros et, pulvinar quam. Maecenas a volutpat.'');');

-- Adding Annotations
SELECT *
FROM bench('INSERT INTO LyricsAnnotation(appUser, song, characterStart, characterEnd, content)
VALUES(''5cc1b26f-27e0-496f-8ad9-ecef34fcd18c'', ''ff78c897-20a0-4832-83cb-1aebb79344da'', ''1'', ''10'', ''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque nec massa laoreet, tincidunt eros et, pulvinar quam. Maecenas a volutpat.'');');

-- Edit Annotations
SELECT *
FROM bench('UPDATE LyricsAnnotation
SET content = ''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque nec massa laoreet, tincidunt eros et, pulvinar quam. Maecenas a volutpat.''
WHERE id = ''eca2a313-db10-4345-9148-4b00195aabe4'';');

-- Adding Songs
-- Without lyrics
SELECT * FROM bench('INSERT INTO Song(artist, album, song, songNumber, year)
VALUES(''10873cce-8b9f-4dc5-9f95-b4088ad44bc1'', ''Invincible Shield'', ''Panic Attack'', ''1'', ''2024'');');

-- With lyrics
SELECT * FROM bench('INSERT INTO Song(artist, album, song, lyrics, songNumber, year)
VALUES(''10873cce-8b9f-4dc5-9f95-b4088ad44bc1'', ''Invincible Shield'', ''The Serpent and the King'', ''Idols to their worlds
Manifesting anger,
Conjurers of evil times!
We can sense the danger!

They claim every soul,
Show you who''''s the leader!
Bow before iconoclasts,
Creators of disaster!

They play with stars and sulphur just for heaven''''s sake.
To them we are a fantasy to see who''''s first to break.
When good and evil go to war we leave it up to fate.
Since time began they fought for man incurring love and hate.

The serpent and the king.
The serpent and the king.
The serpent and the king.
The serpent and the king.

Wiping out the weak,
Lording their creation!
Where you hide they''''ll find to seek!
Feeding those mistaken!

Pyramid of bones
Satiate their hunger!
Volatilic, they condone,
Sympathize no longer!

They play with stars and sulphur just for heaven''''s sake.
To them we are fantasy to see who''''s first to break.
When good and evil go to war we leave it up to fate.
Since time began they fought for man incurring love and hate!

The serpent and the king.
The serpent and the king.
The end is coming soon.
The serpent and the king.
The serpent and the king.
It''''s time to meet your doom!

Cast out of paradise temptation''''s wrath.
Constrict self-sacrifice, the tree of life.

They claim every soul,
Show you who''''s the leader.
Bow before iconoclasts,
Creators of disaster.

They play with stars and sulphur just for heaven''''s sake.
To them we are fantasy to see who''''s first to break.
When good and evil go to war we leave it up to fate.
Since time began they fought for man incurring love and hate.

The serpent and the king.
The serpent and the king.
The serpent and the king.
The serpent and the king.

The serpent and the king.
The end is coming soon.
The serpent and the king.
Prepare to meet your doom!'', ''2'', ''2024'');');

-- Edit Songs lyrics
SELECT * FROM bench('UPDATE Song
SET lyrics = ''

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus egestas sem non magna congue rhoncus. Nulla lacinia ultrices massa, sit amet dapibus turpis venenatis eu. Maecenas vitae ipsum justo. Aliquam erat volutpat. Vestibulum venenatis eros arcu, id rhoncus nunc finibus non. Aliquam cursus auctor tincidunt. Maecenas vulputate nunc sed risus ullamcorper dignissim.

Sed feugiat feugiat eros, sed venenatis dolor efficitur nec. Fusce suscipit semper ligula, in ullamcorper augue vulputate quis. Vestibulum fermentum hendrerit sem at eleifend. Pellentesque velit eros, gravida viverra lectus vel, egestas cursus sem. Etiam vestibulum scelerisque ipsum, quis dictum est placerat vel. In hac habitasse platea dictumst. Donec quis accumsan nulla, ut suscipit dui. Suspendisse pulvinar, velit eget bibendum congue, nulla velit porttitor urna, ac viverra nunc metus et tellus. Ut mollis, urna ut gravida posuere, dolor erat luctus dolor, eget pellentesque dolor orci in tortor. Maecenas vulputate, magna eu vehicula ultricies, est mi faucibus est, quis posuere justo magna quis augue. Ut ornare sit amet tortor vel volutpat. Donec consequat arcu non nisl finibus, a tincidunt felis elementum. Duis semper sed nunc nec egestas. Morbi volutpat metus quis luctus iaculis.

Ut finibus consequat ligula eget porttitor. Duis dignissim placerat ante, in faucibus magna tempus a. Etiam nisl nunc, porttitor ut ipsum eget, hendrerit fringilla risus. Vestibulum accumsan consectetur purus, ac maximus magna molestie eu. Duis a ipsum elementum, sagittis odio sed, egestas dui. Vestibulum elementum sapien non cursus accumsan. Aenean lobortis tortor a gravida tincidunt. ''
WHERE id = ''a2612590-0108-406e-8048-b0f84efa87e3'';
');

-- Rate Annotation
-- Increase Rating
SELECT *
From bench('UPDATE LyricsAnnotation
SET userRating = userRating + 1
WHERE id = ''eca2a313-db10-4345-9148-4b00195aabe4'';');

-- Decrease Rating
SELECT *
From bench('UPDATE LyricsAnnotation
SET userRating = userRating - 1
WHERE id = ''eca2a313-db10-4345-9148-4b00195aabe4'';');

-- Rate Song Theme
-- Increase Rating
SELECT *
FROM bench('Update SongThemes
SET userRating = userRating + 1
WHERE songId = ''ffc5a585-e508-4aa3-b157-cfeb42b8d57c'' AND themeId = ''9a263075-31a1-4a39-8aae-739fbb203f29'';');

-- Decrease Song Theme Rating
SELECT *
FROM bench('Update SongThemes
SET userRating = userRating - 1
WHERE songId = ''ffc5a585-e508-4aa3-b157-cfeb42b8d57c'' AND themeId = ''9a263075-31a1-4a39-8aae-739fbb203f29'';');

-- Register Users
SELECT * FROM bench('INSERT INTO AppUser(name, email)
VALUES (''PoserCrusher667'', ''poser@heavy.metal'');');

-- Adding Themes to Songs
SELECT * FROM BENCH('INSERT INTO SongThemes(songId, themeId)
VALUES((SELECT id FROM song ORDER BY random() LIMIT 1), (SELECT id FROM themes ORDER BY random() LIMIT 1));');
