//   Copyright (c) 2022 Manifold Finance, Inc.
//   This Source Code Form is subject to the terms of the Mozilla Public
//   License, v. 2.0. If a copy of the MPL was not distributed with this
//   file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// ---------------------------------------------------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------------------------------------------------

// @kind data
// @desc Proto schema fields for platform transaction
PltTxFields: `sender`transaction;

// @kind data
// @desc Proto schema fields for swap type
SwpTxFields: (
  `erc20_approval;
  `swap_exact_tokens_for_tokens;
  `swap_tokens_for_exact_tokens;
  `swap_exact_eth_for_tokens;
  `swap_tokens_for_exact_ETH;
  `swap_exact_tokens_for_ETH;
  `swap_eth_for_exact_tokens;
  `swap_exact_tokens_for_tokens_supporting_fee_on_transfer_tokens;
  `swap_exact_eth_for_tokens_supporting_fee_on_transfer_tokens;
  `swap_exact_tokens_for_eth_supporting_fee_on_transfer_tokens;
  `swap_exact_tokens_for_tokens_with_flashloan;
  `swap_exact_tokens_for_tokens_with_flashloan_multi);

// @kind data
// @desc Index ref for Multi flashloan proto schema field
MultiFlashLoan: 10i;

// @kind data
// @desc Index ref for Single flashloan proto schema field
SingleFlashLoan: 9i;

// @kind data
// @desc Index ref for swap exact eth for tokens proto schema field
EthSwap: 2i;

// @kind data
// @desc Index refs for swaps that need approval txs
ApproveSwapList: 0 1 3 4 6 8i;

// @kind data
// @desc Proto schema fields for platform transaction combined with swap type
PltTxFields: PltTxFields,SwpTxFields;

// @kind data
// @desc platform account address in use for signing
PlAcc: 0x0000;

// @kind data
// @desc platform account nonce
PlAccNonce: 0x0000;

// @kind data
// @desc ether balance of active platform account
PlAccEth: 0x0000;

// @kind data
// @desc Next base fee for a block
NextBaseFee: "0x0000";


// @kind data
// @desc Last base fee for a block
LastBaseFee: 0x0000;

// @kind data
// @desc Updated value of latest block number
LatestBlock: 0j;

// @kind data
// @desc Updated value of liquidity count for dex paths
DexLiquidityCount: 0j;

// @kind data
// @desc Updated value of liquidity count for tri paths
TriLiquidityCount: 0j;

// @kind data
// @desc Value of WETH token Id
WethId: ();

// @kind data
// @desc Aave related addresses
AaveAssetAddresses: (
  0xdac17f958d2ee523a2206206994597c13d831ec7;
  0x2260fac5e5542a773aa44fbcfedf7c193bc2c599;
  0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2;
  0x0bc529c00c6401aef6d220be8c6ea1667f6ad93e;
  0xe41d2489571d322189246dafa5ebde1f4699f498;
  0x1f9840a85d5af5bf1d1762f925bdaddc4201f984;
  0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9;
  0x0d8775f648430679a709e98d2b0cb6250d2887ef;
  0x4fabb145d64652a948d72533023f6e7a623c7c53;
  0x6b175474e89094c44da98b954eedeac495271d0f;
  0xf629cbd94d3791c9250152bd8dfbdf380e2a3b9c;
  0xdd974d5c2e2928dea5f71b9825b8b646686bd200;
  0x514910771af9ca656af840dff83e8264ecf986ca;
  0x0f5d2fb29fb7d3cfee444a200298f468908cc942;
  0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2;
  0x408e41876cccdc0f92210600ef50372656052a38;
  0xc011a73ee8576fb46f5e1c5751ca3b9fe0af2a6f;
  0x57ab1ec28d129707052df4df418d58a2d46d5f51;
  0x0000000000085d4780b73119b644ae5ecd22b376;
  0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48;
  0xd533a949740bb3306d119cc777fa900ba034cd52;
  0x056fd409e1d7a124bd7017459dfea2f387b6d5cd;
  0xba100000625a3754423978a60c9317c58a424e3d;
  0x8798249c2e607446efb7ad49ec89dd1865ff4272;
  0xd5147bc8e386d91cc5dbe72099dac6c9b99276f5);

// @kind data
// @desc List to capture and cache reserves for which we have liquidity data
ReserveList: ();

// @kind data
// @desc Table to save possibly triangular arb paths
TrigPaths: 0#enlist `path0`path1`path2`path3!1 2 3 4i;

// @kind data
// @desc Table to save possibly dex arb paths
DexPaths: 0#enlist `path0`path1`path2!1 2 3i;

// @kind data
// @desc Value of HDB handle
HandleHDB: hopen `:unix://5003;

// @kind data
// @desc Value of producer handle
HandleProducer: hopen `:unix://5004;

// @kind data
// @desc Table to simulate liquidity impacts through bundle txs
SimulatedReserves: ([]
  tracking_number: `int$();
  routerId: `int$();
  base_token: `tokens$();
  quote_token: `tokens$();
  base_reserve: (); // bigInt byte array
  quote_reserve: ()
  );
