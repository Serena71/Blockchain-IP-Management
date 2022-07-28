// SPDX-License-Identifier: GPL-3.0
import "./oracle.sol";

pragma solidity^0.8.0;


contract Song is LicenseAgreementOracleClient{
    // Variables
    string song_name;
    uint number_of_artists = 0;

    // Price for a 1 year license of the contract
    uint price;

    // List of names of artist's who've contributed to the project
    string[] artist_list;

    // Address of user who can add artists to this song
    address song_manager;

    // Variable used by factory contract for mapping purposes
    bytes32 copy_right_id;

    struct artist {
        uint id;
        string name;
        address artist_address;
        string role;

        // Integer percentage of artists contribution since solidity doesnt handle floats
        uint contribution;
    }

    // Mapping of artist by id
    mapping(uint => artist) artist_map;

    // Mapping of license hash codes and expire date so user can only access their data
    mapping(address => string) license_map;
    mapping(address => string) date_map;

    mapping(address => uint256) balance;

    // constructor
    constructor(string memory _song_name, address _song_manager, bytes32 _copy_right_id, uint _price, address oracleAd) LicenseAgreementOracleClient(oracleAd){
        song_name = _song_name;
        song_manager = _song_manager;
        copy_right_id = _copy_right_id;
        price = _price * 1 gwei;
    }
    
    // Function to add artist, only accessible by song manager designated in the constructor
    function addArtist(string memory _name, address _artist_address,string memory  _role, uint _contribution) external{
        require(msg.sender == song_manager, "This function can only be accessed by song manager");

        // Creating new artist struct
        artist memory temp_artist;
        temp_artist.id = number_of_artists++;
        temp_artist.name = _name;
        temp_artist.artist_address = _artist_address;
        temp_artist.role = _role;
        temp_artist.contribution = _contribution;

        // A seperate struct for artist is is created and added to the artist map
        artist_map[temp_artist.id] = temp_artist;

        // Artist names is pushed in a seperate array which can be used to return when user asks for artist details
        artist_list.push(_name);
    }

    // Function to get the song price
    function getSongPrice() public view returns(uint) {
        return price;
    }

    // Function to get the list of artist's who've contributed to this song
    function getArtistList () public view returns(string[] memory) {
         return artist_list;
    }

     // Function to get artist details
    function getArtistDetails(uint _id) external view returns (artist memory) {
        return artist_map[_id];
    }

    // Function to purchase song, sets license hash for the caller once purchase has gone through
    function purchaseSong(uint256 _duration) public payable {
        uint256 total_cost = price * _duration;
        uint256 duration = _duration;
        address buyer = msg.sender;

        // Check
        require(msg.value == total_cost, "The amount transferred does not equal the cost of the license");

        // Effect
        // Set up payment distribution
        uint256 block_amount = total_cost / 100;
        for (uint i = 0; i < number_of_artists; i++)
        {
            balance[artist_map[i].artist_address] += block_amount * artist_map[i].contribution;
        }

        // Interaction
        writeLicenseAgreement(buyer, address(this), duration, total_cost);
    }

    function withdraw() public {
        address payable add = payable(msg.sender);
        // Check
        uint256 result = balance[msg.sender];

        // Effect
        balance[msg.sender] = 0;

        // Interaction
        add.send(result);
    }

    function checkBalance() public view returns (uint256){
        return balance[msg.sender];
    }

    // Function called once the oracle has returned the hash of license for the purchased song
    function receiveHash(uint256 request_id, address caller, string memory _license_hash) internal override{
        license_map[caller] = _license_hash;
    }

    // Function for user to get the hash of a license they've purchased
    function getLicenseHash() public view returns (string memory) {
        address caller = msg.sender;
        return license_map[caller];
    }

    // Function to get license expiry date if the user has purchased a license
    function getLicenseExpiry() public view returns (string memory) {
        address caller = msg.sender;
        return date_map[caller];
    }

    // Function to set license status so the user can check expiry
    function getLicenseStatus(string memory _license_hash) public {
        requestLicenseStatus(_license_hash);
    }

    // Function called internally once oracle has prepared the data
    function receiveLicenseStatus(uint256 request_id, address caller, string memory _license_status) internal override {
        date_map[caller] = _license_status;
    }
}