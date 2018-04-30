const crypto = require("crypto");

const express = require("express");
const app = express();
const { MongoClient, GridFSBucket, ObjectID } = require("mongodb");
const { verify, sign } = require("jsonwebtoken");

app.use(express.json());

const hashPassword = password => {
  const hash = crypto.createHash("sha256");
  hash.update(password);
  return hash.digest("base64");
};

const secret = "7hi2135SiSa$ee;bloy8l9EiEeeCre7";

const catchPromise = fn => async (req, res) => {
  try {
    await fn(req, res);
  } catch (error) {
    res
      .json({ error })
      .status(500)
      .end();
  }
};

var db;
var bucket;
var client;




client = MongoClient.connect(
    "mongodb+srv://cufflink:Z4sfeyl2e8ecXCc5@cufflink-cyonp.mongodb.net/test",
    (err, client) => {
      if (err) {
        console.error(err);
        process.exit(1);
      }

      db = client.db("cufflink");
      bucket = new GridFSBucket(db);

      db.collection("users").createIndex({ email: 1 }, { unique: true }, err => {
        if (err) {
          console.error(err);
          process.exit(1);
          }
        });
})




app.post("/signup", (req, res) => {
      if (
        req.body.email == null ||
        req.body.password == null ||
        req.body.firstName == null ||
        req.body.lastName == null ||
        req.body.location == null ||
        req.body.phone == null ||
        req.body.email.trim() === "" ||
        req.body.password.trim() === "" ||
        req.body.firstName.trim() === "" ||
        req.body.lastName.trim() === "" ||
        req.body.location.trim() === "" ||
        req.body.phone.trim() === ""
      ) {
        res
          .status(400)
          .json({
            error:
              "Email, firstName, lastName, phone, location and password are required to be non-blank."
          })
          .end();
      } else {
        const { email, password } = req.body;

        db
          .collection("users")
          .insertOne({
            email,
            hashedPassword: hashPassword(password),
            location: req.body.location,
            firstName: req.body.firstName,
            lastName: req.body.lastName,
            phone: req.body.phone
          })
          .then(() => {
            res
              .status(200)
              .json({ success: true })
              .end();
          })
          .catch(err => {
            res
              .status(400)
              .json({ error: "Email must be unique." })
              .end();
          });
      }
    });

app.post("/login", (req, res) => {
      if (
        req.body.email == null ||
        req.body.password == null ||
        req.body.email.trim() == "" ||
        req.body.password.trim() == ""
      ) {
        res
          .status(400)
          .json({
            error: "Email and password are required to be non-blank."
          })
          .end();
      } else {
        const { email, password } = req.body;

        db
          .collection("users")
          .findOne({ email: email })
          .then(({ _id, hashedPassword }) => {
            if (hashPassword(password) === hashedPassword) {
              const token = sign({ _id }, secret);
              res.json({ token }).end();
            } else {
              res
                .status(400)
                .json({ error: "Invalid username or password" })
                .end();
            }
          })
          .catch(err => {
            res
              .status(400)
              .json({ error: "Invalid username or password" })
              .end();
          });
      }
    });

    const authenticate = (req, res, next) => {
      const failAuthentication = () => {
        res
          .status(403)
          .json({
            error: "You must provide a valid token to access this endpoint"
          })
          .end();
      };

      const token = req.header("token");
      if (token == null) {
        failAuthentication();
      } else {
        try {
          const decoded = verify(token, secret);

          if (decoded == null || decoded._id == null) {
            failAuthentication();
          } else {
            db
              .collection("users")
              .findOne({ _id: new ObjectID(decoded._id) })
              .then(user => {
                if (user == null) {
                  failAuthentication();
                } else {
                  delete user.hashedPassword;
                  req.user = user;
                  next();
                }
              })
              .catch(err => {
                failAuthentication();
              });
          }
        } catch (err) {
          failAuthentication();
        }
      }
    };

    app.get(
      "/items",
      authenticate,
      catchPromise(async (req, res) => {
        const cursor = await db.collection("items").find();
        const items = await cursor.toArray();

        res
          .json(
            items.map(item => ({
              _id: item._id,
              title: item.title,
              price: item.price,
              unitForPrice: item.unitForPrice,
              thumbnail: item.pictures[0]
            }))
          )
          .end();
      })
    );

    app.post(
      "/items",
      authenticate,
      catchPromise(async (req, res) => {
        if (!req.body.thumbnail){
          return res.status(206).json({success: false})
        }


        await db.collection("items").insertOne({
          ...req.body,
          owner: req.user._id
        });

        res.json({ success: true }).end();
      })
    );

    app.post("/upload", authenticate, (req, res) => {
      if (req.get("Content-Type") !== "image/jpeg") {
        res
          .status(400)
          .json({ error: "Only JPEG file uploads are supported" })
          .end();
      } else {
        const name = crypto.randomBytes(24).toString("hex");
        req.pipe(bucket.openUploadStream(name)).on("finish", () => {
          res.json({ url: `/photos/${name}` }).end();
        });
      }
    });

    app.get("/photos/:name", authenticate, (req, res) => {
      res.header("Content-Type", "image/jpeg");
      bucket.openDownloadStreamByName(req.params.name).pipe(res);
    });

    app.get(
      "/items/:id",
      authenticate,
      catchPromise(async (req, res) => {
        const item = await db
          .collection("items")
          .findOne({ _id: new ObjectID(req.params.id) });

        const owner = await db
          .collection("users")
          .findOne({ _id: new ObjectID(item.owner) });
        delete owner.hashedPassword;

        res
          .json({
            ...item,
            owner
          })
          .end();
      })
    );

    app.get("/me", authenticate, (req, res) => {
      res.json(req.user).end();
    });

    app.post(
      "/me",
      authenticate,
      catchPromise(async (req, res) => {
        await db
          .collection("users")
          .updateOne({ _id: new ObjectID(req.user._id) }, { $set: req.body });
        res.json({ success: true }).end();
      })
    );

    app.get(
      "/users/:id",
      authenticate,
      catchPromise(async (req, res) => {
        const user = await db
          .collection("users")
          .findOne({ _id: new ObjectID(req.params.id) });
        delete user.hashedPassword;

        res.json(user).end();
      })
    );

    app.listen(8080, "0.0.0.0", () => {
      console.log("Listening on port 8080");
    });
