//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;

interface Nft {
    function isOwner(address, uint256) external view returns (uint16);
}
interface NftOwnership {
    function isOwner(address, uint256) external view returns (uint16);
}

contract Votes {

    address owner;
    address NftAddress;
    address NftOwnershipAddress;
    bool changing;

    struct poll {
        mapping(uint256 => uint256) votes;
        mapping(uint256 => uint256) voted;
        uint256 [] vote;
        string [] options;
        string description;
    }

    string activePoll;

    mapping(string => poll) polls;

    constructor (address _NftAddress, address _NftOwnership) {
        owner = msg.sender;
        NftAddress = _NftAddress;
        NftOwnershipAddress = _NftOwnership;
    }

    function changeNftAddress(address newAddress) public{
        require(msg.sender == owner, "Not Owner");
        NftAddress = newAddress;
    }

    function changeNftOwnershipAddress(address newAddress) public{
        require(msg.sender == owner, "Not Owner");
        NftOwnershipAddress = newAddress;
    }

    function ownership(address _sender, uint256 nftId) private view returns(uint16) {
        if(_sender == owner || NftOwnership(NftOwnershipAddress).isOwner(_sender, nftId) == 1){
            return 1;
        }
        return 0;
    }

    modifier createdPoll(uint256 nftid, string memory _name) {
        require(ownership(msg.sender, nftid) == 1, "Not Alowed");
        require(polls[_name].votes[0] == 0, "Error. Poll already voted or in vote");
        _;
   }


    function CreateOrEditPoll(uint256 nftid, string memory _name, string memory _description) public createdPoll(nftid, _name) {
        polls[_name].description = _description;
    }

    function addOption(uint256 nftid, string memory _name, string memory _description) public createdPoll(nftid, _name) {
        polls[_name].options.push(_description);
        polls[_name].vote.push(0);
    }

    function setPoll(uint256 nftid, string memory _name) public createdPoll(nftid, _name) {
        polls[_name].votes[0] = 1;
        activePoll = _name;
    }

    function getPoll() public view returns(string memory, string[] memory) {
        return (polls[activePoll].description, polls[activePoll].options);
    }

    modifier changingVotes(uint256 nftid, uint256 _vote) {
        if(changing == false) {
            require(_vote >= 0, "Invalid Vote");
            require(Nft(NftAddress).isOwner(msg.sender, nftid) == 1, "Invalid Nft");
            require(_vote < polls[activePoll].options.length, "Invalid Vote");
            changing = true;
            _;
            changing = false; 
        }
    }

    function vote(uint256 nftid, uint256 _vote, uint256 _votes) public changingVotes (nftid, _vote) {

        require(polls[activePoll].votes[nftid] == 0, "Nft Already Voted");
        polls[activePoll].voted[nftid] = _vote;
        polls[activePoll].votes[nftid] = _votes;
        polls[activePoll].vote[_vote] += _votes;
    }


    function changeVote(uint256 nftid, uint256 _vote) public changingVotes (nftid, _vote) {
        polls[activePoll].vote[polls[activePoll].voted[nftid]] -= polls[activePoll].votes[nftid];
        polls[activePoll].voted[nftid] = _vote;
        polls[activePoll].vote[_vote] += polls[activePoll].votes[nftid];
    }

    function voted(uint256 nftid) public view returns (bool) {
        if(polls[activePoll].votes[nftid] == 0){
            return false;
        }
        return true;
    }

    function countVotes() public view returns (uint256[] memory) {

        uint256[] memory _votes = polls[activePoll].vote;

        return _votes;

    }
}