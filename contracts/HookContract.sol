// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


// hook contract
contract RealWorldCurrenciesUniswapV4Hook {

int256 public LatestEuroPrice;

string public constant Currencies = "EUR / USD";

// this function is the main one to get the data rom Chainlink Oracle
function GetDataFromChainlink () public {
    AggregatorV3Interface EuroPrice = AggregatorV3Interface (0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910);
    (,int256 answer,,,) = EuroPrice.latestRoundData();
    LatestEuroPrice = answer; // / 10e18;
    }

}

