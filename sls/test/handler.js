'use strict';

module.exports.main = async (event) => {
  if (!event.Records) {
    throw new Error("no record");
  }

  for (const r of event.Records) {
    let mess;
    try {
      mess = JSON.parse(r.body);
    } catch (error) {
      throw new Error("Error on queue parent: mess=" + error);
    }

    const id = mess.MessageId;
    let data;

    try {
      data = JSON.parse(mess.Message);
      console.log(data);
    } catch (error) {
      throw new Error("Error on queue child: id=" + id + " mess=" + error);
    }
  }

  console.log(JSON.stringify(event, null, 2));
  return null;
};
