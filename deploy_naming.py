from starkware.starknet.compiler.compile import get_selector_from_name
from starknet_py.net.models.chains import StarknetChainId
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.networks import Network
from starknet_py.transactions.deploy import make_deploy_tx
from starknet_py.compile.compiler import create_contract_class

import asyncio
import sys

argv = sys.argv

deployer_account_addr = (
    0x048F24D0D0618FA31813DB91A45D8BE6C50749E5E19EC699092CE29ABE809294
)
deployer_account_private_key = int(argv[1])
admin = 0x048F24D0D0618FA31813DB91A45D8BE6C50749E5E19EC699092CE29ABE809294
network: Network = "testnet"
chain: StarknetChainId = StarknetChainId.TESTNET
max_fee = int(1e16)

pricing = 0
whitelisting_key = (
    1576987121283045618657875225183003300580199140020787494777499595331436496159
)
l1_contract = 0


async def main():
    client = GatewayClient(net=network)
    account = AccountClient(
        client=client,
        address=deployer_account_addr,
        key_pair=KeyPair.from_private_key(deployer_account_private_key),
        chain=chain,
        supported_tx_version=1,
    )

    logic_file = open("./build/pricing.json", "r")
    declare_contract_tx = await account.sign_declare_transaction(
        compiled_contract=logic_file.read(), max_fee=max_fee
    )
    logic_file.close()
    logic_declaration = await account.declare(declare_contract_tx)
    logic_contract_class_hash = logic_declaration.class_hash
    print("implementation class hash:", hex(logic_contract_class_hash))

    proxy_file = open("./build/proxy.json", "r")
    deploy_contract_tx = make_deploy_tx(
        compiled_contract=create_contract_class(proxy_file.read()),
        constructor_calldata=[
            logic_contract_class_hash,
            get_selector_from_name("initializer"),
            1,
            admin,
        ],
        version=1,
    )
    proxy_file.close()
    deployment_resp = await account.deploy(deploy_contract_tx)
    print("deployment txhash:", hex(deployment_resp.transaction_hash))
    print("proxied pricing contract address:", hex(deployment_resp.contract_address))


if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
