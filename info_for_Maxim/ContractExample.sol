pragma solidity ^0.8.7;
    
    contract CubeMonkeysBusinessCards is ERC721A, Ownable {
    using Strings for uint256;


  string private uriPrefix = "ipfs://QmXLUeRkMWF4ET4R37U9MrBwbNZY8zHiWstAEZrKJMSgCp/" ;
  string private uriSuffix = ".json";
  string public hiddenMetadataUri;

  
  

  uint256 public cost = 0.0 ether;


  uint16 public constant maxSupply = 10000;
 
                                                             
  bool public WLpaused = true;
  bool public paused = true;
  
  mapping (address => uint8) public NFTPerWLAddress;
   mapping (address => uint8) public NFTPerAddress;
  uint8 public maxMintAmountPerWallet = 10; 

  
  bytes32 public whitelistMerkleRoot = "?"; //@dev to finish
  bool public revealed = false;

  constructor() ERC721A("Cube Monkeys Business Cards", "BCCM") {
      setHiddenMetadataUri("ipfs://QmZcbNbT3sC84UK1ddF8mzhWhvdN9Ad7XDKQALjdLgCDNM/hidden.json");
  }

  
 
  function mint(uint8 _mintAmount) external payable  {
     uint16 totalSupply = uint16(totalSupply());
    require(totalSupply + _mintAmount <= maxSupply, "Exceeds max supply.");
    uint8 Nft = NFTPerAddress[msg.sender];
    require(_mintAmount + Nft <= maxMintAmountPerWallet, "Exceeds max Nfts allowed per wallet.");

    require(!paused, "The contract is paused!");

    if(Nft == 0)
    {
    require(msg.value >= cost * (_mintAmount - 1 ), "Insufficient funds!");
    }
    else {
       require(msg.value >= cost * _mintAmount , "Insufficient funds!");
    }
    _safeMint(msg.sender , _mintAmount);
    NFTPerAddress[msg.sender] = _mintAmount + Nft;
     
     delete totalSupply;
     delete _mintAmount;
  }
  
  function Reserve(uint16 _mintAmount, address _receiver) external onlyOwner {
     uint16 totalSupply = uint16(totalSupply());
    require(totalSupply + _mintAmount <= maxSupply, "Excedes max supply.");
     _safeMint(_receiver , _mintAmount);
     delete _mintAmount;
     delete _receiver;
     delete totalSupply;
  }

   
  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if (revealed == false) {
      return hiddenMetadataUri;
    }
  

    

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString() ,uriSuffix))
        : "";
  }

    function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

 
   function setWLPaused() external onlyOwner {
    WLpaused = !WLpaused;
  }



 function setMaxMintAmountPerWallet(uint8 _limit) external onlyOwner{
    maxMintAmountPerWallet = _limit;
   delete _limit;

}
function setWhitelistMerkleRoot(bytes32 _whitelistMerkleRoot) external onlyOwner {
        whitelistMerkleRoot = _whitelistMerkleRoot;
    }

    
    function getLeafNode(address _leaf) internal pure returns (bytes32 temp)
    {
        return keccak256(abi.encodePacked(_leaf));
    }
    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {
        return MerkleProof.verify(proof, whitelistMerkleRoot, leaf);
    }

function whitelistMint(uint8 _mintAmount, bytes32[] calldata merkleProof) external payable {
        
       bytes32  leafnode = getLeafNode(msg.sender);
        uint8 _txPerAddress = NFTPerWLAddress[msg.sender];
       require(_verify(leafnode ,   merkleProof   ),  "Invalid merkle proof");
       require (_txPerAddress + _mintAmount <= maxMintAmountPerWallet, "Exceeds max nft allowed per address");
      
  
    require(!WLpaused, "Whitelist minting is over!");

      if(_txPerAddress >= 2)
    {
    require(msg.value >= cost * _mintAmount, "Insufficient funds!");
    }
    else {
         uint8 costAmount = _mintAmount + _txPerAddress;
        if(costAmount > 2)
       {
        costAmount = costAmount - 2;
        require(msg.value >= cost * costAmount, "Insufficient funds!");
       }
       
         
    }

   
     _safeMint(msg.sender , _mintAmount);
      NFTPerWLAddress[msg.sender] =_txPerAddress + _mintAmount;
     
      delete _mintAmount;
       delete _txPerAddress;
    
    }

  function setUriPrefix(string memory _uriPrefix) external onlyOwner {
    uriPrefix = _uriPrefix;
  }
   


  function setPaused() external onlyOwner {
    paused = !paused;
    WLpaused = true;
  }

  function setCost(uint _cost) external onlyOwner{
      cost = _cost;

  }

   function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
    hiddenMetadataUri = _hiddenMetadataUri;
  }
 

 

  function withdraw() external onlyOwner {
  uint _balance = address(this).balance;
     payable(msg.sender).transfer(_balance ); 
       
  }


  function _baseURI() internal view  override returns (string memory) {
    return uriPrefix;
  }
}