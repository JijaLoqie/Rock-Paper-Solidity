// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperGame {
    enum Element {
        BadElement,
        Rock,
        Paper,
        Scissors
    }

    mapping (address => bytes32) public elements;
    mapping (address => Element) public results;
    address[] public participants;
    bool public gameStopped;

    // function, where input - hashed bytes32, which includes secret word, sender and his move
    function commitMove(bytes32 _hashedMove) external {
        require(!gameStopped, "Game is stopped!");
        require(elements[msg.sender] == bytes32(0), "Move is already commited!");
        require(participants.length < 3, "Game is full of participants!");

        participants.push(msg.sender);
        elements[msg.sender] = _hashedMove;
    }

    // function, created for testing, is not used for commit/reveal pattern
    function commitMove(Element _move, string memory _secret) external {
        bytes32 _hashedMove = keccak256(abi.encodePacked(_move, _secret, msg.sender));

        require(_move != Element.BadElement, "bad element type!");

        require(!gameStopped, "Game is stopped!");
        require(elements[msg.sender] == bytes32(0), "Move is already commited!");
        require(participants.length < 3, "Game is full of participants!");

        participants.push(msg.sender);
        elements[msg.sender] = _hashedMove;
    }

    function revealMove(Element _move, string memory _secret) external {
        require(gameStopped, "Wait for game stop!!");

        bytes32 hashedMove = keccak256(abi.encodePacked(_move, _secret, msg.sender));
        require(hashedMove == elements[msg.sender], "Wrong reveal proof!");

        delete elements[msg.sender];
        results[msg.sender] = _move;
    }

    function stopGame() external {
        require(participants.length == 3, "Not enough participants! Need 3");
        gameStopped = true;
    }

    function getWinner() public view returns(Element[3] memory){
        require(gameStopped,  "Wait for game stop!!");
        
        Element move1 = results[participants[0]];
        require(move1 != Element.BadElement, "1st player should reveal!");
        Element move2 = results[participants[1]];
        require(move2 != Element.BadElement, "2st player should reveal!");
        Element move3 = results[participants[2]];
        require(move3 != Element.BadElement, "3st player should reveal!");

        return [move1, move2, move3];        
    }
}