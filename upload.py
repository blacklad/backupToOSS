# !/usr/bin/env python
# -*- coding: utf-8 -*-
import os, sys, getopt, oss2

# args
localFile = ''
bucket = ''

try:
    opts, args = getopt.getopt(sys.argv[1:], 'a:s:f:e:b:p:')
except getopt.GetoptError as err:
    print(str(err))
    exit()

for k, val in opts:
    if k == '-a':
        access_key_id = val
    elif k == '-s':
        access_key_secret = val
    elif k == '-f':
        localFile = val
    elif k == '-e':
        endpoint = val
    elif k == '-b':
        bucket_name = val
    elif k == '-p':
        oss_dir = val

bucket = oss2.Bucket(oss2.Auth(access_key_id, access_key_secret), endpoint, bucket_name)

# upload
if os.path.isfile(localFile):
    oss_path = os.path.join(oss_dir, os.path.basename(localFile))
    bucket.put_object_from_file(oss_path, localFile)
else:
    print(localFile + ' not exists!')

exit()
