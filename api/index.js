const Hapi = require("hapi");

const registerRoutes = require("./routes");

const server = Hapi.server({
  port: 8080,
  host: "0.0.0.0"
});

const start = async () => {
  // const db = await require("./db").start();

  await registerRoutes(server, null);

  await server.start();
};

start().catch(err => {
  console.error(err);
  process.exit(1);
});
