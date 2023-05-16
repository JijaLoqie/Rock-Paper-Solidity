// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RockPaperGame.sol";

contract RockPaperGameAdapter {
    address rockPaperGame;
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier shouldBeInit() {
        require(rockPaperGame != address(0), "rockPaperGame should be init!!!");
        _;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "only owner of this contract can do that!!!");
        _;
    }
    function init(address _rockPaperGame) onlyOwner public {
        rockPaperGame = _rockPaperGame;
    }

        // function, created for testing, is not used for commit/reveal pattern
    function callCommitMove(uint _move, string memory _secret) external onlyOwner shouldBeInit {
        bytes32 _hashedMove = keccak256(abi.encodePacked(msg.sender, _move, _secret));

        require(_move != 0, "bad element type!");
        (bool success,) = rockPaperGame.call(
			abi.encodeWithSignature("commitMove(address,bytes32)", owner, _hashedMove)
		);

		require(success, "Something went wrong!");
    }

    

    function GetWinner() external onlyOwner shouldBeInit returns(address) {
        (bool successGetResult, bytes memory _result) = rockPaperGame.call(
			abi.encodeWithSignature("getResult(bytes32)")
		);
		require(successGetResult, "getResult: something went wrong!");

        (bool successGetParticipants, bytes memory _participants) = rockPaperGame.call(
			abi.encodeWithSignature("getParticipants()")
			);
		require(successGetParticipants, "getParticipants: something went wrong!");

		address[2] memory participants = abi.decode(_participants, (address[2]));
		uint[2] memory result = abi.decode(_result, (uint[2]));

        if (result[0] == result[1]) {
            return address(0);
        }

        if (result[0] == 1 && result[1] == 2 ||
        result[0] == 2 && result[1] == 3 ||
        result[0] == 3 && result[1] == 1) {
            return participants[1];
        } else {
            return participants[0];
        }
    }
}