'use strict';

module.exports.main = async (event) => {
  console.log(JSON.stringify(event, null, 2));
  return null;
};
