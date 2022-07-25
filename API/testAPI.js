// import axios from 'axios';
const axios = require('axios');
async function testAPI(method, body) {
  let res;
  if (method === 'get') {
    res = await axios.get('http://localhost:5050/checkStatus', { params: body });
  } else {
    res = await axios.post('http://localhost:5050/addLicense', body);
  }

  const data = await res.data;
  // const res = await fetch('/license');
  // const data = await res.json();
  return data;
}

function getData(hashcode) {
  testAPI('get', { hashcode })
    .then((data) => console.log(data))
    .catch((e) => console.error(e));
}

function sentData() {
  const body = {
    buyer: 'buyer3',
    song: 'song3',
    duration: 0,
    totalCost: 100,
  };
  testAPI('post', body)
    .then((data) => console.log(data))
    .catch((e) => console.error(e));
}

getData('0d495106bb1445e29ca563d15d9be9d1');
// sentData();
