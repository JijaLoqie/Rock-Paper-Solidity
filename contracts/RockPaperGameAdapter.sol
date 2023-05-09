// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RockpaperGame.sol";

contract RockPaperGameAdapter {
    address rockPaperGame;

        // function, created for testing, is not used for commit/reveal pattern
    function commitMove(Element _move, string memory _secret) external {
        bytes32 _hashedMove = keccak256(abi.encodePacked(_move, _secret, msg.sender));

        require(_move != Element.BadElement, "bad element type!");
        (bool success,) = rockPaperGame.call("commitMove");
    }

    

    function getWinner() public view returns(address){
        (bool successGetResult, bytes memory result) = rockPaperGame.call("getResult");
        (bool successGetParticipants, bytes memory participants) = rockPaperGame.call("participants");


        if (result[0] == result[1]) {
            return address(0);
        }
        // SOLUTION: 
        // 1. cast `result` to Element[2]
        // 2. cast `participants` to address[2]

        if (result[0] == Element.Rock && result[1] == Element.Paper ||
        result[0] == Element.Paper && result[1] == Element.Scissors ||
        result[0] == Element.Scissors && result[1] == Element.Rock) {

            return participants[1];
        } else {
            return participants[0];
        }
    }
}