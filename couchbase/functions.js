// max theme per doc
function mapThemes(doc, meta) {
    if (doc.themes.length > 0 && doc.artist.id)
        var max = 0;
    for (var i = 1; i < themes.length; i++) {
        if (themes[i].userRating > max) {
            max = i;
        }
    }
    emit([doc.artist.id, doc.themes[max].name], doc.themes[max].userRating)
}

function reduceThemes(keys, values, rereduce) {
    var result = {};
    for (var i = 0; i < keys.length; i++) {
        var key = values[i];
        if (result[key]) {
            result[key] += 1;
        } else {
            result[key] = 1;
        }
    }
    return result;
}

// key = title, value = lyrics.lyricText, artist.country
function titleToLyrics(doc, meta) {
    if (doc.lyrics && doc.artist && doc.title) {
        emit(doc.title, {lyrics: doc.lyrics.lyricText, country: doc.artist.country});
    }
}

// key = artist.country, value = title, lyrics.lyricText

function artistToTitleLyrics(doc, meta) {
    if (doc.lyrics && doc.artist && doc.title) {
        emit(doc.artist.country, {title: doc.title, lyrics: doc.lyrics.lyricText});
    }
}

