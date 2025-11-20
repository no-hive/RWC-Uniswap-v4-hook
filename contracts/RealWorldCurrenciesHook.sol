// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {BaseHook} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BeforeSwapDelta} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract RealWorldCurrenciesUniswapV4Hook is BaseHook {
using PoolIdLibrary for PoolKey;

constructor(IPoolManager _poolManager) BaseHook(_poolManager)
{
Oracle_Address = 0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910;
owner = msg.sender;
}

string public constant Currencies = "EUR / USD";

address public Oracle_Address;

address public owner;

event OracleAddressUpdated (address indexed old_address, address indexed new_address, address updated_by);

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
        beforeSwapReturnDelta: false,
        afterSwapReturnDelta: false,
        afterAddLiquidityReturnDelta: false,
        afterRemoveLiquidityReturnDelta: false
        });
        }
    
// # BeforeSwap function
// is needed to collect proper fees + write down how to rebalance them later.
function beforeSwap (address, PoolKey calldata key, IPoolManager.SwapParams calldata, bytes calldata)
    external
    override   
    returns (bytes4, BeforeSwapDelta, uint24)
    {
    // find current price 
    (uint160 sqrtPriceX96,,,) = poolManager.getSlot0(key.toId()); // StateLibrary.getSlot0 ???
    // maybe change for params call.
    uint256 priceQ192 = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
    int256 DefaultPoolPrice = int256((priceQ192 * 1e18) >> 96);
    //

    // find chainlink price
    (, int256 answer, , , ) = AggregatorV3Interface(Oracle_Address).latestRoundData();
    require(answer > 0, "Invalid oracle price");
    int256 LatestEuroPrice = (answer * 1e10);

    // BeforeSwapDelta definition
    BeforeSwapDelta delta;
    if (LatestEuroPrice > DefaultPoolPrice)
    {
        int256 priceDiff = (LatestEuroPrice - DefaultPoolPrice);
        delta = BeforeSwapDelta({deltaX: priceDiff, deltaY: 0});
        }
    else 
    { 
        int256 priceDiff = (DefaultPoolPrice - LatestEuroPrice);
        delta = BeforeSwapDelta({deltaX: 0, deltaY: priceDiff});
        }
        return (bytes4(0), delta, 0); // return is probably wrong
}

// update Oracle Address
function updateOracleAddress (address _newOracleAddress) external onlyOwner {
    emit OracleAddressUpdated (Oracle_Address, _newOracleAddress, msg.sender);
    Oracle_Address = _newOracleAddress;
}

modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can call this function");
    _;
}

}
// check scaling
// add owner opportunity to change oracle / liquidity providers can change oracle address.


