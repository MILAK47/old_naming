%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from src.interface.starknetid import StarknetID
from src.interface.naming import Naming

@external
func __setup__():
    %{
        context.starknet_id_contract = deploy_contract("./lib/starknet_id/src/StarknetId.cairo").contract_address
        context.pricing_contract = deploy_contract("./src/pricing/main.cairo", [123]).contract_address
        context.naming_contract = deploy_contract("./src/main.cairo", [context.starknet_id_contract, context.pricing_contract, 456]).contract_address
    %}
    return ()
end

@external
func test_simple_buy{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    tempvar starknet_id_contract
    tempvar naming_contract
    %{
        ids.starknet_id_contract = context.starknet_id_contract
        ids.naming_contract = context.naming_contract
        stop_prank_callable = start_prank(456)
        stop_mock = mock_call(123, "transferFrom", [1])
        warp(1)
    %}

    let token_id = Uint256(1, 0)
    StarknetID.mint(starknet_id_contract, token_id)
    # th0rgal encoded
    let th0rgal_string = 28235132438

    Naming.buy(naming_contract, token_id, th0rgal_string, 365, 456)
    let (addr) = Naming.domain_to_address(naming_contract, 1, new (th0rgal_string))
    assert addr = 456
    %{
        stop_prank_callable()
        stop_mock()
    %}

    return ()
end

@external
func test_set_domain_to_address{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    ):
    alloc_locals
    local starknet_id_contract
    local naming_contract
    %{
        ids.starknet_id_contract = context.starknet_id_contract
        ids.naming_contract = context.naming_contract
        stop_prank_callable = start_prank(456)
        stop_mock = mock_call(123, "transferFrom", [1])
        warp(1)
    %}

    let token_id = Uint256(1, 0)
    StarknetID.mint(starknet_id_contract, token_id)
    # th0rgal encoded
    let th0rgal_string = 28235132438

    Naming.buy(naming_contract, token_id, th0rgal_string, 365, 456)
    Naming.set_domain_to_address(naming_contract, 1, new (th0rgal_string), 789)

    let (addr) = Naming.domain_to_address(naming_contract, 1, new (th0rgal_string))
    assert addr = 789

    %{
        stop_prank_callable()
        stop_mock()
    %}

    return ()
end

@external
func test_set_address_to_domain{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    ):
    alloc_locals
    local starknet_id_contract
    local naming_contract
    %{
        ids.starknet_id_contract = context.starknet_id_contract
        ids.naming_contract = context.naming_contract
        stop_prank_callable = start_prank(456)
        stop_mock = mock_call(123, "transferFrom", [1])
        warp(1)
    %}

    let token_id = Uint256(1, 0)
    StarknetID.mint(starknet_id_contract, token_id)
    # th0rgal encoded
    let th0rgal_string = 28235132438

    Naming.buy(naming_contract, token_id, th0rgal_string, 365, 456)
    # %{
    #    stop_prank_callable()
    #    stop_prank_callable = start_prank(456)
    # %}
    # Naming.set_address_to_domain(naming_contract, 1, new (th0rgal_string))
    # let (domain_len, domain : felt*) = Naming.address_to_domain(naming_contract, 456)
    # assert domain_len = 1
    # assert domain[0] = th0rgal_string
    %{
        stop_prank_callable()
        stop_mock()
    %}

    return ()
end

@external
func test_transfer_domain{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    local starknet_id_contract
    local naming_contract
    %{
        ids.starknet_id_contract = context.starknet_id_contract
        ids.naming_contract = context.naming_contract
        stop_prank_callable = start_prank(456)
        stop_mock = mock_call(123, "transferFrom", [1])
        warp(1)
    %}

    let token_id = Uint256(1, 0)
    StarknetID.mint(starknet_id_contract, token_id)

    let token_id2 = Uint256(2, 0)
    StarknetID.mint(starknet_id_contract, token_id2)

    # th0rgal encoded
    let th0rgal_string = 28235132438

    Naming.buy(naming_contract, token_id, th0rgal_string, 365, 456)
    Naming.transfer_domain(naming_contract, 1, new (th0rgal_string), token_id2)

    %{
        stop_prank_callable()
        stop_mock()
    %}

    return ()
end

@external
func test_transfer_subdomain{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    local starknet_id_contract
    local naming_contract
    %{
        ids.starknet_id_contract = context.starknet_id_contract
        ids.naming_contract = context.naming_contract
        stop_prank_callable = start_prank(456)
        stop_mock = mock_call(123, "transferFrom", [1])
        warp(1)
    %}

    let token_id = Uint256(1, 0)
    StarknetID.mint(starknet_id_contract, token_id)

    let token_id2 = Uint256(2, 0)
    StarknetID.mint(starknet_id_contract, token_id2)

    # th0rgal encoded
    let th0rgal_string = 28235132438

    Naming.buy(naming_contract, token_id, th0rgal_string, 365, 456)
    Naming.transfer_domain(naming_contract, 2, new (th0rgal_string, th0rgal_string), token_id2)

    %{
        stop_prank_callable()
        stop_mock()
    %}

    return ()
end
