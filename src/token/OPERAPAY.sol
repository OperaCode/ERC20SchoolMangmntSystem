// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";

contract OPERAPAY is IERC20 {
    
    // Token Metadata 
    string private constant tokenName = "OPERAPAY";
    string private constant tokenSymbol = "OPPY";
    uint8 private constant tokenDecimal = 18;

    uint256 private tokenTotalSupply = 26_000_000 * 1e18;

    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        _balances[msg.sender] = tokenTotalSupply;
        emit Transfer(address(0), msg.sender, tokenTotalSupply);
    }

    function name() external pure returns (string memory) {
        return tokenName;
    }

    function symbol() external pure returns (string memory) {
        return tokenSymbol;
    }

    function decimals() external pure returns (uint8) {
        return tokenDecimal;
    }

    function totalSupply() external view returns (uint256) {
        return tokenTotalSupply;
    }

    function balanceOf(address user) external view returns (uint256) {
        return _balances[user];
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

   
    function transfer(address to, uint256 amount) external returns (bool) {
        transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Approve to zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "Allowance too low");

        _allowances[from][msg.sender] = currentAllowance - amount;
        emit Approval(from, msg.sender, _allowances[from][msg.sender]);

        _transfer(from, to, amount);
        return true;
    }

   
    function transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "Transfer from zero");
        require(to != address(0), "Transfer to zero");
        require(amount > 0, "Amount zero");

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "Insufficient balance");

        _balances[from] = senderBalance - amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }
}