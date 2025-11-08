
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

// Recommended for Remix IDE (using raw URLs)

import "https://raw.githubusercontent.com/Uniswap/v4-periphery/main/src/utils/BaseHook.sol";

import "https://raw.githubusercontent.com/Uniswap/v4-core/main/src/libraries/Hooks.sol";
import "https://raw.githubusercontent.com/Uniswap/v4-core/main/src/interfaces/IPoolManager.sol";
import "https://raw.githubusercontent.com/Uniswap/v4-core/main/src/types/PoolKey.sol";
import "https://raw.githubusercontent.com/Uniswap/v4-core/main/src/types/PoolId.sol";
import "https://raw.githubusercontent.com/Uniswap/v4-core/main/src/types/BalanceDelta.sol";
import "https://raw.githubusercontent.com/Uniswap/v4-core/main/src/types/BeforeSwapDelta.sol";

contract SwapHook is BaseHook {
    using PoolIdLibrary for PoolKey;

    // NOTE: ---------------------------------------------------------
    // state variables should typically be unique to a pool
    // a single hook contract should be able to service multiple pools
    // ---------------------------------------------------------------

    mapping(PoolId => uint256 count) public beforeSwapCount;
    mapping(PoolId => uint256 count) public afterSwapCount;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
        beforeInitialize: false,
        afterInitialize: false,
        beforeAddLiquidity: false,
        afterAddLiquidity: false,
        beforeRemoveLiquidity: false,
        afterRemoveLiquidity: false,
        beforeSwap: true,
        afterSwap: true,
        beforeDonate: false,
        afterDonate: false,
        beforeSwapReturnDelta: false,
        afterSwapReturnDelta: false,
        afterAddLiquidityReturnDelta: false,
        afterRemoveLiquidityReturnDelta: false
    });
    }
    function _beforeSwap (address, PoolKey calldata key, IPoolManager.SwapParams calldata, bytes calldata)
    internal
    override
    returns (bytes4, BeforeSwapDelta, uint24)
{
    beforeSwapCount[key.toId()]++;
    return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
}
}