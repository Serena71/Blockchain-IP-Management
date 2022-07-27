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
  // 31536000000 = number of seconds in a year
  return new Date(purchaseDate.getTime() + 31536000000 * duration).toDateString();
};

const addLicense = (buyer, song, duration, totalCost) =>
  LicenseLock((resolve, reject) => {

    // Creating and storing the actual data
    const now = new Date();
    const agreementData = {
      buyer: buyer,
      song: song,
      purchaseDate: now.toDateString(),
      duration: duration,
      expiryDate: calculateExpiryDate(now, duration),
      totalCost: totalCost,
    };

    // Generating the hash and storing it before passing it back to the oracle
    let mj = new MerkleJson();
    let merklehash = mj.hash(agreementData);
    licenses[merklehash] = agreementData;

    // Returning the data back to the blockchain
    resolve(merklehash);
  });

/***************************************************************
                       Check License Status
***************************************************************/

// Function to check the expiry of the hash
const checkExpiry = (hash) =>
  LicenseLock((resolve, reject) => {
    // Setting the expiry date of the hash and passing it back to the oracle
    const expiryDate = new Date(licenses[hash].expiryDate);
    const now = new Date(new Date().toDateString());
    resolve(expiryDate.toDateString());
  });

module.exports = { save, addLicense, checkExpiry };
