// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract RockPaperGame {

    event moveCommited(bytes32 _hashedMove, uint time);
    event moveRevealed(address who, uint move, uint time);
    event gameEnded(uint time, address game);

    mapping (address => bytes32) public elements;
    mapping (address => uint) public results;
    address[] private participants;
    bool public gameStopped;

    modifier gameIsRelevant {
        require(!gameStopped, "Game is stopped!");
        _;
    }

    function getParticipants() external view returns(address[] memory) {
		return participants;
	}
    function callCommitMove(uint _move, string memory _secret) external gameIsRelevant {
        bytes32 _hashedMove = keccak256(abi.encodePacked(msg.sender, _move, _secret));

        require(_move != 0, "bad element type!");
        commitMove(msg.sender, _hashedMove);
    }
    // function, where input - hashed bytes32, which includes secret word, sender and his move
    function commitMove(address who, bytes32 _hashedMove) public gameIsRelevant {
        require(elements[who] == bytes32(0), "Move is already commited!");
        require(participants.length < 2, "Game is full of participants!");

        participants.push(who);
        elements[who] = _hashedMove;

        emit moveCommited(_hashedMove, block.timestamp);
    }

    function revealMove(uint _move, string memory _secret) external {
        require(gameStopped, "Wait for game stop!!");

        bytes32 hashedMove = keccak256(abi.encodePacked(msg.sender, _move, _secret));
        require(hashedMove == elements[msg.sender], "Wrong reveal proof!");

        delete elements[msg.sender];
        results[msg.sender] = _move;

        emit moveRevealed(msg.sender, _move, block.timestamp);
    }

    function stopGame() external gameIsRelevant() {
        require(participants.length == 2, "Not enough participants! Need 2");

        gameStopped = true;


        emit gameEnded(block.timestamp, address(this));
    }


    function getResult() public view returns(uint[2] memory){
        require(gameStopped,  "Wait for game stop!!");
        
        uint move1 = results[participants[0]];
        require(move1 != 0, "1-st player should reveal!");
        uint move2 = results[participants[1]];
        require(move2 != 0, "2-st player should reveal!");


        return [move1, move2];
    }
}