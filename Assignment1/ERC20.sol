// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SafeMath.sol";

contract ERC20 is Ownable {
    using SafeMath for uint;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    uint public immutable MAX_SUPPLY;

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private allowances;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    constructor() {
        name = "TroonToken";
        symbol = "TRN";
        decimals = 8;
        MAX_SUPPLY = 20_000_000 * 10**decimals;
    }

    function mint(uint _amount) public onlyOwner {
        require(totalSupply.add(_amount) <= MAX_SUPPLY, "MINT: Max Supply Exceeded");
        totalSupply = totalSupply.add(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
        emit Transfer(address(0), msg.sender, _amount);
    }

    function balanceOf(address _account) public view returns(uint) {
        return balances[_account];
    }

    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        require(_spender != address(0), "APPROVE: spender address is null");

        allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _amount) public returns (bool) {
        approve(_spender, allowances[msg.sender][_spender].add(_amount));
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _amount) public returns (bool) {
        uint256 currentAllowance = allowances[msg.sender][_spender];
        require(currentAllowance >= _amount, "DECREASE_ALLOWANCE: decreased allowance below zero");
    
        approve(_spender, currentAllowance.sub(_amount));
        return true;
    }


    function transfer(address _to, uint _amount) public returns (bool) {
        require(_to != address(0), "TRANSFER: to address is null");
        require(_amount <= balances[msg.sender], "TRANSFER: sender account doesn't have enough balance");

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
        require(_to != address(0), "TRANSFER: to address is null");
        require(_from != address(0), "TRANSFER: from address is null");
        require(_amount <= allowances[_from][msg.sender], "TRANSFER: caller approved balance is not enough!");
        require(_amount <= balances[_from], "TRANSFER: sender account doesn't have enough balance");

        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    } 
}