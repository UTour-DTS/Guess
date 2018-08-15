pragma solidity ^0.4.24;


library Utils {
    function inArray(uint[] _arr, uint _val) internal pure returns(bool) {
        for (uint _i = 0; _i < _arr.length; _i++) {
            if (_arr[_i] == _val) {
                return true;
                break;
            }
        }
        return false;
    }
    
    function inArray(address[] _arr, address _val) internal pure returns(bool) {
        for (uint _i = 0; _i < _arr.length; _i++) {
            if (_arr[_i] == _val) {
                return true;
                break;
            }
        }
        return false;
    }
}