// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// Interface abstraction
interface OracleInterface {
    function requestData(uint256 requestType, uint256 requestId, bytes memory data) external;
}

// Client abstraction
abstract contract OracleClient {
    uint256 request_counter;
    address oracle_address;

    constructor (address add) {
        oracle_address = add;
        request_counter = 0;
    }

    function requestDataFromOracle(uint256 request_type, bytes memory data) public {
        Oracle(oracle_address).requestData(request_type, request_counter++, data);
    }

    function replyDataFromOracle(uint256 request_type, uint256 request_id, bytes memory data) public virtual;
}

// Oracle implementation
contract Oracle is OracleInterface{
    address trusted_server_address;
    event request(uint256 request_type, uint256 request_id, address caller, bytes data);

    constructor (address add) {
        trusted_server_address = add;
    }

    function requestData(uint256 request_type, uint256 request_id, bytes memory data) public override{
        emit request(request_type, request_id, msg.sender, data);
    }

    function replyData(uint256 request_type, uint256 request_id, address caller, bytes memory data) public {
        OracleClient(caller).replyDataFromOracle(request_type, request_id, data);
    }
}

// License client abstraction
abstract contract LicenseAgreementOracleClient is OracleClient {

    constructor (address add) OracleClient(add){}

    // Used to create a license, called when purchase song is called
    function writeLicenseAgreement(address buyer, address song, uint256 duration, uint256 totalCost) internal{
        // Encode data to send to oracle
        bytes memory request_data = abi.encode(buyer, song, duration, totalCost);
        requestDataFromOracle(1, request_data);
    }

    // Used to check license expiry status from oracle
    function requestLicenseStatus(string memory data) internal{
        // Encoding data to send to oracle
        bytes memory request_data = abi.encode(data, msg.sender);
        requestDataFromOracle(0, request_data);
    }

    // Called by oracle interface once data is ready
    function replyDataFromOracle(uint256 request_type, uint256 request_id, bytes memory data) public override
    {
        // Decode data and segment it into receive hash or receive license based on request type
        (string memory return_data, address caller) = abi.decode(data, (string, address));
        if (request_type == 0){
            receiveLicenseStatus(request_id, caller, return_data);
        } else if (request_type == 1){
            receiveHash(request_id, caller, return_data);
        }
    }

    // Implemented by License client implementation to handle receiving of hashes
    function receiveHash(uint256 requestId, address caller, string memory returnData) internal virtual{
    }

    // Implemented by License client implementation to handle receiving of license status
    function receiveLicenseStatus( uint256 requestId, address caller, string memory returnData) internal virtual{
    }
}