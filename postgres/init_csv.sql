create table appuser
(
    id    uuid default gen_random_uuid() not null
        primary key,
    name  varchar(64)                    not null,
    email varchar(64)                    not null
);

CREATE TYPE status AS ENUM ('ACTIVE', 'ON HOLD', 'SPLIT-UP', 'UNKNOWN');

create table artist
(
    id        uuid   default gen_random_uuid() not null
        primary key,
    name      varchar(2048),
    formedin  smallint,
    status    status,
    country   varchar(128),
    biography text
);

create table song
(
    id         uuid default gen_random_uuid() not null
        primary key,
    artist     uuid                           not null
        references artist,
    album      varchar(2048),
    song       varchar(2048),
    lyrics     text,
    songnumber smallint,
    year       smallint
);

create index song_search_idx
    on song using gin (((setweight(
                                 to_tsvector('english'::regconfig, COALESCE(song, ''::character varying)::text),
                                 'A'::"char") || setweight(
                                 to_tsvector('english'::regconfig, COALESCE(album, ''::character varying)::text),
                                 'C'::"char")) ||
                        setweight(to_tsvector('english'::regconfig, COALESCE(lyrics, ''::text)), 'D'::"char")));

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

create trigger add_song_to_fts
    after insert
    on song
    for each row
execute procedure insert_into_fts();

create trigger remove_song_from_fts
    after delete
    on song
    for each row
execute procedure delete_from_fts();

create trigger update_lyrics_in_fts
    after update
        of lyrics
    on song
    for each row
execute procedure update_fts();

create table fts
(
    artistid   uuid not null,
    artistname varchar(2048),
    songid     uuid not null,
    songname   varchar(2048),
    album      varchar(2048),
    lyrics     text
);

create index fts_idx
    on fts using gin ((((setweight(to_tsvector('english'::regconfig,
                                               COALESCE(songname, ''::character varying)::text), 'A'::"char") ||
                         setweight(to_tsvector('english'::regconfig,
                                               COALESCE(artistname, ''::character varying)::text),
                                   'B'::"char")) || setweight(
                                to_tsvector('english'::regconfig, COALESCE(album, ''::character varying)::text),
                                'C'::"char")) ||
                       setweight(to_tsvector('english'::regconfig, COALESCE(lyrics, ''::text)), 'D'::"char")));

create table lyricsannotation
(
    id             uuid    default gen_random_uuid() not null
        primary key,
    appuser        uuid                              not null
        references appuser,
    song           uuid                              not null
        references song,
    characterstart smallint                          not null,
    characterend   smallint                          not null,
    content        text                              not null,
    userrating     integer default 0                 not null
);

create table themes
(
    id          uuid default gen_random_uuid() not null
        primary key,
    theme       varchar(32)                    not null,
    description varchar(512)                   not null
);

create table songthemes
(
    songid     uuid              not null
        references song,
    themeid    uuid              not null
        references themes,
    userrating integer default 0 not null,
    primary key (songid, themeid)
);

COPY appuser(id, name, email)
    FROM '/var/lib/postgresql/csvs/export/appuser.csv'
    WITH (FORMAT CSV);

COPY artist(id, name, formedin, status, country, biography)
    FROM '/var/lib/postgresql/csvs/export/artist.csv'
    WITH (FORMAT CSV);

COPY song (id, artist, album, song, lyrics, songnumber, year)
    FROM '/var/lib/postgresql/csvs/export/song.csv'
    WITH (FORMAT CSV);

COPY lyricsannotation (id, appuser, song, characterstart, characterend, content, userrating)
    FROM '/var/lib/postgresql/csvs/export/lyricsannotation.csv'
    WITH (FORMAT CSV);

COPY themes (id, theme, description)
    FROM '/var/lib/postgresql/csvs/export/themes.csv'
    WITH (FORMAT CSV);

COPY songthemes (songid, themeid, userrating)
    FROM '/var/lib/postgresql/csvs/export/songthemes.csv'
    WITH (FORMAT CSV);

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
            _start = clock_timestamp();
            EXECUTE query;
            _end = clock_timestamp();
            _delta = 1000 * (extract(epoch from _end) - extract(epoch from _start));
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