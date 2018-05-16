pragma solidity ^0.4.21;


import "./owned.sol";
import "./FixedSupplyToken.sol";


contract Exchange is owned {

    ///////////////////////
    // GENERAL STRUCTURE //
    ///////////////////////
    struct Offer {
        
        uint amount;
        uint who;
    }

    struct OrderBook {
        uint higherPrice;
        uint lowerPrice;
        
        mapping(uint => Offer) offers;
        
        uint offers_key;
        uint offers_length;
    }

    struct Token {
        address tokenContract;
        string symbolName;
        
        mapping(uint => OrderBook) buyBook;
        uint curBuyPrice;
        uint lowestBuyPrice;
        uint amountBuyPrices;
        
        mapping(uint => OrderBook) sellBook;
        uint curSellPrice;
        uint highestSellPrice;
        uint amountSellPrices;
    }


    //we support a max of 255 tokens...
    mapping (uint8 => Token) tokens;
    uint8 symbolNameIndex;


    //////////////
    // BALANCES //
    //////////////
    mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;

    mapping (address => uint) balanceEthForAddress;




    ////////////
    // EVENTS //
    ////////////




    //////////////////////////////////
    // DEPOSIT AND WITHDRAWAL ETHER //
    //////////////////////////////////
    function depositEther() external payable {
        require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] += msg.value;
    }

    function withdrawEther(uint amountInWei) external {
        require(balanceEthForAddress[msg.sender] - amountInWei >= 0);
        require(balanceEthForAddress[msg.sender] - amountInWei <= balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] -= amountInWei;
        msg.sender.transfer(amountInWei);
    }

    function getEthBalanceInWei() public view returns (uint){
        return balanceEthForAddress[msg.sender];
    }


    //////////////////////
    // TOKEN MANAGEMENT //
    //////////////////////

    function addToken(string symbolName, address erc20TokenAddress) public onlyowner {
        if(!hasToken(symbolName)) {
            symbolNameIndex++;
            tokens[symbolNameIndex].symbolName = symbolName;
            tokens[symbolNameIndex].tokenContract = erc20TokenAddress;
        } else {
            revert("Token already exists");
        }
    }

    function hasToken(string symbolName) view public returns (bool) {
        uint8 index = getSymbolIndex(symbolName);
        if(index == 0) {
            return false;
        } else {
            return true;
        }
    }


    function getSymbolIndex(string symbolName) internal view returns (uint8) {
        for(uint8 i = 1; i<=symbolNameIndex; i++) {
            if(stringsEqual(tokens[i].symbolName, symbolName)) {
                return i;
            }
        }
        return 0;
    }

    function getSymbolIndexOrThrow(string symbolName) private view returns (uint8) {
        require(hasToken(symbolName));
        uint8 index = getSymbolIndex(symbolName);
        require(index > 0);
        return index;
    }


    /////////////////////////////////
    // STRING COMPARISON FUNCTION  //
    /////////////////////////////////
    function stringsEqual(string storage _a, string memory _b) internal view returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);
        if (a.length != b.length) {
            return false;
        }
        for (uint i = 0; i<a.length; i++) {
            if(a[i] != b[i]) {
                return false;
            }else {
                return true;
            }
        }
    }


    //////////////////////////////////
    // DEPOSIT AND WITHDRAWAL TOKEN //
    //////////////////////////////////
    function depositToken(string symbolName, uint amount) public {
        symbolNameIndex = getSymbolIndexOrThrow(symbolName);
        require(tokens[symbolNameIndex].tokenContract != address(0));

        ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);

        require(token.transferFrom(msg.sender, address(this), amount) == true);
        require(tokenBalanceForAddress[msg.sender][symbolNameIndex] + amount >= tokenBalanceForAddress[msg.sender][symbolNameIndex]);
        tokenBalanceForAddress[msg.sender][symbolNameIndex] += amount;
    }

    function withdrawToken(string symbolName, uint amount) public {
        symbolNameIndex = getSymbolIndexOrThrow(symbolName);
        require(tokens[symbolNameIndex].tokenContract != address(0));

        ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);

        require(tokenBalanceForAddress[msg.sender][symbolNameIndex] - amount >= 0);
        require(tokenBalanceForAddress[msg.sender][symbolNameIndex] - amount <= tokenBalanceForAddress[msg.sender][symbolNameIndex]);

        tokenBalanceForAddress[msg.sender][symbolNameIndex] -= amount;
        require(token.transfer(msg.sender, amount) == true);
    }

    function getBalance(string symbolName) view public returns (uint) {
        return tokenBalanceForAddress[msg.sender][getSymbolIndexOrThrow(symbolName)];
    }




    /////////////////////////////
    // ORDER BOOK - BID ORDERS //
    /////////////////////////////
    function getBuyOrderBook(string symbolName) constant returns (uint[], uint[]) {
    }


    /////////////////////////////
    // ORDER BOOK - ASK ORDERS //
    /////////////////////////////
    function getSellOrderBook(string symbolName) constant returns (uint[], uint[]) {
    }



    ////////////////////////////
    // NEW ORDER - BID ORDER //
    ///////////////////////////
    function buyToken(string symbolName, uint priceInWei, uint amount) {
    }





    ////////////////////////////
    // NEW ORDER - ASK ORDER //
    ///////////////////////////
    function sellToken(string symbolName, uint priceInWei, uint amount) {
    }



    //////////////////////////////
    // CANCEL LIMIT ORDER LOGIC //
    //////////////////////////////
    function cancelOrder(string symbolName, bool isSellOrder, uint priceInWei, uint offerKey) {
    }



}