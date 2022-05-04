'use strict';

module.exports.viewer_request = async (event) => {
  return { message: 'Go Serverless v1.0! Your function executed successfully!', event };
};

module.exports.origin_response = async (event) => {
  return { message: 'Go Serverless v1.0! Your function executed successfully!', event };
};
