pragma solidity ^0.4.24;


contract GuessEvents {
    event DrawLog(uint, uint, uint);

    event GuessEvt(
        address indexed playerAddr,
        uint price,
        uint rID,
        uint tID, 
        uint amount
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

    event DrawEvt(
        uint indexed blocknumberr,
        uint number
        );
}