// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/// IMPORTS /// 

/* What every import is needed for, explained: 
 *
 *
 *
 *
 * 
 *
 */

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {BaseHook} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BeforeSwapDelta} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// CONTRACT ///

/* @title
 * @author
 * @notice
 */
contract RealWorldCurrenciesUniswapV4Hook is BaseHook {
using PoolIdLibrary for PoolKey;

/// CONSTRUCTOR ///

constructor(IPoolManager _poolManager) BaseHook(_poolManager) // explore why it looks like this
{
Oracle_Address = 0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910;
owner = msg.sender;
}

/// STORAGE ///

/* just the public insrcibtion to let traders know what currencies this hook stands for. */
string public constant Currencies = "EUR / USD";

/* Oracle Address
 *
 * Keeps Chainlink Oracle address. First adress is saved using constractor.
 *
 * Can be be updated by the owner anytime via change_oracle_address function. 
 *
 * Perfectly the liquidity providers are the ones to change it collectively. 
 */ 
address public Oracle_Address;

/* Owner Address
 * Probably must be performed via Ownable added to the contract,
 * Or it is also possible to make contract ownership asigned to 
 * liquidity providers via adding some simple DAO funtionality.
 */ 
address external owner;

/// EVENTS ///

/* Emited after the address is updated via ________ function */
event OracleAddressChanged (address indexed old_address, address indexed new_address, address updated_by);

/* Emited after the price feed is succefully fetched from Chainlink Oracle before the swap */
event OraclePriceGot();

/* Emited after he amount of the swap is succesfully  */
event SwapAmountGot();

/* Emited after the adjustment is counted */
event SwapAdjustmentsCompleted();

/// SWAP FUNCTIONS ///

/* comment */
function get_chainlink_price

/* comment */
function get_swap_amount

/* comment */
function swap_using_chainlink_prices

/* comment */
function change_oracle_address

/// HOOK MANAGEMENT FUNCTIONS ///

function getHookPermissions

/// MODIFIERS ///

/* Modifier to let Hook Manangemnet be managaable only by Owner.
 * In the future this modifier is better to be changed by Ownable 
 * functionality & Liquidity Providers DAO governing functionality.
 */
modifier onlyOwner() {
    require(msg.sender == owner, "Not the owner");
    _;
 }