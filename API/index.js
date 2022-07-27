// import { checkExpiry } from './service.js';
const service = require('./service.js');

let fs = require('fs');
const bodyParser = require('body-parser');
const express = require('express');
const app = express();

const cors = require('cors');

const PORT = process.env.PORT || 5050;
app.listen(PORT, () => console.log(`App listening on http://localhost:${PORT}`));

app.use(express.static('public'));
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json({ limit: '50mb' }));

const catchErrors = (fn) => async (req, res) => {
  try {
    await fn(req, res);
    service.save();
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
};


// API endpoint to check status of a license
app.get(
  '/checkStatus',
  catchErrors(async (req, res) => {
    const { hashcode } = req.query;
    return res.json(await service.checkExpiry(hashcode));
  })
);

// API endpoint to create a new license in the database
app.post(
  '/addLicense',
  catchErrors(async (req, res) => {
    const { buyer, song, duration, totalCost } = req.body;
    return res.status(200).json(await service.addLicense(buyer, song, duration, totalCost));
  })
);
