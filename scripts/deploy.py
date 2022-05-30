from scripts.helpful_scripts import get_account, get_contract 
from brownie import DappToken, TokenFarm, network, config
from web3 import Web3
import yaml
import json
import os
import shutil

KEPT_BALANCE = Web3.toWei(100, "ether")

def deploy_token_farm_and_dapp_token(front_end_update=False):
    account = get_account()
    print(f"The active network is {network.show_active()}")
    print(f"Account being used to deploy: {account}")
    # Deploy Dapp Token
    dapp_token = DappToken.deploy({"from": account})
    print(f"Dapp token address: {dapp_token.address}")
    print(f"Dapp token total supply: {dapp_token.totalSupply()}")
    print("")
    # Deploy token farm account
    token_farm = TokenFarm.deploy(
        dapp_token.address,
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )
    print(f"TokenFarm address: {token_farm.address}")
    print(f"TokenFarm supply of Dapp ERC20 tokens: {dapp_token.balanceOf(token_farm.address)}")
    print("")
    # Send out Dapp Token from ER20 to TokenFarm contract, ass tokenfarm contrack will distribute these tokens
    tx = dapp_token.transfer(
        token_farm.address, dapp_token.totalSupply() - KEPT_BALANCE, {"from": account}
    )
    tx.wait(1)
    print(f"TokenFarm supply of Dapp ERC20 tokens: {dapp_token.balanceOf(token_farm.address)}")
    print("")
    # Will allow 3 tokens, will pretend fau_token is DAI whilst in tetsing
    print("Add allowed tokens")
    # Get address of weth & fau tokens, if they don't exsist on network we will deploy a mock
    weth_token = get_contract("weth_token")
    fau_token = get_contract("fau_token")
    # Map token to their respective price feed address
    dict_of_allowed_tokens = {
        dapp_token: get_contract("dai_usd_price_feed"), # We'll assume our dapp token is 1:1 with $
        fau_token: get_contract("dai_usd_price_feed"), # equal to dai
        weth_token: get_contract("eth_usd_price_feed"), # WETH = eth
    }
    add_allowed_tokens(token_farm, dict_of_allowed_tokens, account)
    # Default is False so won't exercute unless instrucuted to to in main body of the funtion
    if front_end_update:
        update_front_end()
    return token_farm, dapp_token


def add_allowed_tokens(token_farm, dict_of_allowed_tokens, account):
    """
    Takes are arguments 
        1) TokenFram contract address, 
        2) Dictionary of allowed tokens
        3) Account to deploy with
    """
    for token in dict_of_allowed_tokens:
        add_tx = token_farm.addAllowedTokens(token.address, {"from": account})
        add_tx.wait(1)
        set_tx = token_farm.setPriceFeedContract(
            token.address, dict_of_allowed_tokens[token], {"from": account}
        )
        set_tx.wait(1)
    return token_farm



def update_front_end():
    # In the real world a lot of these would be set & then you would just hard copy them over
    # However, as we're still buidling/developing we can use this script to update fron end app

    # START Sending the front end our config in JSON format
    copy_folders_to_front_end("./build", "./front_end/src/chain-info")

    # START - Send the config file to front end folder so they have access to materials in there
    with open("brownie-config.yaml", "r") as brownie_config:
        # Import into a dictionary object
        config_dict = yaml.load(brownie_config, Loader=yaml.FullLoader)
        # Send this as a JSON object to the front end folder
        # Open source folder in write mode
        with open("./front_end/src/brownie-config.json", "w") as brownie_config_json:
            # dump it into this file
            json.dump(config_dict, brownie_config_json)
    print("Front end updated!")


def copy_folders_to_front_end(src, dest):
    # src <-- source folder
    # est <-- destination folder 
    # Check if it exsits
    if os.path.exists(dest):
        # If so then remove it
        shutil.rmtree(dest)
    # Then copy everything over from the build folder
    shutil.copytree(src, dest)


def main():
    deploy_token_farm_and_dapp_token(front_end_update=True)