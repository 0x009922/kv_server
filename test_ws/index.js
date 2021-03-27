const WebSocket = require("ws");
const delay = require("delay");

const ws = new WebSocket("http://localhost:3000/ws");

function createMessage(type, payload) {
  return JSON.stringify({ type, payload });
}

function parseMessage(raw) {
  return JSON.parse(raw);
}

ws.on("open", async () => {
  console.log("Opened!");

  // Делаю всякое
  // ws.send(createMessage("set", { key: "hello", value: "test" }));

  // await delay(500);
  // ws.send(createMessage("get", { key: "hello" }));

  // подписываюсь и изменяю
  ws.send(createMessage("subscribe", { key: "some" }));

  await delay(1000);

  console.log("Setting");
  ws.send(createMessage("set", { key: "some", value: 1 }));
  await delay(500);

  console.log("updating");
  ws.send(createMessage("set", { key: "some", value: 5 }));
  await delay(500);

  console.log("updating again");
  ws.send(createMessage("set", { key: "some", value: 5 }));
  await delay(500);

  console.log("deleting");
  ws.send(createMessage("delete", { key: "some" }));
  // await delay(500);
});

ws.on("message", (data) => {
  console.log("Message! %o", parseMessage(data));
});

ws.on("close", () => {
  console.log("Closed...");
});

ws.on("error", (err) => {
  console.error("err", err);
});
