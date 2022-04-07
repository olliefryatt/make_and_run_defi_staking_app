from scripts.helpful_scripts import get_account, get_contract 
from brownie import DappToken, TokenFarm, network, config
from web3 import Web3

KEPT_BALANCE = Web3.toWei(100, "ether")

def deploy_token_farm_and_dapp_token():
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

def main():
    deploy_token_farm_and_dapp_token()