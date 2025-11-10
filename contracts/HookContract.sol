// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {Hooks} from "@Uniswap/v4-core/main/src/libraries/Hooks.sol";
import {IPoolManager} from "@Uniswap/v4-core/main/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@Uniswap/v4-core/main/src/types/PoolKey.sol";
import {PoolIdLibrary} from "@Uniswap/v4-core/main/src/types/PoolId.sol";
import {BalanceDelta} from "@Uniswap/v4-core/main/src/types/BalanceDelta.sol";
import {BeforeSwapDelta} from "@Uniswap/v4-core/main/src/types/BeforeSwapDelta.sol";

contract RealWorldCurrenciesUniswapV4Hook is BaseHook {
using PoolIdLibrary for PoolKey;

constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

string public constant Currencies = "EUR / USD";

// # Hook permissions
function getHookPermissions() public pure override returns (Hooks.Permissions memory) 
        {
        return Hooks.Permissions({
        beforeInitialize: false,
        afterInitialize: false,
        beforeAddLiquidity: false,
        afterAddLiquidity: false,
        beforeRemoveLiquidity: false,
        afterRemoveLiquidity: false,
        beforeSwap: true,
        afterSwap: false,
        beforeDonate: false,
        afterDonate: false,
        beforeSwapReturnDelta: true,
        afterSwapReturnDelta: false,
        afterAddLiquidityReturnDelta: false,
        afterRemoveLiquidityReturnDelta: false
        });
        }
    
// # BeforeSwap function
// is needed to collect proper fees + write down how to rebalance them later.
function beforeSwap (address, PoolKey calldata key, IPoolManager.SwapParams calldata, bytes calldata)
    internal
    override   
    returns (bytes4, BeforeSwapDelta, uint24)
    {

    // find current price 
    (uint160 sqrtPriceX96,,,) = poolManager.getSlot0(key.toId());
    uint256 priceQ192 = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
    uint256 defaultPoolPrice = priceQ192 >> 192

    // find chainlink price
    AggregatorV3Interface EuroPrice = AggregatorV3Interface (0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910);
    (,int256 answer,,,) = EuroPrice.latestRoundData();
    LatestEuroPrice = answer;

    if (LatestEuroPrice > DefaultPoolPrice)
    {
        int256 priceDiff = (LatestEuroPrice - DefaultPoolPrice);
        int256 specifiedAdjustment = (priceDiff * absSpecified) / int256(poolPrice) / 1e18;
        return specifiedAdjustment;
        }
    else 
    { 
        int256 priceDiff = (DefaultPoolPrice - LatestEuroPrice);
        int256 specifiedAdjustment = (priceDiff * absSpecified) / int256(poolPrice) / 1e18;
        return specifiedAdjustment;
        }
BeforeSwapDelta newDelta = BeforeSwapDeltaLibrary.toBeforeSwapDelta(specifiedAdjustment, unspecifiedAdjustment);
    }
}
