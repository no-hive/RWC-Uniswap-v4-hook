// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import // everything

contract RealWorldCurrenciesUniswapV4Hook is BaseHook {
using PoolIdLibrary for PoolKey;

mapping(PoolId => uint256 count) public beforeSwapCount;

mapping(PoolId => uint256 count) public afterSwapCount;

constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

int256 public LatestEuroPrice;

string public constant Currencies = "EUR / USD";

// hook permissions
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
        afterSwap: true,
        beforeDonate: false,
        afterDonate: false,
        beforeSwapReturnDelta: false,
        afterSwapReturnDelta: false,
        afterAddLiquidityReturnDelta: false,
        afterRemoveLiquidityReturnDelta: false
        });
        }
    
// beforeSwap
function _beforeSwap (address, PoolKey calldata key, IPoolManager.SwapParams calldata, bytes calldata)
    internal
    override
    returns (bytes4, BeforeSwapDelta, uint24)
    {
    beforeSwapCount[key.toId()]++;
    return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }
    

//
// before_hook to fix the difference and collect proper fees + undesrtand how to rebalance later
// after_hook to rebalance the results using transactions

// get the data from Chainlink Oracle
function GetDataFromChainlink () public 
    {
    AggregatorV3Interface EuroPrice = AggregatorV3Interface (0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910);
    (,int256 answer,,,) = EuroPrice.latestRoundData();
    LatestEuroPrice = (answer / 10e7) ;
    // 1.15676000 - the result
    }

}
