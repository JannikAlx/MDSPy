CREATE TABLE Song
(
    id         UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    artist     VARCHAR(2048),
    album      VARCHAR(2048),
    song       VARCHAR(2048),
    lyrics     TEXT,
    songNumber SMALLINT,
    year       SMALLINT,
    language   VARCHAR(256),
    certainty  DOUBLE PRECISION
);

COPY Song (artist, album, song, lyrics, songNumber, year, language, certainty)
    FROM '/var/lib/postgresql/csvs/Large_Metal_Lyrics_Archive_refined.csv'
    WITH (FORMAT CSV, HEADER TRUE);

ALTER TABLE Song
    DROP COLUMN certainty,
    DROP COLUMN language;

CREATE TYPE status AS ENUM ('ACTIVE', 'ON HOLD', 'SPLIT-UP', 'UNKNOWN');

create or replace function lipsum(quantity_ integer) returns character varying
    language plpgsql
as
$$
declare
    words_       text[];
    returnValue_ text := '';
    random_      integer;
    ind_         integer;
begin
    words_ :=
            array ['lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing', 'elit', 'a', 'ac', 'accumsan', 'ad', 'aenean', 'aliquam', 'aliquet', 'ante', 'aptent', 'arcu', 'at', 'auctor', 'augue', 'bibendum', 'blandit', 'class', 'commodo', 'condimentum', 'congue', 'consequat', 'conubia', 'convallis', 'cras', 'cubilia', 'cum', 'curabitur', 'curae', 'cursus', 'dapibus', 'diam', 'dictum', 'dictumst', 'dignissim', 'dis', 'donec', 'dui', 'duis', 'egestas', 'eget', 'eleifend', 'elementum', 'enim', 'erat', 'eros', 'est', 'et', 'etiam', 'eu', 'euismod', 'facilisi', 'facilisis', 'fames', 'faucibus', 'felis', 'fermentum', 'feugiat', 'fringilla', 'fusce', 'gravida', 'habitant', 'habitasse', 'hac', 'hendrerit', 'himenaeos', 'iaculis', 'id', 'imperdiet', 'in', 'inceptos', 'integer', 'interdum', 'justo', 'lacinia', 'lacus', 'laoreet', 'lectus', 'leo', 'libero', 'ligula', 'litora', 'lobortis', 'luctus', 'maecenas', 'magna', 'magnis', 'malesuada', 'massa', 'mattis', 'mauris', 'metus', 'mi', 'molestie', 'mollis', 'montes', 'morbi', 'mus', 'nam', 'nascetur', 'natoque', 'nec', 'neque', 'netus', 'nibh', 'nisi', 'nisl', 'non', 'nostra', 'nulla', 'nullam', 'nunc', 'odio', 'orci', 'ornare', 'parturient', 'pellentesque', 'penatibus', 'per', 'pharetra', 'phasellus', 'placerat', 'platea', 'porta', 'porttitor', 'posuere', 'potenti', 'praesent', 'pretium', 'primis', 'proin', 'pulvinar', 'purus', 'quam', 'quis', 'quisque', 'rhoncus', 'ridiculus', 'risus', 'rutrum', 'sagittis', 'sapien', 'scelerisque', 'sed', 'sem', 'semper', 'senectus', 'sociis', 'sociosqu', 'sodales', 'sollicitudin', 'suscipit', 'suspendisse', 'taciti', 'tellus', 'tempor', 'tempus', 'tincidunt', 'torquent', 'tortor', 'tristique', 'turpis', 'ullamcorper', 'ultrices', 'ultricies', 'urna', 'ut', 'varius', 'vehicula', 'vel', 'velit', 'venenatis', 'vestibulum', 'vitae', 'vivamus', 'viverra', 'volutpat', 'vulputate'];
    for ind_ in 1 .. quantity_
        loop
            ind_ := (random() * (array_upper(words_, 1) - 1))::integer + 1;
            returnValue_ := returnValue_ || ' ' || words_[ind_];
        end loop;
    return returnValue_;
end;
$$;

CREATE OR REPLACE FUNCTION rand_status()
    RETURNS status
    LANGUAGE SQL AS
$$
(SELECT mystatus FROM unnest(enum_range(NULL::status)) mystatus ORDER BY random() LIMIT 1)
$$;

CREATE TABLE country(
    country VARCHAR(64)
);

COPY Country(country)
    FROM '/var/lib/postgresql/csvs/countries.csv'
    WITH (FORMAT CSV);

CREATE OR REPLACE FUNCTION rand_country()
    RETURNS VARCHAR
    LANGUAGE SQL AS
$$
(SELECT country FROM COUNTRY ORDER BY random() LIMIT 1)
$$;


CREATE TABLE Artist
(
    id        UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    name      VARCHAR(2048),
    formedIn  smallint,
    status    status                    DEFAULT rand_status(),
    country   VARCHAR(128)              DEFAULT rand_country(),
    biography TEXT                      DEFAULT lipsum(50)
);

INSERT INTO Artist (name)(SELECT DISTINCT artist FROM Song);

UPDATE Artist
    set formedIn = random() * 50 + 1970
WHERE formedIn = 0;

UPDATE Song as S
SET artist = (SELECT id FROM Artist as A WHERE S.artist = A.name);

ALTER TABLE Song
    ALTER COLUMN artist SET DATA TYPE UUID USING artist::uuid,
    ALTER COLUMN artist SET NOT NULL,
    ADD FOREIGN KEY (artist) REFERENCES Artist (id);

UPDATE Artist as A
SET formedIn = (SELECT MIN(year) FROM SONG AS S where A.id = S.artist);

CREATE TABLE AppUser
(
    id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name  varchar(64) NOT NULL,
    email varchar(64) NOT NULL
);

CREATE TABLE LyricsAnnotation
(
    id             UUID PRIMARY KEY                      DEFAULT gen_random_uuid(),
    appUser        UUID REFERENCES AppUser (id) NOT NULL,
    song           UUID REFERENCES Song (id)    NOT NULL,
    characterStart SMALLINT                     NOT NULL,
    characterEnd   SMALLINT                     NOT NULL,
    content        TEXT                         NOT NULL,
    userRating     INTEGER                      NOT NULL DEFAULT 0
);

CREATE TABLE Themes
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    theme       VARCHAR(32)  NOT NULL,
    description VARCHAR(512) NOT NULL
);

CREATE TABLE tempThemes(
    themes VARCHAR(64)
);

COPY tempThemes(themes)
    FROM '/var/lib/postgresql/csvs/themes.csv'
    WITH (FORMAT CSV);


INSERT INTO Themes (theme, description)
SELECT *, lipsum(50) FROM tempThemes;

DROP TABLE tempThemes;

CREATE TABLE SongThemes
(
    songId     UUID REFERENCES Song (id),
    themeId    UUID REFERENCES Themes (id),
    userRating INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (songId, themeId)
);

CREATE INDEX song_search_idx ON Song
    USING GIN (
               (setweight(to_tsvector('english', coalesce(song, '')), 'A') ||
                setweight(to_tsvector('english', coalesce(album, '')), 'C') ||
                setweight(to_tsvector('english', coalesce(lyrics, '')), 'D'))
        );

CREATE TABLE fts
(
    artistId   UUID NOT NULL,
    artistName VARCHAR(2048),
    songID     UUID NOT NULL,
    songName   VARCHAR(2048),
    album      VARCHAR(2048),
    lyrics     TEXT
);

CREATE INDEX fts_idx ON fts
    USING GIN ((setweight(to_tsvector('english', coalesce(songName, '')), 'A') ||
                setweight(to_tsvector('english', coalesce(artistName, '')), 'B') ||
                setweight(to_tsvector('english', coalesce(album, '')), 'C') ||
                setweight(to_tsvector('english', coalesce(lyrics, '')), 'D')));

INSERT INTO fts
SELECT Artist.id, Artist.name, Song.id, Song.song, Song.album, Song.lyrics
FROM Song
         JOIN Artist ON Artist.id = Song.artist;

CREATE FUNCTION update_fts() RETURNS TRIGGER AS
$BODY$
BEGIN
    UPDATE fts
    SET lyrics = new.lyrics
    WHERE songId = new.id;
    RETURN new;
END;
$BODY$
    language plpgsql;

CREATE FUNCTION insert_into_fts() RETURNS TRIGGER AS
$BODY$
BEGIN
    INSERT INTO fts
    SELECT artist.id, artist.Name, song.id, song.song, song.album, song.lyrics
    FROM song
             JOIN Artist on Song.artist = artist.id
    WHERE song.id = new.id;
    RETURN new;
END;
$BODY$
    language plpgsql;

CREATE FUNCTION delete_from_fts() RETURNS TRIGGER AS
$BODY$
BEGIN
    DELETE
    FROM fts
    WHERE songId = old.id;
    RETURN OLD;
END;
$BODY$
    language plpgsql;


CREATE TRIGGER add_song_to_fts
    AFTER INSERT
    ON Song
    FOR EACH ROW
EXECUTE FUNCTION insert_into_fts();

CREATE TRIGGER remove_song_from_fts
    AFTER DELETE
    ON Song
    FOR EACH ROW
EXECUTE FUNCTION delete_from_fts();


CREATE TRIGGER update_lyrics_in_fts
    AFTER UPDATE OF lyrics
    ON Song
    FOR EACH ROW
EXECUTE FUNCTION update_fts();

CREATE OR REPLACE FUNCTION bench(query TEXT, iterations INTEGER = 100)
    RETURNS TABLE
            (
                avg    FLOAT,
                min    FLOAT,
                q1     FLOAT,
                median FLOAT,
                q3     FLOAT,
                p95    FLOAT,
                max    FLOAT
            )
AS
$$
DECLARE
    _start TIMESTAMPTZ;
    _end   TIMESTAMPTZ;
    _delta DOUBLE PRECISION;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS _bench_results
    (
        elapsed DOUBLE PRECISION
    );

    -- Warm the cache
    FOR i IN 1..5
        LOOP
            EXECUTE query;
        END LOOP;

    -- Run test and collect elapsed time into _bench_results table
    FOR i IN 1..iterations
        LOOP
            START TRANSACTION;
            _start = clock_timestamp();
            EXECUTE query;
            _end = clock_timestamp();
            _delta = 1000 * (extract(epoch from _end) - extract(epoch from _start));
            ROLLBACK;
            INSERT INTO _bench_results VALUES (_delta);
        END LOOP;

    RETURN QUERY SELECT avg(elapsed),
                        min(elapsed),
                        percentile_cont(0.25) WITHIN GROUP (ORDER BY elapsed),
                        percentile_cont(0.5) WITHIN GROUP (ORDER BY elapsed),
                        percentile_cont(0.75) WITHIN GROUP (ORDER BY elapsed),
                        percentile_cont(0.95) WITHIN GROUP (ORDER BY elapsed),
                        max(elapsed)
                 FROM _bench_results;
    DROP TABLE IF EXISTS _bench_results;

END
$$
    LANGUAGE plpgsql;