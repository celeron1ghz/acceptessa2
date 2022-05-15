'use strict';

module.exports.viewer_request = async (event) => {
  console.log(JSON.stringify(event, null, 2));
  const req = event.Records[0].cf.request;
  return req;
};

module.exports.origin_response = async (event) => {
  console.log(JSON.stringify(event, null, 2));
  const req = event.Records[0].cf.request;
  return req;
};
