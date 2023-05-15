// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RockPaperGame.sol";

contract RockPaperGameAdapter {
    address rockPaperGame;
    address owner;

    event Check(address winner, address first, address second);

    constructor() {
        owner = msg.sender;
    }

    modifier shouldBeInit() {
        require(rockPaperGame != address(0), "rockPaperGame should be init!!!");
        _;
    }
    modifier onlyOwner() {
        require(
            owner == msg.sender,
            "only owner of this contract can do that!!!"
        );
        _;
    }

    function init(address _rockPaperGame) public onlyOwner {
        rockPaperGame = _rockPaperGame;
    }

    // function, created for testing, is not used for commit/reveal pattern
    function callCommitMove(uint256 _move, string memory _secret)
        external
        onlyOwner
        shouldBeInit
    {
        bytes32 _hashedMove = keccak256(
            abi.encodePacked(msg.sender, _move, _secret)
        );

        require(_move != 0, "bad element type!");
        (bool success, ) = rockPaperGame.call(
            abi.encodeWithSignature(
                "commitMove(address,bytes32)",
                owner,
                _hashedMove
            )
        );

        require(success, "Something went wrong!");
    }

    function GetWinner() external view onlyOwner shouldBeInit returns (string memory) {
        (bool successGetResult, bytes memory _result) = rockPaperGame.staticcall(
            abi.encodeWithSignature("getResult()")
        );
        require(successGetResult, "getResult: something went wrong!");

        (
            bool successGetParticipants,
            bytes memory _participants
        ) = rockPaperGame.staticcall(abi.encodeWithSignature("getParticipants()"));
        require(
            successGetParticipants,
            "getParticipants: something went wrong!"
        );
        address winner;

        address[] memory participants = abi.decode(
            _participants,
            (address[])
        );
        uint256[2] memory result = abi.decode(_result, (uint256[2]));

        if (result[0] == result[1]) {
            return "Same element!";
        }

        if (
            (result[0] == 1 && result[1] == 2) ||
            (result[0] == 2 && result[1] == 3) ||
            (result[0] == 3 && result[1] == 1)
        ) {
            winner = participants[1];
        } else {
            winner = participants[0];
        }
        if (winner == address(msg.sender)) {
            return "You win :)";
        } else {
            return "You loose :(";
        }
    }
}
