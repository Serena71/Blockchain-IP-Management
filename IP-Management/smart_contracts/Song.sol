// SPDX-License-Identifier: GPL-3.0

pragma solidity^0.8.0;

contract Song{
    // Variables
    string  song_name;
    address  song_manager;
    bytes32  copy_right_id;
    uint  price;
    uint  number_of_artists = 0;
    string[]  artist_list;

    struct artist {
        uint id;
        string name;
        address artist_address;
        string role;
        uint contribution;
    }
    mapping(uint => artist) artist_map;

    // constructor
    constructor(string memory _song_name, address _song_manager, bytes32 _copy_right_id, uint _price){
        song_name = _song_name;
        song_manager = _song_manager;
        copy_right_id = _copy_right_id;
        price = _price;
    }
    
    // Function to add artist
    function songAddArtist(uint _id,string memory _name, address _artist_address,string memory  _role, uint _contribution) external{
        number_of_artists++;
        artist memory temp_artist;
        temp_artist.id = _id;
        temp_artist.name = _name;
        temp_artist.artist_address = _artist_address;
        temp_artist.role = _role;
        temp_artist.contribution = _contribution;
        // A seperate struct for artist is is created and added to the artist map
        artist_map[_id] = temp_artist;
        // Artist names is pushed in a seperate array which can be used to return when user asks for artist details
        artist_list.push(_name);
    }

    // function to return artist details if given id
    function songArtistDetails(uint _id) external view returns (artist memory) {
        return artist_map[_id];
    }

    // function to return song price
    function returnPrice() external view returns(uint){
        return price;
    }

    // function to return artist list
    function returnArtistList() external view returns(string[] memory){
        return artist_list;
    }
}