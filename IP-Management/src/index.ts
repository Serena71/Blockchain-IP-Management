import Web3 from 'web3';
import { WebsocketProvider, Account } from 'web3-core';
import { deployContract } from './deploy';
import { handleRequestEvent } from './listen';
import { loadCompiledSols } from './load';
import { grabTemperature, grabData } from './dataGrabber';
import { methodSend } from './send';
import { Contract } from 'web3-eth-contract';
let fs = require('fs');

function initializeProvider(): WebsocketProvider {
  try {
    let provider_data = fs.readFileSync('eth_providers/providers.json');
    let provider_json = JSON.parse(provider_data);
    let provider_link = provider_json['provider_link'];
    return new Web3.providers.WebsocketProvider(provider_link);
  } catch (error) {
    throw 'Cannot read provider';
  }
}

function getAccount(web3: Web3, name: string): Account {
  try {
    let account_data = fs.readFileSync('eth_accounts/accounts.json');
    let account_json = JSON.parse(account_data);
    let account_pri_key = account_json[name]['pri_key'];
    return web3.eth.accounts.wallet.add('0x' + account_pri_key);
  } catch (error) {
    throw 'Cannot read account';
  }
}

var shellArgs = process.argv.slice(2);
if (shellArgs.length < 1) {
  console.error('node programName cmd, e.g. node index.js deploy');
  process.exit(1);
}

(async function run() {
  let web3Provider!: WebsocketProvider;
  let web3!: Web3;
  try {
    web3Provider = initializeProvider();
    web3 = new Web3(web3Provider);
  } catch (e) {
    throw 'web3 cannot be initialized';
  }

  var cmd0 = shellArgs[0];

  if (cmd0 == 'deploy') {
    if (shellArgs.length < 2) {
      console.error('e.g. node index.js deploy oracle');
      process.exit(1);
    }
    if (shellArgs[1] == 'oracle') {
      try {
        let account = getAccount(web3, 'trusted_server');
        let loaded = loadCompiledSols(['oracle']);
        let contract = await deployContract(
          web3!,
          account,
          loaded.contracts['oracle']['TemperatureOracle'].abi,
          loaded.contracts['oracle']['TemperatureOracle'].evm.bytecode.object,
          [account.address]
        );
        console.log('oracle contract address: ' + contract.options.address);
      } catch (err) {
        console.error('error deploying contract');
        console.error(err);
      }
    } else if (shellArgs[1] == 'userapp') {
      if (shellArgs.length <= 2) {
        console.error('need to specify oracle address');
      } else {
        let oracleAddr = shellArgs[2];
        try {
          let account = getAccount(web3, 'user');
          let loaded = loadCompiledSols(['oracle', 'userapp']);
          let contract = await deployContract(
            web3!,
            account,
            loaded.contracts['userapp']['UserApp'].abi,
            loaded.contracts['userapp']['UserApp'].evm.bytecode.object,
            [oracleAddr]
          );
          console.log('user app contract address: ' + contract.options.address);
        } catch (err) {
          console.error('error deploying contract');
          console.error(err);
        }
      }
    }
    web3Provider.disconnect(1000, 'Normal Closure');
  } else if (cmd0 == 'listen') {
    if (shellArgs.length < 3) {
      console.error('e.g. node index.js listen oracle 0x23a01...');
      process.exit(1);
    }
    if (shellArgs[1] == 'oracle') {
      let account!: Account;
      let contract!: Contract;
      try {
        account = getAccount(web3, 'trusted_server');
        let loaded = loadCompiledSols(['oracle']);
        let contractAddr = shellArgs[2];
        contract = new web3.eth.Contract(loaded.contracts['oracle']['TemperatureOracle'].abi, contractAddr, {});
      } catch (err) {
        console.error('error listening oracle contract');
        console.error(err);
      }
      handleRequestEvent(contract, async (caller: String, requestId: Number, data: any) => {
        console.log('start data grabbing');
        let cities = web3.eth.abi.decodeParameters(['string', 'string'], data);
        let city1 = cities[0];
        let city2 = cities[1];
        let temperature1 = await grabTemperature(city1);
        let temperature2 = await grabTemperature(city2);

        let temperatureHex1!: String;
        let temperatureHex2!: String;
        try {
          temperatureHex1 = web3.utils.toTwosComplement(temperature1);
          temperatureHex2 = web3.utils.toTwosComplement(temperature2);
        } catch (e) {
          console.error('invalid temperature grabbed');
          console.error(e);
          return;
        }
        let temperaturesHex = web3.eth.abi.encodeParameters(['uint256', 'uint256'], [temperatureHex1, temperatureHex2]);
        console.log('the temperature in ' + city1 + ' is ' + temperature1);
        console.log('the temperature in ' + city2 + ' is ' + temperature2);
        let receipt = await methodSend(
          web3,
          account,
          contract.options.jsonInterface,
          'replyData(uint256,address,bytes)',
          contract.options.address,
          [requestId, caller, temperaturesHex]
        );
        // console.log(receipt);
      });
    }
  } else if (cmd0 == 'invoke') {
    if (shellArgs.length < 4) {
      console.error('e.g. node index.js run oracle 0x23a01...');
      process.exit(1);
    }
    if (shellArgs[1] == 'userapp') {
      let account!: Account;
      let contract!: Contract;
      try {
        account = getAccount(web3, 'user');
        let loaded = loadCompiledSols(['oracle', 'userapp']);
        let contractAddr = shellArgs[3];
        contract = new web3.eth.Contract(loaded.contracts['userapp']['UserApp'].abi, contractAddr, {});
      } catch (err) {
        console.error('error listening oracle contract');
        console.error(err);
      }
      if (shellArgs[2] == 'getTemperature') {
        let receipt = await methodSend(
          web3,
          account,
          contract.options.jsonInterface,
          'getTemperature(string,string)',
          contract.options.address,
          ['Sydney', 'Melbourne']
        );
        // console.log(receipt);
        // let receipt1 = await contract.methods.temperature1().call();
        // let receipt2 = await contract.methods.temperature2().call();
        // console.log('Sydnet: ' + receipt1 + ' ' + 'Melbourne: ' + receipt2);
      } else if (shellArgs[2] == 'viewTemperature') {
        let receipt1 = await contract.methods.temperature1().call();
        let receipt2 = await contract.methods.temperature2().call();
        console.log('Sydnet: ' + receipt1 + ' ' + 'Melbourne: ' + receipt2);
      }
    }
    web3Provider.disconnect(1000, 'Normal Closure');
  }
})();
