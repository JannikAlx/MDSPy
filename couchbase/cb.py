import datetime
import json
from datetime import timedelta

import pandas as pd
# needed for any cluster connection
from couchbase.auth import PasswordAuthenticator
from couchbase.cluster import Cluster
# needed for options -- cluster, timeout, SQL++ (N1QL) query, etc.
from couchbase.options import (ClusterOptions, ClusterTimeoutOptions,
                        QueryOptions)



# Update this to your cluster
username = "MDS"
password = "supersecure"
bucket_name = "default"
# User Input ends here.

# Connect options - authentication
auth = PasswordAuthenticator(
    username,
    password,
)

# Get a reference to our cluster
# NOTE: For TLS/SSL connection use 'couchbases://<your-ip-address>' instead
cluster = Cluster('127.0.0.1', ClusterOptions(auth))

# Wait until the cluster is ready for use.
cluster.wait_until_ready(timedelta(seconds=5))

# get a reference to our bucket
cb = cluster.bucket(bucket_name)

cb_coll = cb.scope("_default").collection("_default")


print("Loading data...")

test = json.load(open("../data/final.json"))

print(test)
a = datetime.datetime.now()
returnval = cb_coll.upsert_multi(test)
b = datetime.datetime.now()
c = b - a
print("Took " + str(c.seconds) + "seconds and " + str(c.microseconds) + "ms to save " + str(returnval) + " documents")