# http://tmont.com/blargh/2014/1/uploading-to-s3-in-bash

# Usage s3.sh filename destination mime-type
# Make sure to export both s3Key s3Secret

file=$1
dest=$2
bucket=datasets.project-fifo.net
resource="/${bucket}/${file}"
contentType=$3
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | openssl enc -base64`
curl -k -X PUT -T "${file}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  https://${bucket}.s3.amazonaws.com/${file}