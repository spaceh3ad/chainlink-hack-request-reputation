from brownie import APIConsumer, config, network, accounts, interface
from web3 import Web3

# https://ormi.herokuapp.com/data?
query = "id=0x2&type=ETH"


def deploy_contract():
    account = accounts.add(config["wallets"]["from_key"])

    api = APIConsumer.deploy(
        config["networks"][network.show_active()]["oracle"],
        config["networks"][network.show_active()]["jobId"],
        config["networks"][network.show_active()]["fee"],
        config["networks"][network.show_active()]["link"],
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )

    link = interface.IERC20(config["networks"][network.show_active()]["link"])
    link.transfer(api, Web3.toWei(2, "ether"), {"from": account})

    api.requestReputationData(query, {"from": account})


def main():
    deploy_contract()
