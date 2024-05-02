// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./Erc20.sol";
import "hardhat/console.sol";
contract LendingPool1 {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public borrowedAmounts;
    mapping(address => bool) public isBorrower;
    mapping(address => uint256) public timestamp_borrow;
    mapping(address => bool) public isFirstRepay;
    mapping(address => uint256) public repayable_interest;

    uint256 public totalDeposits;
   

    ATokenETH public token; // Token contract address

    event Deposit(address indexed user, uint256 amount, uint256 tokensMinted);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
   

    constructor() {
        token = new ATokenETH();
    }
    event BalanceAfterDeposit(address account, uint256 balance);
    event BalanceAfterWithdrawal(address account, uint256 balance);


    // Deposit funds into the lending pool and mint tokens
    function depositETH() external payable {
        uint256 _ethAmount = msg.value;
        require(_ethAmount > 0, "Amount must be greater than 0");

        token.mintTokens(msg.sender,  _ethAmount); // Mint tokens directly to the user
        balances[msg.sender] += _ethAmount;
        totalDeposits += _ethAmount;
        emit Deposit(msg.sender, _ethAmount,  _ethAmount);
        emit BalanceAfterDeposit(msg.sender, balances[msg.sender]);
    }


    function withdraw(uint256 _amount) external payable{
        
        console.log(balances[msg.sender]);
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        token.burnTokens(msg.sender,  _amount);

        payable(msg.sender).transfer(_amount);
        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;
        
        emit Withdraw(msg.sender, _amount);
    }

    function borrow(uint256 _amount) external payable {
        require(!isBorrower[msg.sender], "You have already borrowed funds! Clear Debt To borrow again!");
        require(totalDeposits>_amount,"Not Enough Funds");
        require(msg.value>_amount,"Provide Collateral To continue the transaction");
        
        
        timestamp_borrow[msg.sender] = block.timestamp;

        // Additional checks for maximum borrowing limits, credit scores, etc. can be added here
        
        collateral[msg.sender] += msg.value;
        borrowedAmounts[msg.sender] += _amount;
        isBorrower[msg.sender] = true;
        isFirstRepay[msg.sender] = true;
        totalDeposits -= _amount;
        //console.log(_amount);
        payable(msg.sender).transfer(_amount);
        emit Borrow(msg.sender, _amount);


    }

    function repay() external payable{
        require(isBorrower[msg.sender],"You have not borrowed any funds!");
        uint256 time_now;
        time_now = block.timestamp;
        console.log("Borrowed at timestamp : ");
        console.log(timestamp_borrow[msg.sender]);

        if(isFirstRepay[msg.sender]){
            repayable_interest[msg.sender] = 0;
            isFirstRepay[msg.sender] = false;
        }
        repayable_interest[msg.sender] +=(time_now - timestamp_borrow[msg.sender]);
        console.log("Interest : ");
        console.log(repayable_interest[msg.sender]);

        uint256 total_repayable;
        total_repayable = repayable_interest[msg.sender] + borrowedAmounts[msg.sender];
        
        timestamp_borrow[msg.sender] = time_now;

        if (msg.value >= total_repayable) {
            

            isBorrower[msg.sender] = false;
            if (msg.value > total_repayable) {
                
                // Return Extra funds and collateral
                payable(msg.sender).transfer(msg.value - total_repayable+collateral[msg.sender]);
                // Return All collateral
                //payable(msg.sender).transfer(collateral[msg.sender]);
                
                collateral[msg.sender] = 0;

                console.log("Sent Back excess Funds and Collateral!");
                console.log(msg.value - total_repayable);
                
            }
            totalDeposits += total_repayable;
            borrowedAmounts[msg.sender] = 0;
            repayable_interest[msg.sender] = 0;
            
        }
        else{

            if(repayable_interest[msg.sender]<= msg.value){
                borrowedAmounts[msg.sender] -= msg.value-repayable_interest[msg.sender];
                repayable_interest[msg.sender] = 0;

            }
            else{
                repayable_interest[msg.sender] -= msg.value;
            }
            totalDeposits += msg.value;         
            
            
        }
    

    emit Repay(msg.sender, msg.value);



    }





}
