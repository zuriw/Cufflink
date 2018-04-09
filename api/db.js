const { MongoClient } = require("mongodb");

module.exports = async () => {
  const client = await MongoClient.connect(
    "mongodb+srv://cufflink:Z4sfeyl2e8ecXCc5@cufflink-cyonp.mongodb.net/test"
  );

  return client.db("cufflink");
};
