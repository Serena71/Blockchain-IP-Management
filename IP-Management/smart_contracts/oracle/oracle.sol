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

    function replyDataFromOracle(uint256 requestType, uint256 requestId, bytes memory data) public virtual;
}

contract Oracle is OracleInterface{
    address trustedServerAddress;
    event request(uint256, uint256, address, bytes);

    constructor (address add) {
        trustedServerAddress = add;
    }

    function requestData(uint256 requestType, uint256 requestId, bytes memory data) public {
        emit request(requestType, requestId, msg.sender, data);
    }

    function replyData(uint256 requestType, uint256 requestId, bytes memory data) public {
        OracleClient(trustedServerAddress).replyDataFromOracle(requestType, requestId, data);
    }
}

abstract contract LicenseAgreementOracleClient is OracleClient {
    constructor (address add) OracleClient(add){}

    // buyer, song, duration, totalCost, purchaseDate, expiryDate
    function writeLicenseAgreement(address buyer, address song, uint256 duration, uint256 totalCost) public{
        // Writing license and awaitng hash

        bytes memory requestData = abi.encode(buyer, song, duration, totalCost);
        requestDataFromOracle(1, requestData);
    }


    function requestLicenseStatus() public{
        // Requesting status and receiving status
        bytes memory requestData = abi.encode();
        requestDataFromOracle(0, requestData);
    }

    
    function replyDataFromOracle(uint256 requestType, uint256 requestId, bytes memory data) public override
    {
        // Decode data and segment it into receive hash or receive license
        (string memory returnData) = abi.decode(data, (string));
        if (requestType == 0){
            receiveLicenseStatus(requestId,returnData);
        } else if (requestType == 1){
            receiveHash(requestId, returnData);
        }
    }
     function receiveHash( uint256 requestId, string memory returnData) private{
        // Receiving hash
        // Call song contracts receive hash
        
    }

    function receiveLicenseStatus( uint256 requestId, string memory returnData) private{
        // Call song contracts receive license status

        // Call song contracts receive license 
    }

}