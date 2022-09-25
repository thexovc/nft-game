const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
  const gameContract = await gameContractFactory.deploy(
    ["Luffytaro", "Zorotaro", "Choppero", "Aangaro"],       // Names
    ["https://cdn.pixabay.com/photo/2020/04/25/09/52/onepiece-5090120__340.jpg", // Images
      "https://cdn.pixabay.com/photo/2019/01/31/19/30/toy-3967772_960_720.jpg",
      "https://cdn.pixabay.com/photo/2019/06/16/13/50/chopper-car-display-4277816__340.jpg",
      "https://i.imgur.com/xVu4vFL.png",],
    [400, 300, 250, 200],                    // HP values
    [100, 65, 50, 40],                       // Attack damage values
    "Dwayne Douglas Johnson", //Boss name
    "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg/330px-Dwayne_Johnson_2014_%28cropped%29.jpg", // Boss image
    1500, // Boss hp
    50, // Boss attack damage
    100000000000000 // revive Fee
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  // Get the value of the NFT's URI.
  let returnedTokenUri = await gameContract.tokenURI(1);
  // console.log("Token URI:", returnedTokenUri);

};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();