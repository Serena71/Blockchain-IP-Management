// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

//Import utility packages
// import "@openzeppelin/contracts/utils/Strings.sol";
//Importing the song format contract
import "./song.sol";
import "./oracle.sol";

contract Factory {
    address oracle;
    address manager;
    address address_container;
    mapping (bytes32 => address) public address_map;
    bytes32  copy_right_id;
    mapping (bytes32 => address) public song_manager_map;
    mapping (string => bytes32) public get_song_id;
   

    constructor(address _oracle) {
        manager = msg.sender;
        oracle = _oracle;
    }

    // Access restriction to the AddSong function
    modifier restricted(){
        require(msg.sender == manager, "New song can only be deployed by the authorised node");
        _;
    }

    // Function to create the song
    function addSong(string memory song_name, address song_manager, uint price) public restricted{
        string memory temp;
        // temp = Strings.toString(block.number);
        // temp = string(bytes.concat(bytes(song_name),bytes(temp)));
        temp = "random data";
        copy_right_id = sha256(abi.encodePacked(temp));
        Song new_song = new Song(song_name, song_manager,copy_right_id,price, oracle);
        address_container = address(new_song);
        address_map[copy_right_id] = address_container;
        song_manager_map[copy_right_id] = song_manager;
        get_song_id[song_name] = copy_right_id;
    }

    function searchSong(string memory title) public view returns(address){
        bytes32 id = get_song_id[title];
        return address_map[id];
    }


    // // function which acts as an interfact for adding artist
    // function addArtist(bytes32 _copy_right_id, uint _id,string memory _name, address _artist_address,string memory  _role, uint _contribution) public {
    //     require(msg.sender == song_manager_map[_copy_right_id], "This function can only be accessed by song manager");
    //     Song(address_map[_copy_right_id]).songAddArtist(_id,_name,_artist_address,_role,_contribution);
    // }

    // // function to check artist details by providing their ID
    // function artistDetails(bytes32 _copy_right_id, uint _id) public view returns(factoryArtist memory){
    //     factoryArtist memory fa;
    //     fa.id =Song(address_map[_copy_right_id]).songArtistDetails(_id).id;
    //     fa.name =Song(address_map[_copy_right_id]).songArtistDetails(_id).name;
    //     fa.artist_address =Song(address_map[_copy_right_id]).songArtistDetails(_id).artist_address;
    //     fa.role =Song(address_map[_copy_right_id]).songArtistDetails(_id).role;
    //     fa.contribution =Song(address_map[_copy_right_id]).songArtistDetails(_id).contribution;
    //     return fa;
    // }

    // // Interface function to get the song price
    // function getSongPrice(bytes32 _copy_right_id) public view returns(uint) {
    //     uint song_price = Song(address_map[_copy_right_id]).returnPrice();
    //     return song_price;
    // }

    // // Interface function to get the song artist details
    // function getArtistList (bytes32  _copy_right_id) public view returns(string[] memory) {
    //      string[] memory artist_list = Song(address_map[_copy_right_id]).returnArtistList();
    //      return artist_list;
    // }

    // // Purchasing the song
    // function purchaseSong(bytes32 _copy_right_id, uint _duration,uint _amount, string memory purchase_key) public{
    //     uint expected_amount;
    //     uint duration = _duration;
    //     address buyer = msg.sender;
    //     address song_address = address_map[_copy_right_id];
    //     uint total_cost;
    //     expected_amount = getSongPrice(_copy_right_id) * duration;
    //     require(total_cost == expected_amount, "The amount you transferred does not match with the actual price");
    //     writeLicenseAgreement(buyer, song_address, duration, total_cost);
    // }

    // function receiveLicenceHash(string memory _license_hash) external{
    //     license_hash = _license_hash;
    // }

    // function getLicenseStatus(string memory _license_hash) public returns(string memory) {
    //     requestLicenseStatus(_license_hash);
    // }

    // function fReceiveLicenceStatus(string memory _license_status) external {
    //     license_status = _license_status;
    // }

    
}
