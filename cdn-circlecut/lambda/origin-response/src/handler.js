'use strict';

const AWS = require('aws-sdk');
const S3 = new AWS.S3({ signatureVersion: 'v4' });
const Sharp = require('sharp');

const BUCKET = 'acceptessa2-cdn';

module.exports.origin_response = async (event) => {
  const response = event.Records[0].cf.response;
  const request = event.Records[0].cf.request;

  if (response.status == 404) {
    const uri = request.uri;
    const key = uri.substring(1);
    const match = key.match(/^(.+?)\/(\d+)\/(.+?)$/);

    if (!match) {
      console.log("PATH_NOT_MATCH " + uri);
      return response;
    }

    const prefix = match[1];
    const width = parseInt(match[2], 10);
    const imageName = match[3];
    const originalKey = prefix + "/" + imageName;

    try {
      const file = await S3.getObject({ Bucket: BUCKET, Key: originalKey }).promise();
      const buffer = await Sharp(file.Body)
        .resize(width, width, { fit: 'outside' })
        // .toFormat(requiredFormat)
        .toBuffer();

      response.status = 200;
      response.body = buffer.toString('base64');
      response.bodyEncoding = 'base64';
      // response.headers['content-type'] = [{ key: 'Content-Type', value: 'image/' + requiredFormat }];
      response.headers['content-type'] = [{ key: 'Content-Type', value: 'image/jpg' }];

      console.log("RESIZED " + uri);
      return response;
    } catch (err) {
      console.log(err);
      console.log("Exception while reading source image :%j", err);
      return response;
    }
  } else {
    return response;
  }
};
