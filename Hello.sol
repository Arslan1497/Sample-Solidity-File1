// Hello world
solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ExampleToken - An ERC20 token with mint, burn, pause, and ownable features
/// @author ChainGPT

contract ExampleToken {
    // --- ERC20 Metadata ---
    string public constant name = "ExampleToken";
    string public constant symbol = "EXT";
    uint8 public constant decimals = 18;

    // --- ERC20 Storage ---
    uint256 public totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // --- Access Control ---
    address public owner;

    // --- Pausable ---
    bool public paused;

    // --- Events ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address indexed account);
    event Unpaused(address indexed account);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    // --- Modifiers ---
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Not paused");
        _;
    }

    // --- Constructor ---
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // --- ERC20 Functions ---

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external whenNotPaused returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address accountOwner, address spender) external view returns (uint256) {
        return _allowances[accountOwner][spender];
    }

    function approve(address spender, uint256 amount) external whenNotPaused returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external whenNotPaused returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(from, msg.sender, currentAllowance - amount);
        }
        _transfer(from, to, amount);
        return true;
    }

    // --- Minting ---
    function mint(address to, uint256 amount) external onlyOwner whenNotPaused {
        require(to != address(0), "ERC20: mint to zero");
        totalSupply += amount;
        unchecked {
            _balances[to] += amount;
        }
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    // --- Burning ---
    function burn(uint256 amount) external whenNotPaused {
        _burn(msg.sender, amount);
    }

    function burnFrom(address from, uint256 amount) external whenNotPaused {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(from, msg.sender, currentAllowance - amount);
        }
        _burn(from, amount);
    }

    // --- Pause/Unpause ---
    function pause() external onlyOwner whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }

    // --- Ownership ---
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is zero");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // --- Internal Functions ---

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from zero");
        require(to != address(0), "ERC20: transfer to zero");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _approve(address accountOwner, address spender, uint256 amount) internal {
        require(accountOwner != address(0), "ERC20: approve from zero");
        require(spender != address(0), "ERC20: approve to zero");
        _allowances[accountOwner][spender] = amount;
        emit Approval(accountOwner, spender, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "ERC20: burn from zero");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            totalSupply -= amount;
        }
        emit Burn(from, amount);
        emit Transfer(from, address(0), amount);
    }
}


