module.exports.origin_response = async (event) => {
  console.log(JSON.stringify(event, null, 2));
  const res = event.Records[0].cf.response;
  return res;
};
