'use strict';

module.exports.main = async (event) => {
  console.log(JSON.stringify(event, null, 2));
  const req = event.Records[0].cf.request;
  return req;
};