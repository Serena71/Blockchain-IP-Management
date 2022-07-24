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
    }

    function requestDataFromOracle(uint256 requestType, bytes memory data) public {
        Oracle(oracleAddress).requestData(requestType, requestCounter++, data);
    }

    function replyDataFromOracle(uint256 requestId, bytes memory data) public virtual;
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

    function replyData(uint256 requestId, bytes memory data) public {
        OracleClient(trustedServerAddress).replyDataFromOracle(requestId, data);
    }
}

abstract contract LicenseAgreementOracleClient is OracleClient {
    uint256 public hash = 0;
    bool public license = false;

    constructor (address add) OracleClient(add){}

    // buyer, song, duration, totalCost, purchaseDate, expiryDate
    function writeLicenseAgreement(address buyer, address song, uint256 duration, uint256 totalCost) public{
        // Writing license and awaitng hash

        bytes memory requestData = abi.encode(buyer, song, duration, totalCost);
        requestDataFromOracle(1, requestData);
    }

    function receiveHash(bytes memory returnData) private{
        // Receiving hash
        // Call song contracts receive hash
        hash = 1;
    }

    function requestLicenseStatus() public{
        // Requesting status and receiving status
        bytes memory requestData = abi.encode();
        requestDataFromOracle(0, requestData);
    }

    function receiveLicenseStatus(bytes memory returnData) private{
        // Figure out what to do with license status

        // Used only to verify function was called correctly
        license = true;
    }

    function testGetZero() pure public returns(uint256) {
        uint256 x = 0;
        return x;
    }

    function replyDataFromOracle(uint256 requestId, bytes memory data) public override
    {
        // Decode data and segment it into receive hash or receive license
        (uint256 requestType, bytes memory returnData) = abi.decode(data, (uint256, bytes));
        if (requestType == 0){
            receiveLicenseStatus(returnData);
        } else if (requestType == 1){
            receiveHash(returnData);
        }
        requestId = 0;
    }
}