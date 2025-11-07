// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// hook contract
contract RealWorldCurrenciesUniswapV4Hook {

int256 public LatestEuroPriceIndex;

address private ContractAddress = 0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910;

string public Currencies = "EUR / USD";


// this function is the main one to get the data rom Chainlink Oracle
function GetDataFromChainlink () public {
    AggregatorV3Interface EuroPrice = AggregatorV3Interface (ContractAddress);
    (,int256 answer,,,) = EuroPrice.latestRoundData();
    LatestEuroPriceIndex = answer;
    }

//// Can be used to read the latest data fetched
// function ReadFetchedData () public view returns (int256) {
//    return LatestEuroPriceIndex;
//    }

//// Can be used to check the tradable pair name
// function ReadCurrencies () public view returns (string memory) {
//   return Currencies;
//     }

}

