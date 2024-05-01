// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";
contract ATokenETH is ERC20 {
    address public owner;
    uint256 constant private AAVE_PRICE_USD = 88.53 * (10 ** 18); 
    uint256 constant private ETH_PRICE_USD = 3171.83 * (10 ** 18); 

    uint256 public ethToUsd;
    uint256 public aaveToUsd;
    constructor() ERC20("aToken Ethereum", "anew1ETH") {
        owner = msg.sender;
        ethToUsd = (10 ** 36) / ETH_PRICE_USD; 
        aaveToUsd = AAVE_PRICE_USD; 
    }

    function mintTokens(address recipient, uint256 amount) external {
        require(msg.sender == owner, "Only owner can mint tokens");
        uint256 aaveAmount = (amount * ethToUsd)*(10**18) / aaveToUsd;
        _mint(recipient, aaveAmount);
        uint256 balanceAfterMint = balanceOf(recipient);
        emit BalanceAfterMint(recipient, balanceAfterMint);
        emit TokensMinted(recipient, amount, aaveAmount);
    }
    event BalanceAfterMint(address indexed recipient, uint256 balance);

    function burnTokens(address recipient, uint256 amount) public payable {

        console.log(balanceOf(recipient));
        
        require(msg.sender == owner, "Only owner can burn tokens");
        uint256 ethAmount = (amount * ethToUsd) * (10**18)/ aaveToUsd;
        console.log(ethAmount);
        require(balanceOf(recipient) >= ethAmount, "Insufficient balance");

        
        _burn(recipient, ethAmount);
        console.log(msg.sender);
        console.log(recipient);
        console.log("Balance");
        console.log(recipient.balance);

        console.log("Amount :");
        console.log(amount);
        
        

        emit TokensBurned(recipient, amount, ethAmount);
    }


    event TokensMinted(address indexed recipient, uint256 amount, uint256 aaveAmount);
    event TokensBurned(address indexed burner, uint256 amount, uint256 ethAmount);
    
}