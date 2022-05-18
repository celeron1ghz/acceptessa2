module.exports.main = async (event) => {
  for (const record of event.Records) {
    const data = JSON.parse(record.Sns.Message);

    console.log(JSON.stringify(data, null, 2));

    delete data.mail.sourceArn;
    delete data.mail.callerIdentity;
    delete data.mail.sendingAccountId;
    delete data.mail.headersTruncated;
    delete data.mail.headers;
    delete data.mail.commonHeaders;

    console.log(JSON.stringify(data, null, 2));
  }

  return "OK";
};