
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

// Production contract
contract MyToken {
    string public name = "MyToken";
    uint256 public totalSupply = 1000;
    address public owner;

    mapping(address => uint256) public balances;

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        balances[owner] = totalSupply;
    }

    function mint(uint256 amount) public onlyOwner {
        totalSupply += amount;
        balances[owner] += amount;
        emit Mint(owner, amount);
    }

    function burn(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough balance");
        totalSupply -= amount;
        balances[msg.sender] -= amount;
        emit Burn(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}

// Foundry Test Contract (.t.sol)
contract MyTokenTest is Test {
    MyToken token;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        token = new MyToken();
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000);
        assertEq(token.balances(address(this)), 1000);
    }

    function testMintByOwner() public {
        token.mint(500);
        assertEq(token.totalSupply(), 1500);
        assertEq(token.balances(address(this)), 1500);
    }

    function testMintByNonOwner() public {
        vm.prank(alice);
        vm.expectRevert("Not the owner");
        token.mint(500);
    }

    function testBurn() public {
        token.burn(200);
        assertEq(token.totalSupply(), 800);
        assertEq(token.balances(address(this)), 800);
    }

    function testBurnFails() public {
        vm.expectRevert("Not enough balance");
        token.burn(2000);
    }

    function testTransfer() public {
        token.transfer(alice, 300);
        assertEq(token.balances(alice), 300);
        assertEq(token.balances(address(this)), 700);
    }

    function testTransferFails() public {
        vm.expectRevert("Not enough balance");
        token.transfer(bob, 2000);
    }

    function testEvents() public {
        vm.expectEmit(true, true, false, true);
        emit MyToken.Mint(address(this), 100);
        token.mint(100);

        vm.expectEmit(true, true, false, true);
        emit MyToken.Burn(address(this), 50);
        token.burn(50);
    }
}
