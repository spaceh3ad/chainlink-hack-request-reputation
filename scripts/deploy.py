from brownie import APIConsumer, config, network, accounts, interface
from web3 import Web3

# https://ormi.herokuapp.com/data?
query = "reputation/eth/0xF444A6B13c63999639dF53c1DB10bD59e3048b3e"


def deploy_contract():
    account = accounts.add(config["wallets"]["from_key"])

    api = APIConsumer.deploy(
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )

    link = interface.IERC20(config["networks"][network.show_active()]["link"])
    link.transfer(api, Web3.toWei(5, "ether"), {"from": account})

    api.requestReputationData(
        config["networks"][network.show_active()]["oracle"],
        config["networks"][network.show_active()]["jobId"],
        query,
        {"from": account},
    )


def main():
    deploy_contract()
