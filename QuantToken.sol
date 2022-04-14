// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract QuantToken is ERC20, ERC20Burnable, Ownable {
    address public admin;  
    struct Claim {
        address sender;
        uint time;
        uint amount;
    }  
    mapping(address => Claim) public claims;
    //mapping(address => uint) public balances;

    constructor() ERC20("Quant Token", "QTK") {
        admin = msg.sender;
        _mint(msg.sender, 100);
    }

    function transfer(address to) public payable {
        approve(to, msg.value);
        
        claims[to].time = block.timestamp;
        claims[to].amount += msg.value;
        claims[to].sender = msg.sender;
    }

    function claimableFunds() external view returns(uint) {
        return claims[msg.sender].amount;
    }

    function withdrawableAmount() public view returns(uint) {
        uint apm = allowance(claims[msg.sender].sender, msg.sender) / 100;
        return (block.timestamp - claims[msg.sender].time)/60 * apm;
    }

    function withdraw(uint amt) external {
        require(amt <= withdrawableAmount(), "Lock period for this much amount has not expired");
        require(amt <= claims[msg.sender].amount);
        claims[msg.sender].amount -= amt;
        claims[msg.sender].time = block.timestamp;
        _transfer(claims[msg.sender].sender, msg.sender, amt);
        if(claims[msg.sender].amount == 0) {
            delete claims[msg.sender];
        }
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
