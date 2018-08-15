pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
// import {utils} from "./utils.sol";
import "./Utils.sol";
import "./GuessEvents.sol";


contract GuessEth is Ownable, GuessEvents {
    using SafeMath for uint;

    /* Player guess */
    struct PlyrData {
        address addr; // addr 
        uint price; // price
        uint rID; // 
        uint tID;
        uint pID;
        uint value;
        bool result;
    }

    /* plyr address => plyr ID */
    mapping(address => uint) public plyrIDs;
    /* rndID => PlyrData */
    mapping(uint => PlyrData[]) public rndPlyrs;
    mapping(uint => address) public betNumber;

    uint private unitPrice = 1 finney; // 0.001 ether
    address[] private plyrs;
    
    /* Awards Records */
    struct Winner {
        bool result;
        uint price;
    }
    
    /* rndID => winner */
    mapping(uint => Winner) private winners;
    mapping(uint => uint) private winResult;
    
    address private wallet1;
    address private wallet2;
   
    /**
    * @dev prevents contracts from interacting with fomo3d
    */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
    
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    
    // constructor (address _wallet1, address _wallet2) public {
    //     wallet1 = _wallet1;
    //     wallet2 = _wallet2;

    //    // 
    //     uint id = plyrs.push(msg.sender) - 1;
    //     plyrIDs[msg.sender] = id;
    // }

    function getPlyrID() public payable isHuman() returns (uint) {
        // new player
        if (plyrIDs[msg.sender] == 0 && plyrs[0] != msg.sender) {
            uint id = plyrs.push(msg.sender) - 1;
            plyrIDs[msg.sender] = id;
        }
        return(plyrIDs[msg.sender]);
    }
    
    /**
    @dev dapp initialize runtime params when launch
    _unitPrice, _multProduct, 
     */
    function getRunParam() public view returns (uint _unitPrice) {
        return(unitPrice);
    }

    /**
    @dev guess entry
    @param _price price of guess
    @param _rID round id
    @param _tID team id
     */
    function guess(uint _price, uint _rID, uint _tID) public payable isHuman() returns(uint) {
       
        uint pID = getPlyrID();
        // for {}
        // require(rndPlyrs[_rID][pID] == 0);

        // save to rnd plyr' list
        PlyrData memory b;
            
        b.addr = msg.sender;
        b.price = _price;
        b.rID = _rID;
        b.tID = _tID;
        b.value = msg.value;
        // b.result = 0;
    
        rndPlyrs[_rID].push(b);
        
        emit GuessEvt(msg.sender, _price, _rID, _tID, msg.value);

        return pID;
    }
    
    function getPlayerGuessPrices(uint _rID) public view returns (address[], uint[], uint[], uint[], bool[]) {
        uint _c = rndPlyrs[_rID].length;
        uint _i=0;

        uint limitRows=100;

        address[] memory _addrs = new address[](_c);
        uint[] memory _prices = new uint[](_c);
        uint[] memory _tIDs = new uint[](_c);
        uint[] memory _pIDs=new uint[](_c);
        bool[] memory _res=new bool[](_c);
        
        if (_c <= 0) {
            return(_addrs, _prices, _tIDs, _pIDs, _res);
        }

        for (_i = 0; _i < rndPlyrs[_rID].length && _i < limitRows; _i++) {
            _addrs[_i] = rndPlyrs[_rID][_i].addr;
            _prices[_i] = rndPlyrs[_rID][_i].price;
            _tIDs[_i] = rndPlyrs[_rID][_i].tID;
            _pIDs[_i] = rndPlyrs[_rID][_i].pID;
            _res[_i] = rndPlyrs[_rID][_i].result;
        }

        return(_addrs, _prices, _tIDs, _pIDs, _res);
    }

    // function draw(uint _blockNumber,uint _blockTimestamp) public onlyOwner returns (uint) {
    //     require(block.number >= curOpenBNumber + blockInterval);

    //     /*Set open Result*/
    //     curOpenBNumber=_blockNumber;
    //     uint result=_blockTimestamp % numberRange;
    //     winResult[_blockNumber]=result;

    //     for(uint _i=0;_i < bets[_blockNumber].length;_i++){
    //         //result+=1;
            
            
    //         if(bets[_blockNumber][_i].number==result){
    //             bets[_blockNumber][_i].result = 1;
    //             bets[_blockNumber][_i].price = bets[_blockNumber][_i].value * odds;
                
    //             emit winnersEvt(_blockNumber,bets[_blockNumber][_i].addr,bets[_blockNumber][_i].value,bets[_blockNumber][_i].price);

    //             withdraw(bets[_blockNumber][_i].addr,bets[_blockNumber][_i].price);

    //         }else{
    //             bets[_blockNumber][_i].result = 0;
    //             bets[_blockNumber][_i].price = 0;
    //         }
    //     }
        
    //     emit drawEvt(_blockNumber, curOpenBNumber);
        
    //     return result;
    // }
    
    // function getWinners(uint _rID) public view returns(address, uint, uint){
    //     uint _count=winners[_blockNumber].length;
        
    //     address[] memory _addresses = new address[](_count);
    //     uint[] memory _price = new uint[](_count);
        
    //     uint _i=0;
    //     for(_i=0;_i<_count;_i++){
    //         //_addresses[_i] = winners[_blockNumber][_i].addr;
    //         _price[_i] = winners[_blockNumber][_i].price;
    //     }

    //     return (_addresses, _price);
    // }

    function getWinResults(uint _blockNumber) view public returns(uint){
        return winResult[_blockNumber];
    }
    
    function withdraw(address _to, uint amount) public onlyOwner returns(bool) {
        require(address(this).balance.sub(amount) > 0);
        _to.transfer(amount);
        
        emit WithdrawEvt(_to, amount);
        return true;
    }

    function() public payable isHuman() {

    }
}