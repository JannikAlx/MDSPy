import datetime
import json
from datetime import timedelta

import pandas as pd
# needed for any cluster connection
from couchbase.auth import PasswordAuthenticator
from couchbase.cluster import Cluster
# needed for options -- cluster, timeout, SQL++ (N1QL) query, etc.
from couchbase.options import (ClusterOptions, ClusterTimeoutOptions,
                               QueryOptions, ViewOptions)

username = "MDS"
password = "supersecure"
bucket_name = "default"

# Connect options - authentication
auth = PasswordAuthenticator(
    username,
    password,
)
cluster = Cluster('127.0.0.1', ClusterOptions(auth))
cluster.wait_until_ready(timedelta(seconds=3))

# get a reference to our bucket
cb = cluster.bucket(bucket_name)

cb_coll = cb.scope("_default").collection("_default")

def lookup_by_song_title(title):
    print("\nLookup Result: ")
    try:
        default_scope = cb.scope("_default")
        sql_query = 'SELECT VALUE title FROM default WHERE title = $1'
        row_iter = default_scope.query(
            sql_query,
            QueryOptions(positional_parameters=[title]))
        for row in row_iter:
            print(row)
    except Exception as e:
        print(e)


res = cb.view_query("songdesign", "by_album_song_count", ViewOptions(group=True))

for row in res:
    print(row)

