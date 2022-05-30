
## Objective of this repo

Build out a web based app that interacts with our smart contracts. Users should be able to enter our front end application through their Web3 wallet and stake tokens to our smart contract. We should be able to specify what tokens we allowed to be staked and reward stakers by issuing a reward token. 

## Building out the Web3 Smart Contracts in this project

1. Build out SmartContracts. See contracts for more detail on their respective funtionality. Note contracts are not gas optimised. See 'DappToken.sol' & 'TokenFarm.sol'. Note need to work with OpenZepplin contracts. Depending on your set up will need to modify the import lines in the SmartContracts. 

2. Build deployment python scripts. See 'scripts'. Includes adding mock contracts for local deployment, see contracts/test.

3. Unit testing of smart contracts. See test/unit & also 'conftest.py'. 

## Deploy to a live blockcahin

Make sure (1st) that we have ".gitgnore" to ensure our .env file is not pushed to github. Then (2nd) make sure we have a ".env" file. Inside the env file we need the following details. 

PRIVATE_KEY=______
WEB3_INFURA_PROJECT_ID=________
ETHERSCAN_TOKEN=________

Make sure we have have enough in our wallet to deploy on testnets. If not find a faucet. Note that our front end application will only work on chain that we specify at that stage. 

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

Will now also use https://usedapp.io/ to help beef up our front end. Rather than building it all out from scatch. 

> $ yarn add @usedapp/core

Initally start work in src/App.tsx. For more detail on this 14:15:00 https://www.youtube.com/watch?v=M576WGiDBdQ&t=50271s

Important files
- Index.tsx
- App tsx
- Components folder

For styling we wil use Material UI https://mui.com/. Do set up if necessary. I used this command, doesn't seem to match their lattest docs. 

> $ yarn add @material-ui/core

Then can import sytling into scripts. e.g. imported button style into the components/header.tsx. 

> import { Button, makeStyles } from "@material-ui/core"

We also set a default style or use across the app. See this in the src/components/header.tsx

> const useStyles = makeStyles((theme)... & then in the header... 
> const classes = useStyles()

Note to start building more complexity into the front end we need to move content of our config file to the app. See instructions on this at (14:37:00). When updaitng deploy.py to dump files make sure yaml in installed.

> $ pip install pyyaml