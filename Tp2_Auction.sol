// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "hardhat/console.sol";  //https://remix-ide.readthedocs.io/en/latest/hardhat.html

contract Tp2_Auction {

/**** Data  ***/

    address public owner;
    uint256 private init_value;
    uint256 private init_time;
    uint256 public window;
    uint256 public expiration;
    
    enum State{ 
        on,
        off
    }

    State public state;

    struct Person{
        address id;
        uint256 value;
        uint256 balance;
    }

    mapping (address => Person) public infoMapp;   

    struct Person2{
        address id;
        uint256 value;
    }

    Person2[] public infoArray;

    Person2 public winner;


    address payable[] public uniqueArray; // ya payable para enviarles el dinero
    mapping (address => bool) isBidder; // default `false`

/****   Events   *******/

    event NewOffer(address indexed _id, uint256 _value);
    event AuctionEnded(address _id, uint256 _value);

/****   Constructor   *******/

    constructor() {
        owner=msg.sender;
        
        init_time = block.timestamp;
        expiration = init_time + 10 seconds;   // set Auction duration

        window = 10 seconds;  // time window to increase Auction duration
       
        init_value = 100 wei;

        winner.id = owner;
        winner.value = init_value;

        state = State.on; // Auction live
    }


/****   Auxiliaries   *******/

    modifier onlyOwner(){
        require(owner==msg.sender,"not the owner");
        _;
    }

    modifier auctionAlive(){
        require(state == State.on,"auction already ended");
        _;
    }

    modifier auctionEnded(){
        require(state == State.off,"auction still alive");
        _;
    }

    modifier validOffer(){
        if(state == State.on) {
        require((block.timestamp < expiration),"invalid offer time");
        require((msg.value > winner.value * 105 / 100),"invalid offer value");
        _;
        }else {
            revert("Auction Ended");
        }
    }

    function updateWinner (address _id, uint256 _value) private {
        winner.id = _id;
        winner.value = _value;
    }

    function updateInfoMApp (address _id, uint256 _value, uint256 _value2) private {
        // _id = msg.sender
        infoMapp[_id].value = _value;  // msg.value
        infoMapp[_id].balance += _value2;  // msg.value OR deolution
    }

    function updateInfoArray (address _id, uint256 _value) private {
        Person2 memory aux;
        aux.id = _id;
        aux.value = _value;
        infoArray.push(aux);
    }

    function updateExpiration () private {
         if (block.timestamp >= expiration - window) {
            expiration += window; 
        }
        
    }


// https://stackoverflow.com/questions/70907172/how-to-store-unique-value-in-an-array-using-for-loop-in-solidity

    // only add `msg.sender` to `uniqueArray` if it's not there yet
    function addUnique(address _id) private {
        // check against the mapping
        if (isBidder[_id] == false) {
            // push the unique item to the array
            uniqueArray.push(payable(_id));
            // set the mapping value as well
            isBidder[_id] = true;
        }
    }



/****   Make Offers  *******/

    function Offer () external payable validOffer {
        //console.log(msg.sender);
        updateWinner(msg.sender, msg.value);
        updateInfoMApp(msg.sender, msg.value, msg.value);
        updateInfoArray(msg.sender, msg.value);
        updateExpiration();
        emit NewOffer(msg.sender, msg.value);
        addUnique(msg.sender);
      // console.log("NAME: %s; AMMOUNT: %s", OffererInfo[msg.sender].name, OffererInfo[msg.sender].amount); 

      }


/****    Claim $$$    *******/

    function claim() external {


    }

/****   Show Offers  *******/

    function showOffers() external view returns (Person2[] memory) {
        return infoArray;
    }

/****   Show Winner  *******/

    function showWinner() external view returns (Person2 memory) {
        return winner;
    }

/****    End Auction     *******/

    function endAuction() external onlyOwner auctionAlive{
        if (block.timestamp > expiration) {
            state = State.off; // Aucition ended
            emit AuctionEnded(winner.id, winner.value);
        }
    }


/****    Return $$$     *******/

    function transferEther(address payable _to) internal {
            // MSG.SENDER.CALL() - It calls the anonymous fallback function on msg.sender.
            // Las comillas vacías "" es porque no está llamando a ninguna función, por eso cae en fallback.
            // porque hacer un CALL CON PARÁMETROS VACÍO ES COMO HACER UN SEND.
            // puedo ponerle el normbre de una función entre las comillas
            // 2300 límite del gas enviado

        (bool result, ) = _to.call{gas: 2300, value: (infoMapp[_to].balance * 98 / 100)}(""); 

        if( result == false){   // la función no revierte, devuelve True/False, por eso debe chequearse
            revert("fallo el envio");  // yo revierto si falló
        }
    }

    function transferEtherWinner(address payable _to) internal {

        (bool result, ) = _to.call{gas: 2300, value: ( (infoMapp[_to].balance - winner.value) * 98 / 100)}(""); 

        if( result == false){   // la función no revierte, devuelve True/False, por eso debe chequearse
            revert("fallo el envio");  // yo revierto si falló
        }
    }

    function returnOffers() external onlyOwner auctionEnded{

       for (uint i = 0; i < uniqueArray.length; i++) {
            if(uniqueArray[i] != winner.id){
                transferEther(uniqueArray[i]);
            }else{
                transferEtherWinner(uniqueArray[i]);  // 
            }
        }
    }

}
