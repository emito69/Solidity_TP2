// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "hardhat/console.sol";  //https://remix-ide.readthedocs.io/en/latest/hardhat.html

contract Tp2_Auction {

/// @notice 
/// @dev
/// @params


/**** Data  ***/

    address private owner;
    uint256 private init_value;
    uint256 private init_time;
    uint256 private window;
    uint256 public expiration;
    
    enum State{ 
        on,
        off
    }

    State public state;

    struct Person{
        address id;
        uint256 value;    // will save the last valid offer for each person
        uint256 balance;  // will save the balance for each person (including offers, claimsclaims)
    }

    mapping (address => Person) public infoMapp;   

    struct Person2{
        address id;
        uint256 value;  
    }

    Person2[] public infoArray;

    Person2 public winner;

    address payable[] public uniqueArray; // created as payables in order to use them to send money later
    mapping (address => bool) isBidder; // default `false`


/****   Events   *******/

    event NewOffer(address indexed _id, uint256 _value);
    event AuctionEnded(address _id, uint256 _value);


/****   Constructor   *******/

    constructor() {
        owner=msg.sender;
        
        init_time = block.timestamp;
        expiration = init_time + 1 weeks;   // set Auction duration

        window = 10 minutes;  // time window to increase Auction duration
       
        init_value = 1000000 wei;  // set Base Offer $$$

        winner.id = owner;
        winner.value = init_value;

        state = State.on; // Auction live
    }


/****   Auxiliaries   *******/

    modifier onlyOwner(){
        require(owner==msg.sender,"not the owner");
        _;
    }

    modifier isBidderM(){
        require(isBidder[msg.sender] == true,"not a bidder");
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


    function returnEther(address payable _to) internal returns (bool, uint256) {
            // MSG.SENDER.CALL() - It calls the anonymous fallback function on msg.sender.
            // The empty quotes "" mean it's not calling any function, which is why it falls back to the fallback.
            // Because making a call with empty parameters is like doing a SEND.
            // I can put a function name inside the quotes
            // 2300 gas limit sent

        uint256 aux_val1 = (infoMapp[_to].balance);
        uint256 aux_val2 = (aux_val1 * 98 / 100);

        (bool result, ) = _to.call{gas: 2300, value:aux_val2}(""); 

        if( result == false){   // The function does not revert; it returns True/False, so the return value must be checked
            aux_val1 = 0;
            return (result, aux_val1);  //  revert if failed
        } else {
            return (result, aux_val1);
        }
    }


    function returnEtherWinner(address payable _to) internal returns (bool, uint256) {

        uint256 aux_val1 = (infoMapp[_to].balance - winner.value);
        uint256 aux_val2 = (aux_val1 * 98 / 100);

        (bool result, ) = _to.call{gas: 2300, value:aux_val2}(""); 

        if( result == false){   
            aux_val1 = 0;
            return (result, aux_val1);
        } else {
            return (result, aux_val1);
        }
    }


    function returnClaimedEthers(address payable _to) internal returns (bool, uint256) {

        if (infoMapp[_to].balance > infoMapp[_to].value) { // value in the mapp is the last valid offer 
           
            uint256 aux_val1 = (infoMapp[_to].balance - infoMapp[_to].value); // value in the mapp is the last valid offer 
            uint256 aux_val2 = (aux_val1 * 98 / 100);

            (bool result, ) = _to.call{gas: 2300, value:aux_val2}(""); 

            if( result == false){   
                aux_val1 = 0;
                return (result, aux_val1);
            } else {
                return (result, aux_val1);
            }

        } else {

            return (true, 0);  // 
        }
    }

    
    function addUnique(address _id) private {   // only add `msg.sender` to `uniqueArray` if it's not there yet
        // check against the mapping
        if (isBidder[_id] == false) {
            // push the unique item to the array
            uniqueArray.push(payable(_id)); 
            // set the mapping value as well (because by default is created as`false`)
            isBidder[_id] = true;
        }
    }

/********  ********************************  *******/
/********  FUNCIONES EXTERNAL DEL CONTRATO  *******/


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

/****   Show Offers  *******/

    function showOffers() external view returns (Person2[] memory) {
        return infoArray;
    }

/****   Show Winner  *******/

    function showWinner() external view returns (Person2 memory) {
        return winner;
    }

/****    Claim $$$    *******/

    function claim() external auctionAlive isBidderM {

        bool result;
        uint256 aux_val;

        (result, aux_val) = returnClaimedEthers(payable (msg.sender));
        
        if( result == false){   
            revert("fallo el envio");  

        } else {
            // update infoMapp:
            //infoMapp[uniqueArray[i]].value = 0;  // I don't update this value because it's the last valid bid
            infoMapp[msg.sender].balance -= aux_val;  

            // update infoArray
            Person2 memory aux;
            aux.id = msg.sender;
            aux.value = 0; // I would have to show a debit as a negative number, 
                            // but that would require changing from uint to int, which creates me other issues -
                            // im using 0 just as a reference in my movements record
            infoArray.push(aux);
        }

    }

    /*** (DELETED AND CHANGED FOR INDIVIDUAL CLAIMs)
    function claimForEverybody() external auctionAlive{

     bool result;
     uint256 aux_val;

       for (uint i = 0; i < uniqueArray.length; i++) {
    
            (result, aux_val) = returnClaimedEthers(uniqueArray[i]);
            
            if( result == false){   
                revert("fallo el envio");  // 
            } else {
                // update infoMapp:
                //infoMapp[uniqueArray[i]].value = 0;  
                infoMapp[uniqueArray[i]].balance -= aux_val;  

                // update infoArray
                Person2 memory aux;
                aux.id = uniqueArray[i];
                aux.value = 0; 
                infoArray.push(aux);
            }
        }
    }
    /*** *************************** ***** */


/****    End Auction     *******/

    function endAuction() external onlyOwner auctionAlive{
        if (block.timestamp > expiration) {
            state = State.off; // Aucition ended
            emit AuctionEnded(winner.id, winner.value);
        }
    }


/****    Return $$$     *******/
    
    function returnOffers() external onlyOwner auctionEnded{

        bool result;
        uint256 aux_val;

       for (uint i = 0; i < uniqueArray.length; i++) {
            if(uniqueArray[i] != winner.id){

                (result, aux_val) = returnEther(uniqueArray[i]);
                
                if( result == false){   
                    revert("fallo el envio");  
                } else {
                    // update infoMapp:
                    //infoMapp[uniqueArray[i]].value = 0;  // I don't update this value because it's the last valid bid
                    infoMapp[uniqueArray[i]].balance -= aux_val;  

                    // update infoArray
                    Person2 memory aux;
                    aux.id = uniqueArray[i];
                    aux.value = 0; 
                    infoArray.push(aux);
                }

            } else {

                (result, aux_val) = returnEtherWinner(uniqueArray[i]); 

                if( result == false){   
                    revert("fallo el envio");  
                } else {
                    // updat infoMapp:
                    //infoMapp[uniqueArray[i]].value = 0;    
                    infoMapp[uniqueArray[i]].balance -= aux_val;  

                    // updat infoArray
                    Person2 memory aux;
                    aux.id = uniqueArray[i];
                    aux.value = 0; 
                    infoArray.push(aux);
                }
            }
        }
    }


/****    OWNER CLAIM HIS MONEY  $$$     *******/
    
    function ownerClaim() external onlyOwner auctionEnded{

        (bool result, ) = owner.call{gas: 2300, value:address(this).balance}(""); 

        if( result == false){   
            revert("fallo el envio");  
        } 
    }

}
