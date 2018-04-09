module.exports = (server, db) => {
  server.route({
    method: "GET",
    path: "/items",
    handler: (req, h) => [
      {
        _id: "1",
        title: "A Suit",
        price: 12.5,
        unitForPrice: "perDay",
        thumbnail:
          "https://davidreevesbespoke.files.wordpress.com/2011/03/me-24.jpg"
      }
    ]
  });

  server.route({
    method: "GET",
    path: "/items/1",
    handler: (req, h) => ({
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
  });

  // server.route({
  //   method: "GET",
  //   path: "/users"
  // });

  // server.route({
  //   method: "GET",
  //   path: "/users/{id}"
  // });

  // server.route({
  //   method: "POST",
  //   path: "/users"
  // });

  // server.route({
  //   method: "POST",
  //   path: "/items"
  // });

  // server.route({
  //   method: "POST",
  //   path: "/login"
  // });
};
