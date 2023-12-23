// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Interface {
    function transferFrom(address sender,address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenTransferContract{
    address public owner;
    mapping(address => bool) private verifiedTokens;
    address [] public verifiedTokensList;

    struct Transaction {
        address sender;
        address receiver;
        uint256 amount;
        string message;
    }

    event TransactionCompleted (
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        string message
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'only owner can call this function.');
        _;
        
    }

    modifier onlyVerfiedToken(address tokenAddress){
        require (verifiedTokens[tokenAddress],'Token is not verified');
        _;
    }

    function addVerifiedToken(address _token) public onlyOwner{
        verifiedTokens[_token] = true;
        verifiedTokensList.push(_token);
    }

    function removeVerifiedToken(address _token) public onlyOwner{
        require( verifiedTokens[_token] == true, 'Token is not verified');
        verifiedTokens[_token] = false;

        for ( uint256 i=0; i< verifiedTokensList.length; i++){
            if( verifiedTokensList[i] == _token){
                verifiedTokensList[i] = verifiedTokensList[verifiedTokensList.length-1];
                verifiedTokensList.pop();
                break;
            }
        }
    }

    function getVerifiedTokens() public view returns(address[] memory){
        return verifiedTokensList;
    }

    function transfer(IERC20Interface token, address to , uint256 amount, string memory message) public onlyVerfiedToken(address(token)) returns (bool){
        uint256 senderBalance = token.balanceOf(msg.sender);
        require(senderBalance >= amount, 'Insufficient balance');
        bool success = token.transferFrom(msg.sender,to,amount);
        require (success, 'Transaction failed');

        Transaction memory transaction = Transaction({
            sender: msg.sender,
            receiver: to,
            amount: amount,
            message: message
        });

        emit TransactionCompleted(msg.sender, transaction.receiver, transaction.amount, transaction.message);

        return true;
    }
}