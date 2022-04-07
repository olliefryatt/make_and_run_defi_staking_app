
pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/token/ERC20/ERC20.sol";

contract MockWETH is ERC20 {
    constructor() public ERC20("Mock WETH", "WETH"){}
}