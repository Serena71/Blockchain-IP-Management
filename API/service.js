const fs = require('fs');
const AsyncLock = require('async-lock');
const merkleJson = require('merkle-json');
const { MerkleJson } = require('merkle-json');
const lock = new AsyncLock();

/***************************************************************
                       State Management
***************************************************************/

const DATABASE_FILE = './database.json';
let data = fs.readFileSync(DATABASE_FILE);
let licenses = JSON.parse(data);

const LicenseLock = (callback) =>
  new Promise((resolve, reject) => {
    lock.acquire('licenseLock', callback(resolve, reject));
  });

const update = (licenses) =>
  new Promise((resolve, reject) => {
    lock.acquire('saveData', () => {
      try {
        fs.writeFileSync(DATABASE_FILE, JSON.stringify(licenses, null, 2));
        resolve();
      } catch {
        reject(new Error('Writing to database failed'));
      }
    });
  });

const save = () => update(licenses);

/***************************************************************
                       Write License Agreement
***************************************************************/

const calculateExpiryDate = (purchaseDate, duration) => {
  return new Date(purchaseDate.setMonth(purchaseDate.getMonth() + duration)).toDateString();
};

const addLicense = (buyer, song, duration, totalCost) =>
  LicenseLock((resolve, reject) => {
    const now = new Date();

    const agreementData = {
      buyer: buyer,
      song: song,
      purchaseDate: now.toDateString(),
      duration: duration,
      expiryDate: calculateExpiryDate(now, duration),
      totalCost: totalCost,
    };

    let mj = new MerkleJson();
    // let hash = Object.keys(licenses).pop();
    // hash = parseInt(hash) + 1;
    let merklehash = mj.hash(agreementData);
    licenses[merklehash] = agreementData;

    resolve(merklehash);
  });

/***************************************************************
                       Check License Status
***************************************************************/

const checkExpiry = (hash) =>
  LicenseLock((resolve, reject) => {
    const expiryDate = new Date(licenses[hash].expiryDate);
    const now = new Date(new Date().toDateString());
    resolve(now > expiryDate ? 'expired' : 'valid');
  });

module.exports = { save, addLicense, checkExpiry };
