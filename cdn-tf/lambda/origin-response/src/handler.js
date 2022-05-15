module.exports.origin_response = async (event) => {
  const res = event.Records[0].cf.response;
  console.log(JSON.stringify(res, null, 2));
  console.log(res.status);
  console.log(res.statusDescription);
  return res;
};
