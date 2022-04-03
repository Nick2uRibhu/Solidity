//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Spotify {
    struct Song {
        uint256 id;
        uint256 c_ID;
        address payable owner;
        uint256 price;
        uint256 listens;
        bool exist;
    }
    mapping(uint256 => Song) public songDetails;
    uint256 count = 0;
    event songCreated(uint256 id);
    address payable manager;

    constructor() {
        manager == msg.sender;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only Manager can do this!");
        _;
    }

    function createSong(uint256 c_ID, uint256 price) public {
        require(!songDetails[c_ID].exist, "C-Id can not be the same");
        songDetails[c_ID] = Song(
            count,
            c_ID,
            payable(msg.sender),
            price,
            0,
            true
        );
        count++;
        emit songCreated(count);
    }

    function destroySong(uint256 c_ID) public onlyManager {
        require(songDetails[c_ID].exist == true, "No such song exist!!");
        delete songDetails[c_ID];
    }
}
