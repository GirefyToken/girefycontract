// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract TokenTransfer {
    IERC20 _token;

    // token = MyToken's contract address
    constructor(address token) {
        _token = IERC20(token);
    }

    // Modifier to check token allowance
    modifier checkAllowance(uint amount) {
        console.log('on modifier checkAlloance');
        console.log('balance', _token.balanceOf(msg.sender));
        console.log('amount',amount);
        console.log('allowance',_token.allowance(msg.sender, address(this)));
        require(_token.allowance(msg.sender, address(this)) >= amount, "Error allowance");
        _;
    }

    // In your case, Account A must to call this function and then deposit an amount of tokens 
    function depositTokens(uint _amount) public checkAllowance(_amount) {
        _token.transferFrom(msg.sender, address(this), _amount);
    }
    
    // to = Account B's address
    function stake(address to, uint amount) public {
        _token.transfer(to, amount);
    }

    // Allow you to show how many tokens owns this smart contract
    function getSmartContractBalance() external view returns(uint) {
        return _token.balanceOf(address(this));
    }
    
}