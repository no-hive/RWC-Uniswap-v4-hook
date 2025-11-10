// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import {BeforeSwapDelta} from "@uniswap/v4-core/contracts/types/BeforeSwapDelta.sol";
import {SwapMath} from "@uniswap/v4-core/contracts/libraries/SwapMath.sol";
import {BaseHook} from "@uniswap/v4-core/contracts/base/BaseHook.sol";

contract RealWorldCurrencyHook is BaseHook {
    using SwapMath for uint160;

    AggregatorV3Interface private constant CHAINLINK_EUR_USD =
        AggregatorV3Interface(0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910);

    int256 public latestEuroPrice;
    uint256 public defaultPoolPrice;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory)
    {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: false,  // Disabled (using beforeSwapReturnDelta instead)
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: true,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    // Fetches latest EUR/USD price from Chainlink
    function updateOraclePrice() external {
        (, int256 answer, , , ) = CHAINLINK_EUR_USD.latestRoundData();
        latestEuroPrice = answer;  // Keep full precision (1e8 for Chainlink EUR/USD)
    }

    // Adjusts swap deltas based on price difference
    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    )
        external
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        // Get current pool price (EUR/USD)
        (uint160 sqrtPriceX96, , , , , , ) = poolManager.getSlot0(key);
        defaultPoolPrice = uint256(sqrtPriceX96).mul(sqrtPriceX96) >> (192);  // Convert to Q64.64

        // Scale Chainlink price (1e8) to match pool price precision
        int256 scaledOraclePrice = latestEuroPrice * (1e18 / 1e8);
        int256 priceDifference = scaledOraclePrice - int256(defaultPoolPrice);

        // Calculate adjustment (0.1% of difference)
        int256 adjustment = priceDifference / 1000;

        // Apply adjustment to swap delta
        BeforeSwapDelta delta;
        if (priceDifference > 0) {
            delta = BeforeSwapDelta({deltaX: adjustment, deltaY: 0});  // Reduce EUR (token0)
        } else {
            delta = BeforeSwapDelta({deltaX: 0, deltaY: -adjustment}); // Reduce USD (token1)
        }

        return (this.beforeSwap.selector, delta, 0);
    }

    // Optional: Add access control for updateOraclePrice
    function setOracleAddress(address _oracle) external {
        // Add owner-only modifier in production
        CHAINLINK_EUR_USD = AggregatorV3Interface(_oracle);
    }
}