// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface OracleInterface {
    function requestData(uint256 requestType, uint256 requestId, bytes memory data) external;
}

abstract contract OracleClient {
    uint256 requestCounter;

    address oracleAddress;

    constructor (address add) {
        
        oracleAddress = add;
        requestCounter = 0;
    }

    function requestDataFromOracle(uint256 requestType, bytes memory data) public {
        Oracle(oracleAddress).requestData(requestType, requestCounter++, data);
    }

    function replyDataFromOracle(uint256 requestType, uint256 requestId, bytes memory data) public virtual;
}

contract Oracle is OracleInterface{
    address trustedServerAddress;
    event request(uint256 requestType, uint256 requestId, address caller, bytes data);

    constructor (address add) {
        trustedServerAddress = add;
    }

    function requestData(uint256 requestType, uint256 requestId, bytes memory data) public override{
        emit request(requestType, requestId, msg.sender, data);
    }

    function replyData(uint256 requestType, uint256 requestId, bytes memory data) public {
        OracleClient(trustedServerAddress).replyDataFromOracle(requestType, requestId, data);
    }
}

abstract contract LicenseAgreementOracleClient is OracleClient {
    string public hash = "";
    bool public license = false;

    constructor (address add) OracleClient(add){}

    // buyer, song, duration, totalCost, purchaseDate, expiryDate
    function writeLicenseAgreement(address buyer, address song, uint256 duration, uint256 totalCost) public {
        // Writing license and awaitng hash

        bytes memory requestData = abi.encode(buyer, song, duration, totalCost);
        requestDataFromOracle(1, requestData);
    }


    function requestLicenseStatus(string memory data) public {
        // Requesting status and receiving status
        bytes memory requestData = abi.encode(data);
        requestDataFromOracle(0, requestData);
    }

    
    function replyDataFromOracle(uint256 requestType, uint256 requestId, bytes memory data) public override
    {
        // Decode data and segment it into receive hash or receive license
        (string memory returnData) = abi.decode(data, (string));
        if (requestType == 0){
            receiveLicenseStatus(requestId, returnData);
        } else if (requestType == 1){
            receiveHash(requestId, returnData);
        }
    }

    function receiveHash(uint256 requestId, string memory returnData) private{
        // Receiving hash

        // Call song contracts receive hash
        hash = returnData;
    }

    function receiveLicenseStatus( uint256 requestId, string memory returnData) private{
        // Call song contracts receive license status

        // Call song contracts receive license 
    }

}