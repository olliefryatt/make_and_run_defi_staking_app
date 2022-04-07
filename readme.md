
## Objective of this repo

Build out a web based app that interacts with our smart contracts. Users should be able to enter our front end application through their Web3 wallet and stake tokens to our smart contract. We should be able to specify what tokens we allowed to be staked and reward stakers by issuing a reward token. 

## Building out the Web3 Smart Contracts in this project

1. Build out SmartContracts. See contracts for more detail on their respective funtionality. Note contracts are not gas optimised. See 'DappToken.sol' & 'TokenFarm.sol'. Note need to work with OpenZepplin contracts. Depending on your set up will need to modify the import lines in SmartContracts. 

2. Build deployment python scripts. See 'scripts'. Includes adding mock contracts for local deployment, see contracts/test.

3. Unit testing of smart contracts. See test/unit & also 'conftest.py'. 

## Build the front end for our application to engage with our Smart Contracts

Check that we have npx & yar insallated. I had to install yarn https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable

> $ npx -version
> $ yarn --version

Create boiler plate folder template to hold our our work in. Will want to work with typescript rather than Javascript

> $ npx create-react-app front_end --template typescript

Note usually a project will have several repos covering all these topics. Here I'm putting everything into one repo. However, other porjects you might see that python/solidity would be in one repo and all the front end code would be in another repot. 

> $ cd front_end
> $ yarn
> $ yarn start

Should see a web app fornt end appear. Pree control C to close this

