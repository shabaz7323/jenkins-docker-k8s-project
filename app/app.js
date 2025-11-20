const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
app.get('/', (req, res) => {
  res.send({ message: 'Hello from Jenkins+Docker+K8s demo!', pod: process.env.HOSTNAME || null });
});
app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
