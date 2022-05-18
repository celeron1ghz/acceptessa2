const AWS = require('aws-sdk');
const ddb = new AWS.DynamoDB.DocumentClient();

module.exports.main = async (event) => {
  for (const record of event.Records) {
    const data = JSON.parse(record.Sns.Message);

    delete data.mail.sourceArn;
    delete data.mail.callerIdentity;
    delete data.mail.sendingAccountId;
    delete data.mail.headersTruncated;
    delete data.mail.headers;
    delete data.mail.commonHeaders;
    // console.log(JSON.stringify(data, null, 2));

    await ddb.put({
      TableName: process.env.TABLE_NAME,
      Item: {
        MessageId: data.mail.messageId,
        Raw: JSON.stringify(data),
      }
    }).promise();
  }

  return "OK";
};