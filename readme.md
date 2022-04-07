
## Objective of this repo

Build out a web based app that interacts with our smart contracts. Users should be able to enter our front end application through their Web3 wallet and stake tokens to our smart contract. We should be able to specify what tokens we allowed to be staked and reward stakers by issuing a reward token. 

## Steps taken in construction of this repo

1. Build out SmartContracts. See contracts for more detail on their respective funtionality. Note contracts are not gas optimised. See 'DappToken.sol' & 'TokenFarm.sol'. Note need to work with OpenZepplin contracts. Depending on your set up will need to modify the import lines in SmartContracts. 

2. Build deployment python scripts. See 'scripts'. Includes adding mock contracts for local deployment, see contracts/test.

3. Unit testing of smart contracts. See test/unit & also 'conftest.py'. 

4. 