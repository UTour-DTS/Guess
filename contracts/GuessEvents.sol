pragma solidity ^0.4.24;


contract GuessEvents {
    event DrawLog(uint a, uint b, uint c);

    event GuessEvt(
        address indexed playerAddr,
        uint price,
        uint rID,
        uint tID,
        uint amount
        );
    
    event NewPrdctEvt(
        uint rID,
        uint price,
        uint maxPlyr,
        string name, 
        string nameEn, 
        string disc, 
        string discEn
    );

    event WinnersEvt(
        uint blockNumber,
        address indexed playerAddr,
        uint amount,
        uint winAmount
        );

    event WithdrawEvt(
        address indexed to,
        uint256 value
        );

    event EndGuessEvt(
        uint rID,
        uint minValue, 
        uint pID,
        uint tID,
        address addr,
        uint timestamp
        );
}
