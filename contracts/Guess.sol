pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
// import {utils} from "./utils.sol";
import "./Utils.sol";
import "./GuessEvents.sol";

contract Guess is Ownable, GuessEvents {
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

    struct PrdctData {
        uint price;
        uint maxPlyr;
        uint percent;
        string name;
        string nameEn;
        string disc;
        string discEn;
        bool isOver;
        uint winPrice;
        uint winPlyr;
        uint winTeam;
        address winAddr;
    }

    /* plyr address => plyr ID */
    mapping(address => uint) public plyrIDs;
    /* product ID => PlyrData */
    mapping(uint => PlyrData[]) public prdctPlyrs;

    uint private modulus = 10 ** 4;
    uint private unitPrice = 1 finney; // 0.001 ether
    uint private nonce= 0;
    address[] private plyrs;
    PrdctData[] private products;

    /* Awards Records */
    struct Winner {
        uint price;
        uint winPrice;
        uint pID;
        uint tID;
        address addr;
    }

    /* rID => winner */
    mapping(uint => Winner) private winners;

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

    constructor () public {
        uint id = plyrs.push(msg.sender) - 1;
        plyrIDs[msg.sender] = id;
    }

    function getPlyrID() public view isHuman() returns (uint) {
        // new player
        return(plyrIDs[msg.sender]);
    }

    function canJoin(uint _rID) public view isHuman() returns (bool) {
        for (uint i = 0; i < prdctPlyrs[_rID].length; i++) {
            if (prdctPlyrs[_rID][i].addr == msg.sender) {
                return true;
            }
        }

        return false;
    }
    /**
    @dev dapp initialize runtime params when launch
    _unitPrice, _multProduct,
     */
    function getRunParam() public view returns (uint _unitPrice) {
        return(unitPrice);
    }

    /**
    @dev create new product and launch new guess
    @param _price price of market selling
    @param _name  title for product
    @param _nameEn title in english
    */
    function createProduct(uint _price, uint _maxPlyr, uint _percent, string _name, string _nameEn, string _disc, string _discEn) public  isHuman() returns(uint) {
        uint id = products.push(PrdctData(_price, _maxPlyr, _percent, _name, _nameEn, _disc, _discEn, false, 0, 0, 0, address(0))) - 1;

        emit NewPrdctEvt(id, _price, _maxPlyr, _name, _nameEn, _disc, _discEn);
        return id;
    }

    /**
    @dev guess entry
    @param _price price of guess
    @param _rID round id
    @param _tID team id
     */
    function guess(uint _price, uint _rID, uint _tID) public payable isHuman() returns(uint) {

        uint pID = getPlyrID();

        if (pID == 0 && plyrs[0] != msg.sender) {
            pID = plyrs.push(msg.sender) - 1;
            plyrIDs[msg.sender] = pID;
        }

        require(msg.value >= unitPrice);
        require(_price <= products[_rID].price);
        require(canJoin(_rID));

        // save to rnd plyr' list
        PlyrData memory b;

        b.addr = msg.sender;
        b.price = _price;
        b.rID = _rID;
        b.tID = _tID;
        b.value = msg.value;
        // b.result = 0;

        prdctPlyrs[_rID].push(b);

        emit GuessEvt(msg.sender, _price, _rID, _tID, msg.value);

        if (products[_rID].maxPlyr == prdctPlyrs[_rID].length) {
            endGuess(_rID);
        }

        return pID;
    }

    function getPlayerGuessPrices(uint _rID) public view returns (address[], uint[], uint[], uint[], bool[]) {
        uint _c = prdctPlyrs[_rID].length;
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

        for (_i = 0; _i < prdctPlyrs[_rID].length && _i < limitRows; _i++) {
            _addrs[_i] = prdctPlyrs[_rID][_i].addr;
            _prices[_i] = prdctPlyrs[_rID][_i].price;
            _tIDs[_i] = prdctPlyrs[_rID][_i].tID;
            _pIDs[_i] = prdctPlyrs[_rID][_i].pID;
            _res[_i] = prdctPlyrs[_rID][_i].result;
        }

        return(_addrs, _prices, _tIDs, _pIDs, _res);
    }

    function endGuess(uint _rID) public onlyOwner {
        require(products[_rID].maxPlyr <= prdctPlyrs[_rID].length);
        nonce++;
        uint rand = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) % modulus;
        uint winPrice = products[_rID].price.mul(rand).div(modulus);

        uint minValue = products[_rID].price;
        uint winIdx;
        uint tmpValue;

        for(uint _i=0; _i < prdctPlyrs[_rID].length; _i++) {
            if (winPrice >= prdctPlyrs[_rID][_i].price) {
                tmpValue = winPrice.sub(prdctPlyrs[_rID][_i].price);
            }else {
                tmpValue = prdctPlyrs[_rID][_i].price.sub(winPrice);
            }

            if (minValue > tmpValue) {
                minValue = tmpValue;
                winIdx = _i;
            }
        }

        prdctPlyrs[_rID][winIdx].result = true;

        products[_rID].winPrice = minValue;
        products[_rID].winPlyr = prdctPlyrs[_rID][winIdx].pID;
        products[_rID].winAddr = prdctPlyrs[_rID][winIdx].addr;
        products[_rID].winTeam = prdctPlyrs[_rID][winIdx].tID;

        winners[_rID] = Winner(products[_rID].price,
                            products[_rID].winPrice,
                            products[_rID].winPlyr,
                            products[_rID].winTeam,
                            products[_rID].winAddr);

        emit EndGuessEvt(_rID, minValue, products[_rID].winPlyr, products[_rID].winTeam, products[_rID].winAddr, now);
    }

    function getWinResult(uint _rID) public view returns (
        uint price,
        uint winPrice,
        uint pID,
        uint tID,
        address addr)
    {
        return (winners[_rID].price, winners[_rID].winPrice, winners[_rID].pID, winners[_rID].tID, winners[_rID].addr);
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
