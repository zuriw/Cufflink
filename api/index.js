const crypto = require("crypto");

const express = require("express");
const app = express();
const { MongoClient } = require("mongodb");
const { verify, sign } = require("jsonwebtoken");

app.use(express.json());

const hashPassword = password => {
  const hash = crypto.createHash("sha256");
  hash.update(password);
  return hash.digest("base64");
};

const secret = "7hi2135SiSa$ee;bloy8l9EiEeeCre7";

const client = MongoClient.connect(
  "mongodb+srv://cufflink:Z4sfeyl2e8ecXCc5@cufflink-cyonp.mongodb.net/test",
  (err, client) => {
    if (err) {
      console.error(err);
      process.exit(1);
    }

    const db = client.db("cufflink");

    app.post("/signup", (req, res) => {
      if (
        req.body.email == null ||
        req.body.password == null ||
        req.body.firstName == null ||
        req.body.lastName == null ||
        req.body.location == null ||
        req.body.email.trim() === "" ||
        req.body.password.trim() === "" ||
        req.body.firstName.trim() === "" ||
        req.body.lastName.trim() === "" ||
        req.body.location.trim() === ""
      ) {
        res
          .status(400)
          .json({
            error:
              "Email, firstName, lastName, location and password are required to be non-blank."
          })
          .end();
      } else {
        const { email, password } = req.body;

        db
          .collection("users")
          .insertOne({
            email,
            hashedPassword: hashPassword(password)
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
              .json({ success: false })
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
              .findOne({ _id: decoded._id })
              .then(user => {
                req.user = user;
                next();
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

    app.get("/items", authenticate, (req, res) => {
      res
        .json([
          {
            _id: "1",
            title: "A Suit",
            price: 12.5,
            unitForPrice: "perDay",
            thumbnail:
              "https://davidreevesbespoke.files.wordpress.com/2011/03/me-24.jpg"
          }
        ])
        .end();
    });

    app.get("/items/1", authenticate, (req, res) => {
      res
        .json({
          _id: "1",
          title: "A Suit",
          price: 12.5,
          thumbnail:
            "https://davidreevesbespoke.files.wordpress.com/2011/03/me-24.jpg",
          description: "This is my fancy suit that you can rent",
          unitForPrice: "perDay",
          pictures: [
            "https://davidreevesbespoke.files.wordpress.com/2011/03/me-24.jpg",
            "https://davidreevesbespoke.files.wordpress.com/2011/12/me-52.jpg",
            "http://previewcf.turbosquid.com/Preview/2014/07/11__17_30_20/Suit2_2.jpgf5a003e9-fc72-4c69-be5a-5f05c2be6e00Original.jpg"
          ],
          owner: {
            email: "joe@gmail.com",
            name: "Joe",
            zipcode: 24060
          }
        })
        .end();
    });

    // app.get("/users");
    // app.get("/users/:id");
    // app.post("/items");

    db.collection("users").createIndex({ email: 1 }, { unique: true }, err => {
      if (err) {
        console.error(err);
        process.exit(1);
      } else {
        app.listen(8080, "0.0.0.0", () => {
          console.log("Listening on port 8080");
        });
      }
    });
  }
);
