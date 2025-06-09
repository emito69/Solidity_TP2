// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

//@notice: Auction contract managing bids and payouts
//@dev: Implements a time-limited auction with automatic extension window
contract Tp2_Auction {

/**** Data / Variables ***/

    //@notice: Contract owner address
    address private owner;
    //@notice: Initial minimum bid value
    uint256 private init_value;
    //@notice: Auction start timestamp
    uint256 private init_time;
    //@notice: Time window for automatic auction extension
    uint256 private window;
    //@notice: Auction expiration timestamp
    uint256 public expiration;
    //@notice: Auction state enum (on/off)
    enum State{ 
        on,
        off
    }
    //@notice: Current auction state
    State public state;

    //@notice: Bidder information structure
    //@dev: Tracks last valid offer and total balance per bidder
    struct Person{
        address id;
        uint256 value;    // will save the last valid offer for each person
        uint256 balance;  // will save the balance for each person (including offers, claims, returns)
    }

    //@notice: Mapping of bidders to their information
    mapping (address => Person) private infoMapp;   

    //@notice: Simplified bidder structure for transaction history
    struct Person2{
        address id;
        uint256 value;  
    }

    //@notice: Array recording all auction movements
    Person2[] private infoArray; // will record all movements (offers, claims, returns)

    //@notice: Current winning bid information
    Person2 private winner;  // will record id and value of the current best offer

    //@notice: Array of unique bidder addresses
    address payable[] private uniqueArray; // created as payables in order to use them to send money later

    //@notice: Mapping to check if address is a bidder
    mapping (address => bool) isBidder; // default `false`


/****   Events   *******/

    //@notice: Emitted when a new bid is placed
    //@dev: Includes bidder address and bid amount
    //@params: _id - Bidder address, _value - Bid amount
    event NewOffer(address indexed _id, uint256 _value);

    //@notice: Emitted when auction concludes
    //@dev: Includes winner address and winning amount
    //@params: _id - Winner address, _value - Winning amount
    event AuctionEnded(address _id, uint256 _value);

    //@notice: Emitted when a bidder mrequest a PartialClaim
    //@dev: Includes bidder address and the returned amount
    //@params: _id - Bidder address, _value - Returned amount
    event PartialClaim(address indexed _id, uint256 _value);

    //@notice: Emitted when the Auction has Ended and the Owner makes a Return for all the Participants
    //@dev: Includes participant address and the returned amount
    //@params: _id - Bidder address, _value - Returned amount
    event ReturnedAmount(address indexed _id, uint256 _value);


/****   Constructor   *******/

    //@notice: Initializes auction contract
    //@dev: Sets owner, initial values and auction duration
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

    //@notice: Restricts access to contract owner
    //@dev: Reverts if caller is not the owner
    modifier onlyOwner(){
        require(owner==msg.sender, "not the owner");
        _;
    }

    //@notice: Verifies caller is registered bidder
    //@dev: Reverts if caller hasn't placed any bids
    modifier isBidderM(){
        require(isBidder[msg.sender] == true,"not a bidder");
        _;
    }

    //@notice: Verifies auction is active
    //@dev: Reverts if auction has ended
    modifier auctionAlive(){
        require(state == State.on,"auction already ended");
        _;
    }

    //@notice: Verifies auction has ended
    //@dev: Reverts if auction is still active
    modifier auctionEnded(){
        require(state == State.off,"auction still alive");
        _;
    }

    //@notice: Validates bid conditions
    //@dev: Checks timing and requires 5% increase over current best
    modifier validOffer(){
        if(state == State.on) {
        require((block.timestamp < expiration),"invalid offer time");
        require((msg.value >= winner.value * 105 / 100),"invalid offer value");
        _;
        }else {
            revert("Auction Ended");
        }
    }

    //@notice: Updates current winner information
    //@dev: Modifies winner struct with new values
    //@params: _id - New winner address, _value - New winning amount
    function updateWinner (address _id, uint256 _value) private {
        winner.id = _id;
        winner.value = _value;
    }

    //@notice: Updates bidder information in mapping
    //@dev: Sets last bid value and adds to balance
    //@params: _id - Bidder address, _value - New bid amount, _value2 - Amount to add to balance
    function updateInfoMApp (address _id, uint256 _value, uint256 _value2) private {
        // _id = msg.sender
        infoMapp[_id].value = _value;  // msg.value
        infoMapp[_id].balance += _value2;  // msg.value OR deolution
    }

    //@notice: Records transaction in history array
    //@dev: Creates new entry in movement history
    //@params: _id - Participant address, _value - Transaction amount
    function updateInfoArray (address _id, uint256 _value) private {
        Person2 memory aux;
        aux.id = _id;
        aux.value = _value;
        infoArray.push(aux);
    }

    //@notice: Extends auction if near expiration
    //@dev: Adds window time if called during extension period
    function updateExpiration () private {
         if (block.timestamp >= expiration - window) {
            expiration += window; 
        }
        
    }

    //@notice: Sends ether to specified address 
    //@dev: Transfers 98% of balance with 2300 gas limit
    //@params: _to - Recipient address
    //@returns: result - Transfer success, aux_val1 - Original amount
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

    //@notice: Sends ether to winner (excluding winning bid)
    //@dev: Similar to returnEther but deducts winning amount
    //@params: _to - Winner address
    //@returns: result - Transfer success, aux_val1 - Original amount
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

    //@notice: Sends claimable ether to participant
    //@dev: Calculates difference between balance and last bid
    //@params: _to - Claimant address
    //@returns: result - Transfer success, aux_val1 - Claimed amount
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

    //@notice: Adds new unique bidder to registry
    //@dev: Checks mapping to prevent duplicates
    //@params: _id - Bidder address to add    
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
/********    CONTRACTs EXTERNAL FUNCTIONS    *******/


/****   Make Offers  *******/

    //@notice: Places new bid in auction
    //@dev: Requires valid offer amount and updates all records
    function Offer () external payable validOffer {
        
        updateWinner(msg.sender, msg.value);
        updateInfoMApp(msg.sender, msg.value, msg.value);
        updateInfoArray(msg.sender, msg.value);
        updateExpiration();  // expiration + window (if offer called during extension period window)
        emit NewOffer(msg.sender, msg.value);
        addUnique(msg.sender);
      
    }

/****   Show Offers  *******/

    //@notice: Returns all auction movements
    //@dev: Provides complete transaction history
    //@returns: Array of Person2 structs with all bids
    function showOffers() external view returns (Person2[] memory) {
        return infoArray;
    }

/****   Show Winner  *******/

    //@notice: Shows current winning bid
    //@dev: Returns winner information
    //@returns: Person2 struct with winner data
    function showWinner() external view returns (Person2 memory) {
        return winner;
    }

/****    Partial Claim $$$    *******/

    //@notice: Allows bidder to claim funds OVER HIS LAST VALID OFFER
    //@dev: Only available during active auction for registered bidders
    function partialClaim() external auctionAlive isBidderM {

        bool result;
        uint256 aux_val;

        (result, aux_val) = returnClaimedEthers(payable (msg.sender));
        
        if( result == false){   
            revert("transaction fail");  

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
            emit PartialClaim(msg.sender, aux_val);  
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

    //@notice: Ends auction if expiration time reached
    //@dev: Only callable by owner during active auction
    function endAuction() external onlyOwner auctionAlive{
        if (block.timestamp > expiration) {
            state = State.off; // Aucition ended
            emit AuctionEnded(winner.id, winner.value);
        } else {
            revert("not expired yet");
        }
    }


/****    Return $$$     *******/

    //@notice: Returns funds to all participants after auction
    //@dev: Handles winner separately from other bidders    
    function returnOffers() external onlyOwner auctionEnded{

        bool result;
        uint256 aux_val;

       for (uint i = 0; i < uniqueArray.length; i++) {
            if(uniqueArray[i] != winner.id){

                (result, aux_val) = returnEther(uniqueArray[i]);
                
                if( result == false){   
                    revert("transaction fail");  
                } else {
                    // update infoMapp:
                    //infoMapp[uniqueArray[i]].value = 0;  // I don't update this value because it's the last valid bid
                    infoMapp[uniqueArray[i]].balance -= aux_val;  

                    // update infoArray
                    Person2 memory aux;
                    aux.id = uniqueArray[i];
                    aux.value = 0; 
                    infoArray.push(aux);
                    emit ReturnedAmount(aux.id, aux_val);  
                }

            } else {

                (result, aux_val) = returnEtherWinner(uniqueArray[i]); 

                if( result == false){   
                    revert("transaction fail");  
                } else {
                    // updat infoMapp:
                    //infoMapp[uniqueArray[i]].value = 0;    
                    infoMapp[uniqueArray[i]].balance -= aux_val;  

                    // updat infoArray
                    Person2 memory aux;
                    aux.id = uniqueArray[i];
                    aux.value = 0; 
                    infoArray.push(aux);
                    emit ReturnedAmount(aux.id, aux_val);  
                }
            }
        }
    }


/****    OWNER CLAIM HIS MONEY  $$$     *******/

    //@notice: Allows owner to withdraw contract balance
    //@dev: Only callable after auction ends
    function ownerClaim() external onlyOwner auctionEnded{

        (bool result, ) = owner.call{gas: 2300, value:address(this).balance}(""); 

        if( result == false){   
            revert("transaction fail");  
        } 
    }

}
