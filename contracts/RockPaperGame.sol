// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperGame {
    enum Element {
        BadElement,
        Rock,
        Paper,
        Scissors
    }

    event moveCommited(bytes32 _hashedMove, uint time);
    event moveRevealed(address who, Element move, uint time);
    event gameEnded(uint time, address game);

    mapping (address => bytes32) public elements;
    mapping (address => Element) public results;
    address[] public participants;
    bool public gameStopped;

    modifier gameIsRelevant {
        require(!gameStopped, "Game is stopped!");
        _;
    }

    // function, where input - hashed bytes32, which includes secret word, sender and his move
    function commitMove(bytes32 _hashedMove) external gameIsRelevant() {
        require(elements[msg.sender] == bytes32(0), "Move is already commited!");
        require(participants.length < 2, "Game is full of participants!");

        participants.push(msg.sender);
        elements[msg.sender] = _hashedMove;

        emit moveCommited(_hashedMove, block.timestamp);
    }

    // function, created for testing, is not used for commit/reveal pattern
    function commitMove(Element _move, string memory _secret) external gameIsRelevant() {
        bytes32 _hashedMove = keccak256(abi.encodePacked(_move, _secret, msg.sender));

        require(_move != Element.BadElement, "bad element type!");

        require(elements[msg.sender] == bytes32(0), "Move is already commited!");
        require(participants.length < 2, "Game is full of participants!");

        participants.push(msg.sender);
        elements[msg.sender] = _hashedMove;

        emit moveCommited(_hashedMove, block.timestamp);
    }

    function revealMove(Element _move, string memory _secret) external {
        require(gameStopped, "Wait for game stop!!");

        bytes32 hashedMove = keccak256(abi.encodePacked(_move, _secret, msg.sender));
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


    function getResult() public view returns(Element[2] memory){
        require(gameStopped,  "Wait for game stop!!");
        
        Element move1 = results[participants[0]];
        require(move1 != Element.BadElement, "1-st player should reveal!");
        Element move2 = results[participants[1]];
        require(move2 != Element.BadElement, "2-st player should reveal!");


        return [move1, move2];
    }

    function getWinner() public view returns(address){
        Element[2] memory result = getResult();

        if (result[0] == result[1]) {
            return address(0);
        }

        if (result[0] == Element.Rock && result[1] == Element.Paper ||
        result[0] == Element.Paper && result[1] == Element.Scissors ||
        result[0] == Element.Scissors && result[1] == Element.Rock) {

            return participants[1];
        } else {
            return participants[0];
        }
    }
}