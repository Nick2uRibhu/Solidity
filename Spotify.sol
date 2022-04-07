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
        bool isStaked;
    }
    mapping(uint256 => Song) public songDetails;
    uint256 count = 0;
    event songCreated(uint256 id);
    address payable public manager;

    constructor() {
        manager = payable(msg.sender);
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
            true,
            false
        );
        count++;
        emit songCreated(count);
    }

    function destroySong(uint256 c_ID) public onlyManager {
        require(songDetails[c_ID].exist == true, "No such song exist!!");
        delete songDetails[c_ID];
    }

    function listen(uint256 c_ID) public payable {
        require(
            msg.value >= songDetails[c_ID].price * 10**18,
            "Have to contribute more to listen to this song!!"
        );
        songDetails[c_ID].listens++;
        songDetails[c_ID].owner.transfer(msg.value);
    }

    uint256 public start;
    uint256 public end;

    function stakeSong(uint256 c_ID) public payable {
        require(
            songDetails[c_ID].owner == msg.sender,
            "Only Owner of the song can do this!"
        );
        require(songDetails[c_ID].isStaked == false, "Already Staked!");
        require(msg.value > 0, "Have to spend more in order to stake");
        songDetails[c_ID].isStaked = true;
        start = block.timestamp;
        end = start + 1 minutes;
    }

    // stakers address to listen number he thinks
    mapping(address => uint256) public stakers;
    //stakers address to songCID
    mapping(address => uint256) public stakers_cID;

    function stake(uint256 c_ID, uint256 _listens) public payable {
        require(
            songDetails[c_ID].isStaked == true,
            "Can not stake in this Song!"
        );
        require(
            songDetails[c_ID].listens < _listens,
            "Current Listen is greater"
        );
        require(stakers[msg.sender] == 0, "You have already Staked");
        require(msg.value > 0, "Can Not stake O!");
        stakers[msg.sender] = _listens;
        stakers_cID[msg.sender] = c_ID;
        canWithdraw[msg.sender] = true;
    }

    mapping(address => bool) public canWithdraw;

    modifier _withdraw() {
        require(canWithdraw[msg.sender] == true, "You can't do this anymore!");
        canWithdraw[msg.sender] = false;
        _;
    }

    function withdraw() public payable _withdraw {
        require(
            stakers[msg.sender] != 0,
            "You have not staked Yet or already Withdrawed or Loose!"
        );
        require(block.timestamp >= end, "Can not Withdraw before End");
        require(
            stakers[msg.sender] <= songDetails[stakers_cID[msg.sender]].listens,
            "You Lose!"
        );
        payable(msg.sender).transfer(address(this).balance);
    }

    function Bal(address add) public view returns (uint256) {
        return add.balance;
    }
}
