// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./song.sol";
import "./oracle.sol";

contract Factory {
    address oracle;
    address manager;

    // Address for the last created song contract
    address address_container;

    // Storage of addresses of created song contracts
    mapping (bytes32 => address) public address_map;

    // Storing manager of each song
    bytes32  copy_right_id;
    mapping (bytes32 => address) public song_manager_map;

    // Storing id of each song according to their song title
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

    // Function to create the song contract
    function addSong(string memory song_name, address song_manager, uint price) public restricted{
        // Pseudorandom data to generate a unique copy_right_id
        string memory temp;
        // temp = Strings.toString(block.number);
        // temp = string(bytes.concat(bytes(song_name),bytes(temp)));
        temp = "random data";
        copy_right_id = sha256(abi.encodePacked(temp));

        // Creating new song contract and storing relevant details
        Song new_song = new Song(song_name, song_manager, copy_right_id, price, oracle);
        address_container = address(new_song);
        address_map[copy_right_id] = address_container;
        song_manager_map[copy_right_id] = song_manager;
        get_song_id[song_name] = copy_right_id;
    }

    // Function to get song address by name
    function searchSong(string memory title) public view returns(address){
        bytes32 id = get_song_id[title];
        return address_map[id];
    }
}
