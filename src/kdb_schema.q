//   Copyright (c) 2022 Manifold Finance, Inc.
//   This Source Code Form is subject to the terms of the Mozilla Public
//   License, v. 2.0. If a copy of the MPL was not distributed with this
//   file, You can obtain one at http://mozilla.org/MPL/2.0/.

tokens: ([tokenId: `int$()]
  token_symbol:`symbol$();
  token_address: ();
  decimals:`int$());

accounts: ([accountId: `int$()]
  address: ();
  is_externally_owned: `boolean$());

v2Routers: ([routerId: 0 1i]
  routerName: `SUSHISWAP`UNISWAP;
  routerAddress: (0xd9e1ce17f2641f24ae83637ab66a2cca9c378b9f; 0x7a250d5630b4cf539739df2c5dacb4c659f2488d)
  );

sushiPairs: ([]
  id: `long$();
  contract_address: ();
  base_token: `tokens$();
  quote_token: `tokens$();
  isActive: `boolean$()
  );

sushiLiquidity: ([]
  block_number: `long$();
  base_token: `tokens$();
  quote_token: `tokens$();
  base_reserve: (); // bigInt byte array
  quote_reserve: (); // bigInt byte array
  block_timestamp: `long$()
  );

uniPairs: ([]
  id: `long$();
  contract_address: ();
  base_token: `tokens$();
  quote_token: `tokens$();
  isActive: `boolean$()
  );

uniLiquidity: ([]
  block_number: `long$();
  base_token: `tokens$();
  quote_token: `tokens$();
  base_reserve: (); // bigInt byte array
  quote_reserve: (); // bigInt byte array
  block_timestamp: `long$()
  );


platformAccount: ([address:()]
  isActive:`boolean$()
  );

platformToken: ([]
  address: ();
  isActive: `boolean$()
  );

accountBalance: ([]
  block_number: `long$();
  accountId: `accounts$();
  nonce:();
  ether: () // bigInt byte array
  );

tokenBalance: ([]
  block_number: `long$();
  accountId: `accounts$();
  tokenId: `tokens$();
  balance: () // bigInt byte array
  );

swapType: ([swaptypeId: 0 1 2 3 4 5 6 7 8 9 10i];
  name: (
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
  getAmountsIn: 01010100000b);

// virtual swap pool
swaps:([]
  signer: (); // 20 byte array address
  tx_from: (); // 20 byte array address
  to: (); // 20 byte array address
  tx_hash: (); // 32 byte array
  signed_tx: ();
  nonce: ();
  tx_value: ();
  chainId: `int$();
  gasPrice: ();
  maxPriorityFeePerGas: ();
  maxFeePerGas: ();
  gasLimit: `long$();
  input: ();
  v: ();
  r: ();
  s: ();
  swaptypeId: `swapType$();
  path: (); // tokenId list
  amountIn: (); // bigint hex
  amountOut: (); // bigint hex
  swap_to: (); // 20 byte address output to swap result
  deadline: `int$()); // deadline in seconds

errors: ([errId: 0 1 2 3 4i]; errDesc: `passedDeadline`slippageTooLow`pathNotInLiquidity`bribeTooSmall`cancelledSwap);

// unbundled swaps e.g.
// passed deadline buffer (10 mins)
// slippage requirements too low
swapsError: ([]
  signer: (); // 20 byte array address
  tx_from: (); // 20 byte array address
  to: (); // 20 byte array address, maybe superfluous with swap_to
  tx_hash: (); // 32 byte array
  signed_tx: ();
  nonce: ();
  tx_value: ();
  chainId: `int$();
  gasPrice: ();
  maxPriorityFeePerGas: ();
  maxFeePerGas: ();
  gasLimit: `long$();
  input: ();
  v: ();
  r: ();
  s: ();
  swaptypeId: `swapType$();
  path: (); // tokenId list
  amountIn: (); // bigint hex
  amountOut: (); // bigint hex
  swap_to: (); // 20 byte address output to swap result
  deadline: `int$(); // deadline in seconds
  errId: `errors$();
  timestamp: `timestamp$());

bundles: ([]
  bundleid: `long$();
  signer: (); // 20 byte array address
  tx_from: (); // 20 byte array address
  to: (); // 20 byte array address
  tx_hash: (); // 32 byte array
  signed_tx: ();
  nonce: ();
  tx_value: ();
  chainId: `int$();
  gasPrice: ();
  maxPriorityFeePerGas: ();
  maxFeePerGas: ();
  gasLimit: `long$();
  input: ();
  v: ();
  r: ();
  s: ();
  swaptypeId: `swapType$();
  path: (); // tokenId list
  amountIn: (); // bigint hex
  amountOut: (); // bigint hex
  swap_to: (); // 20 byte address output to swap result
  deadline: `int$()); // deadline in seconds

bundlesSubmitted: ([]
  subbundleid: `long$();
  signer: (); // 20 byte array address
  tx_from: (); // 20 byte array address
  to: (); // 20 byte array address
  tx_hash: (); // 32 byte array
  signed_tx: ();
  nonce: ();
  tx_value: ();
  chainId: `int$();
  gasPrice: ();
  maxPriorityFeePerGas: ();
  maxFeePerGas: ();
  gasLimit: `long$();
  input: ();
  v: ();
  r: ();
  s: ();
  swaptypeId: `swapType$();
  path: (); // tokenId list
  amountIn: (); // bigint hex
  amountOut: (); // bigint hex
  swap_to: (); // 20 byte address output to swap result
  deadline: `int$()); // deadline in seconds

status: ([statusId: 0 1 2 3 4i]; status: `PENDING`SUBMITTED`ERROR`WON`DISTRIBUTED);

// bundle status schema
bundleStatus: ([]
  bundleid: `long$(); // unique bundle id
  statusId: `status$();  // PENDING / SUBMITTED / ERROR / WON / DISTRIBUTED
  profit_eth: ();
  bribe: ();
  profit: ();
  profit_token: `tokens$();
  block_number: `long$();
  timestamp: `timestamp$());

blockHeader: ([]
  block_number: `long$();
  block_hash: ();
  block_timestamp: `long$();
  base_fee: ()
  );

triangularArbs: ([
  path0: `int$();
  path1: `int$();
  path2: `int$();
  path3: `int$();
  router0: `int$();
  router1: `int$();
  router2: `int$()]
  amountIn: ();
  amountOut: ();
  profit: ();
  profit_eth: ());

dexArbs: ([
  path0: `int$();
  path1: `int$();
  path2: `int$();
  router0: `int$();
  router1: `int$()]
  amountIn: ();
  amountOut: ();
  profit: ();
  profit_eth: ());
