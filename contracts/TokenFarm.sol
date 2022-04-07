// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Brownie use
import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.2.0/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


// Remix can use
//import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract TokenFarm is Ownable {
// Functionality to include
// Stake tokens
// unStake tokens
// issue toekns
// add Allowed tokens
// get Eth value of staked tokens

    // SET UP VARIABLES 

    // List of allowed tokens (could be a mapping)
    address[] public allowedTokens;

    // Map token address -> staker address -> amount 
    mapping(address => mapping(address => uint256)) public stakingBalance;

    // Capture how many unique tokens types each user has staked
    mapping(address => uint256) public uniqueTokensStaked;

    // Capture all stakers to this contract
    address[] public stakers;

    // Need map of token address to price feed address
    mapping(address => address) public tokenPriceFeedMapping;

    // 
    IERC20 public dappToken;



    // FUNTIONCS

    // Get address of our DappToken
    constructor(address _dappTokenAddress) {
        dappToken = IERC20(_dappTokenAddress);
    }

    // Need means to set the feed address
    function setPriceFeedContract(address _token, address _priceFeed)
        public
        onlyOwner 
    {
        tokenPriceFeedMapping[_token] = _priceFeed;
    }

    // Get total value staked by a user
    // Is very gas exspensive to give users a native token based on their tokens staked
    // Hence why we see a lot of protocols that allow users to 'claim' native tokens, is more gas efficient
    // Here we do it the gas exspensive way, we check their value staked then issue native token based on that
    function getUserTotalValue(address _user) public view returns (uint256){
        uint256 totalValue = 0;
        require(uniqueTokensStaked[_user] > 0, "No tokens staked!");
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ){
            totalValue = totalValue + getUserSingleTokenValue(_user, allowedTokens[allowedTokensIndex]);
        }
        return totalValue;
    }

    // Get value of single token type
    function getUserSingleTokenValue(address _user, address _token) 
    public
    view 
    returns (uint256) {
        if (uniqueTokensStaked[_user] <= 0){
            return 0;
        }
        // price of the token * stakingBalance[_token][user]
        (uint256 price, uint256 decimals) = getTokenValue(_token);
        return
            // Take amount of token user has staked, e.g. 10 ETH (but with decimals is 10000000000000000000)
            // Take price of ETH/USD in 'price'. but ETH/USD might only have 8 decimals
            // Calc here 10 ETH * price 
            (stakingBalance[_token][_user] * price / (10**decimals));
    }

    // Get value of a single token
    function getTokenValue(address _token) public view returns (uint256, uint256) {
        // Returns (a) price (b) decimals
        address priceFeedAddress = tokenPriceFeedMapping[_token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (,int256 price,,,)= priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());
        return (uint256(price), decimals);
    }

    // Stake tokens to contact
    function stakeTokens(uint256 _amount, address _token) public {
        // How much can they stake?
        require(_amount > 0, "Amount must be more than 0");
        // What tokens can they stake?
        require(tokenIsAllowed(_token), "Token is currently not allowed");
        // Transfer tokens from sender to this address. Use ERC20 interface from OpenZepplin
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        // If new token, update number of unique tokens types user has staked 
        updateUniqueTokensStaked(msg.sender, _token);
        // Add to list of tokens, stakers & count
        stakingBalance[_token][msg.sender] = stakingBalance[_token][msg.sender] + _amount;
        // If this is their first unique token, then we want to add them to the list of 'stakers'
        if (uniqueTokensStaked[msg.sender] == 1){
            stakers.push(msg.sender);
        }
    }

    function unstakeTokens(address _token) public {
        // Check their balance
        uint256 balance = stakingBalance[_token][msg.sender];
        require(balance > 0, "Staking balance cannot be 0");
        // Transfer them their funds
        IERC20(_token).transfer(msg.sender, balance);
        // Reduce their balance to 0
        stakingBalance[_token][msg.sender] = 0 ;
        // Remove a 'unique' token
        uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1;
        // Should really remove them from 'stakers' array, as they are no longer there
        // Issue tokens alreayd omits them if no tokens staked
    }

    // Issue native token (dapp token) to all stakers
    function issueTokens() public onlyOwner {
        // Issue tokens to all stakers
        for ( 
            uint256 stakersIndex = 0;
            stakersIndex < stakers.length;
            stakersIndex++
        ){
            // Loop through each staker
            address recipient = stakers[stakersIndex];
            // Sen them a token reward, baased on total value locked
            uint256 userTotalValue = getUserTotalValue(recipient);
            // Use funtion from dappToken to send that token
            dappToken.transfer(recipient, userTotalValue);
        }
    }

    // Check if the _token being deposited by a user is the first new type token deposited by that user, of it they staked this type before
    // Internal, only this contract can call this funtion
    function updateUniqueTokensStaked(address _user, address _token) internal {
        if (stakingBalance[_token][_user] <= 0){
            uniqueTokensStaked[_user] = uniqueTokensStaked[_user] + 1;
        }
    }

    // Add token to list of approved tokens
    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    // Look through list of approved tokens, return is allowed true/false
    function tokenIsAllowed(address _token) public returns (bool) {
        for( uint256 allowedTokensIndex=0; allowedTokensIndex < allowedTokens.length; allowedTokensIndex++){
            if(allowedTokens[allowedTokensIndex] == _token){
                return true;
            }
        }
        return false;
    }
}
