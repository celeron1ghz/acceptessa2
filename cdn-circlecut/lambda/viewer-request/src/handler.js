'use strict';

const querystring = require('querystring');

const allowWidths = [
  100,
  200,
  300,
];

const defaultWidth = 200;

module.exports.viewer_request = async (event) => {
  const request = event.Records[0].cf.request;
  const params = querystring.parse(request.querystring);
  const uri = request.uri;

  if (!params.w) {
    console.log("NO_PARAM " + uri);
    return request;
  }

  const match = uri.match(/^\/([^/]+?)\/([^/]+)$/);

  if (!match) {
    console.log("NOT_MATCHED " + uri);
    return request;
  }

  const prefix = match[1];
  const imageName = match[2];
  let width;

  if (allowWidths.includes(parseInt(params.w))) {
    width = params.w;
  } else {
    width = defaultWidth;
  }

  const newUri = [
    '',
    prefix,
    width,
    imageName,
  ].join("/");

  console.log("RESOLVED " + request.uri + " => " + newUri);
  request.uri = newUri;
  return request;
};
