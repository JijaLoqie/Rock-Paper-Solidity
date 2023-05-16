const { ethers } = require("hardhat");

const { expect } = require("chai");

describe("RockPaperGame", function () {
	let acc1, acc2, owner;
	let rockPaperGame;
	beforeEach(async function() {
		this.timeout(5000);
		[acc1, acc2, owner] = await ethers.getSigners();
		let RockPaperGame = await ethers.getContractFactory("RockPaperGame", owner);

		rockPaperGame = await RockPaperGame.deploy();
		await rockPaperGame.deployed();
	})

  it("Should be deployed", async function () {
	expect(rockPaperGame.address).to.be.properAddress;
  });

  it("Correct getParticipants", async function () {
	await rockPaperGame.connect(acc1).callCommitMove(1, 1);
	await rockPaperGame.connect(acc2).callCommitMove(2, 2);
	const addresses = await rockPaperGame.getParticipants();
	expect(addresses).to.deep.equal([acc1.address, acc2.address]);
  });

  it("Correct commitMove", async function () {
	await rockPaperGame.connect(acc1).callCommitMove(1, 1);
	const addresses = await rockPaperGame.getParticipants();
	expect(addresses.length).to.equal(1);


	await expect(
		rockPaperGame.connect(acc1).callCommitMove(1, 1)
	).to.be.revertedWith("Move is already commited!");
	});

  it("Correct revealMove", async function () {
	await rockPaperGame.connect(acc2).callCommitMove(2, 2);
	await rockPaperGame.connect(acc1).callCommitMove(1, 1);
	await rockPaperGame.stopGame();
	await rockPaperGame.connect(acc2).revealMove(2, 2);
	await rockPaperGame.connect(acc1).revealMove(1, 1);

	const result = await rockPaperGame.getResult();

	expect(result).to.deep.equal([2,1]);
  });

  it("Correct stopGame", async function () {
	await rockPaperGame.connect(acc2).callCommitMove(2, 2);
	await expect(
		rockPaperGame.stopGame()
	).to.be.revertedWith("Not enough participants! Need 2");
	

	await rockPaperGame.connect(acc1).callCommitMove(1, 1);

	await expect(
		rockPaperGame.connect(acc1).revealMove(1, 1)
	).to.be.revertedWith("Wait for game stop!!");
	await rockPaperGame.stopGame();

	await expect(
		rockPaperGame.stopGame()
	).to.be.revertedWith("Game is stopped!");

	await rockPaperGame.connect(acc2).revealMove(2, 2);
	await rockPaperGame.connect(acc1).revealMove(1, 1);
  });

  it("Correct getResult", async function () {
	await rockPaperGame.connect(acc1).callCommitMove(1, 1);
	await rockPaperGame.connect(acc2).callCommitMove(2, 2);
	await expect(
		rockPaperGame.getResult()
	).to.be.revertedWith("Wait for game stop!!");

	await rockPaperGame.stopGame();
	await expect(
		rockPaperGame.getResult()
	).to.be.revertedWith("1-st player should reveal!");
	await rockPaperGame.connect(acc1).revealMove(1, 1);
	
	await expect(
		rockPaperGame.getResult()
	).to.be.revertedWith("2-st player should reveal!");

	await rockPaperGame.connect(acc2).revealMove(2, 2);

	const result = await rockPaperGame.getResult();
	expect(result).to.deep.equal([1,2]);
  });
});