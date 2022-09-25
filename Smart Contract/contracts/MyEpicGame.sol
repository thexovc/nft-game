// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

error NeedMoreETHSent();

contract MyEpicGame is ERC721 {

  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;        
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

  // The tokenId is the NFTs unique identifier, it's just a number that goes
  // 0, 1, 2, 3, etc.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  CharacterAttributes[] defaultCharacters;

  // We create a mapping from the nft's tokenId => that NFTs attributes.
  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  // Boss structure
  struct BigBoss {
  string name;
  string imageURI;
  uint hp;
  uint maxHp;
  uint attackDamage;
  }
  
  BigBoss public bigBoss;
  
  // A mapping from an address => the NFTs tokenId. Gives me a user way a
  // to store the owner of the NFT and reference it later.
  mapping(address => uint256) public nftHolders;
  uint256 internal immutable i_reviveFee;

  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
  event AttackComplete(address sender, uint newBossHp, uint newPlayerHp);

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    string memory bossName, // These new variables would be passed in via run.js or deploy.js.
    string memory bossImageURI,
    uint bossHp,
    uint bossAttackDamage,
    uint256 reviveFee
  )
    ERC721("Heroes", "HERO")
  {
    // set revive fee
    i_reviveFee = reviveFee;

    bigBoss = BigBoss({
      name: bossName,
      imageURI: bossImageURI,
      hp: bossHp,
      maxHp: bossHp,
      attackDamage: bossAttackDamage
    });

    console.log("Initialized Big BOSS %s with %w HP, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);
    
    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
      
  
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }

    // I increment _tokenIds here so that my first NFT has an ID of 1.

    _tokenIds.increment();
  }

  // Users would be able to hit this function and get their NFT based on the
  // characterId they send in!
  function mintCharacterNFT(uint _characterIndex) external {
    // Get current tokenId (starts at 1 since we incremented in the constructor).
    uint256 newItemId = _tokenIds.current();

    // The magical function! Assigns the tokenId to the caller's wallet address.
    _safeMint(msg.sender, newItemId);

   
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
    
    // Keep an easy way to see who owns what NFT.
    nftHolders[msg.sender] = newItemId;

    // Increment the tokenId for the next person that uses it.
    _tokenIds.increment();

    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
  CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

  string memory strHp = Strings.toString(charAttributes.hp);
  string memory strMaxHp = Strings.toString(charAttributes.maxHp);
  string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

  string memory json = Base64.encode(
    abi.encodePacked(
      '{"name": "',
      charAttributes.name,
      ' -- NFT #: ',
      Strings.toString(_tokenId),
      '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
      charAttributes.imageURI,
        '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
        strAttackDamage,'} ]}'
      )
    );
  
    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );
    
    return output;
  }

  function attackBoss() public {
  // Get the state of the player's NFT.
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
    console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
    console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

    require(
      player.hp > 0,
      "Error: Player must have Hp to attack the boss"
    );

    require(
      bigBoss.hp > 0,
      "Error: Boss must have Hp to attack player"
    );

    // Attack boss.
    if (bigBoss.hp < player.attackDamage) {
      bigBoss.hp = 0;
    } else {
      bigBoss.hp = bigBoss.hp - player.attackDamage;
    }
  
    // Attack player.
    if (player.hp < bigBoss.attackDamage) {
      player.hp = 0;
    } else {
      player.hp = player.hp - bigBoss.attackDamage;
    }

    console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
    console.log("Boss attacked player. New player hp: %s\n", player.hp);

    emit AttackComplete(msg.sender, bigBoss.hp, player.hp);    
  }

  function revivePlayer() public payable{
    if(msg.value < i_reviveFee){
      revert NeedMoreETHSent();
    }

    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

    player.hp = player.maxHp;
  }

  function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
    uint256 userNftTokenId = nftHolders[msg.sender];
   
    if (userNftTokenId > 0) {
      return nftHolderAttributes[userNftTokenId];
    }
    // Else, return an empty character.
    else {
      CharacterAttributes memory emptyStruct;
      return emptyStruct;
     }
  }

  function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
    return defaultCharacters;
  }

  function getBigBoss() public view returns (BigBoss memory) {
    return bigBoss;
  }
  
}