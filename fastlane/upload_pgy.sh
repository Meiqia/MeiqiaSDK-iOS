#!/usr/bin/env/ bash

set -ev
file_path=""
key=""
api_key=""
if [ -z $1 ];then
    echo 'ipa path missing'
    EOF
else
    file_path=$1
fi

curl -F ${file_path}
-F "uKey=${key}"
-F "_api_key=${api_key}"
http://www.pgyer.com/apiv1/app/upload
