import { Contract } from 'web3-eth-contract';

export function handleRequestEvent(contract: Contract, grabData: Function) {
  // Listening for requests from the oracle
  contract.events['request(uint256,uint256,address,bytes)']()
    .on('connected', function (subscriptionId: any) {
      console.log("listening on event 'request'" + ', subscriptionId: ' + subscriptionId);
    })
    .on('data', function (event: any) {
      let requestType = event.returnValues.request_type;
      let caller = event.returnValues.caller;
      let requestId = event.returnValues.request_id;
      let data = event.returnValues.data;
      grabData(requestType, caller, requestId, data);
    })
    .on('error', function (error: any, receipt: any) {
      console.log(error);
      console.log(receipt);
      console.log("error listening on event 'request'");
    });
}
