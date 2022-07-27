import Web3 from 'web3';
import { WebsocketProvider, Account } from 'web3-core';
import { deployContract } from './deploy';
import { handleRequestEvent } from './listen';
import { loadCompiledSols } from './load';
import { grabData } from './dataGrabber';
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
          loaded.contracts['oracle']['Oracle'].abi,
          loaded.contracts['oracle']['Oracle'].evm.bytecode.object,
          [account.address]
        );
        console.log('oracle contract address: ' + contract.options.address);
      } catch (err) {
        console.error('error deploying contract');
        console.error(err);
      }
    } else if (shellArgs[1] == 'factory') {
      if (shellArgs.length <= 2) {
        console.error('need to specify oracle address');
      } else {
        let oracleAddr = shellArgs[2];
        try {
          let account = getAccount(web3, 'trusted_server');
          let loaded = loadCompiledSols(['oracle', 'factory']);
          let contract = await deployContract(
            web3!,
            account,
            loaded.contracts['factory']['Factory'].abi,
            loaded.contracts['factory']['Factory'].evm.bytecode.object,
            [oracleAddr]
          );
          console.log('factory contract address: ' + contract.options.address);
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
        contract = new web3.eth.Contract(loaded.contracts['oracle']['Oracle'].abi, contractAddr, {});
      } catch (err) {
        console.error('error listening oracle contract');
        console.error(err);
      }
      handleRequestEvent(contract, async (requestType: Number, caller: String, requestId: Number, data: any) => {
        console.log('start data grabbing');
        let c = caller;
        
        let hex;
        if (requestType == 0) {
          // pass hashcode, get status of license
          let param = web3.eth.abi.decodeParameters(['string'], data);

          let status = await grabData('get', { hashcode: param[0] });
          hex = web3.eth.abi.encodeParameters(['string', 'address'], [status, "0x4624C6C4Fd1Cff64FCAd238f9d8bCFbF9859847c"]);
          console.log('the license status is ' + status);
        } else if (requestType == 1) {
          // pass licnese info, write into database, and get hashcode
          let params = web3.eth.abi.decodeParameters(['address', 'address', 'uint256', 'uint256'], data);
          const body = {
            buyer: params[0],
            song: params[1],
            duration: params[2],
            totalCost: params[3],
          };
          let hashcode = await grabData('post', body);
          console.log(caller);
          
          hex = web3.eth.abi.encodeParameters(['string', 'address'], [hashcode, params[0]]);
          console.log('the license hashcode is ' + hashcode);
        }

        let receipt = await methodSend(
          web3,
          account,
          contract.options.jsonInterface,
          'replyData(uint256,uint256,address,bytes)',
          contract.options.address,
          [requestType, requestId, caller, hex]
        );
        // console.log(receipt);
      });
    }
  } else if (cmd0 == 'invoke') {
    if (shellArgs[2] == 'search') {
      if (shellArgs.length < 4) {
        console.error('Please specify the contract address');
        process.exit(1);
      }
      let account!: Account;
      let contract!: Contract;
      try {
        account = getAccount(web3, 'user');
        let loaded = loadCompiledSols(['oracle', 'factory']);
        let contractAddr = shellArgs[1];
        contract = new web3.eth.Contract(loaded.contracts['factory']['Factory'].abi, contractAddr, {});
      } catch (err) {
        console.error('error listening factory contract');
        console.error(err);
      }
      const address = await contract.methods.searchSong(shellArgs[3]).call();
      console.log('Song address for ' + shellArgs[3] + ' is ' + address);
    } else if (shellArgs[1] == 'song') {
      if (shellArgs.length < 4) {
        console.error('e.g. node index.js run oracle 0x23a01...');
        process.exit(1);
      }
      let account!: Account;
      let contract!: Contract;
      try {
        account = getAccount(web3, 'user');
        let loaded = loadCompiledSols(['oracle', 'song']);
        let contractAddr = shellArgs[2];
        contract = new web3.eth.Contract(loaded.contracts['song']['Song'].abi, contractAddr, {});
      } catch (err) {
        console.error('error listening song contract');
        console.error(err);
      }
      if (shellArgs[3] == 'requestStatus') {
        const receipt = await methodSend(
          web3,
          account,
          contract.options.jsonInterface,
          'getLicenseStatus(string)',
          contract.options.address,
          [shellArgs[4]]
        );
      } else if (shellArgs[3] == 'receiveStatus') {
        const status = await contract.methods.license_status().call();
        console.log(status);
      } else if (shellArgs[3] == 'purchase') {
        const receipt = await methodSend(
          web3,
          account,
          contract.options.jsonInterface,
          'purchaseSong(uint256)',
          contract.options.address,
          [shellArgs[4]]
        );
      } else if (shellArgs[3] == 'receiveHashcode') {
        const hashcode = await contract.methods.license_hashcode().call();
        console.log(hashcode);
      } 
    } else if (shellArgs[1] == 'factory') {
      let account!: Account;
      let contract!: Contract;
      try {
        account = getAccount(web3, 'trusted_server');
        let loaded = loadCompiledSols(['oracle', 'factory']);
        let contractAddr = shellArgs[4];
        contract = new web3.eth.Contract(loaded.contracts['factory']['Factory'].abi, contractAddr, {});
      } catch (err) {
        console.error('error listening factory contract');
        console.error(err);
      }

      if (shellArgs[2] == 'addSong'){
        console.log("adding song");
        const receipt = await methodSend(
          web3,
          account,
          contract.options.jsonInterface,
          'addSong(string,address,uint256)',
          contract.options.address,
          [shellArgs[3], shellArgs[6], shellArgs[5]]
        );
      }
    }

    web3Provider.disconnect(1000, 'Normal Closure');
  }
})();
