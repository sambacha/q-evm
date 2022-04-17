#!/usr/bin/env q

//   Copyright (c) 2022 Manifold Finance, Inc.
//   This Source Code Form is subject to the terms of the Mozilla Public
//   License, v. 2.0. If a copy of the MPL was not distributed with this
//   file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// bundler.q
// receive latest block data and swap requests
// aggregate by block target, market, side
// order by tx amount desc
// calculate net
// interlace buy / sell orders for minimum slippage with largest orders first
// estimate max arb for slippage requirements
// produce bundles
// pick top estimated profit bundle per block and submit to producer
// dissipate un submitted txs back to the pool for re-aggregation
// set timer function for syncing hdb bundle data

// start with
// q bundler.q -p 5002 -s 2

// load libraries
\l domain/kdb_schema.q
\l domain/proto.q
\l utils/hex.q
\l utils/assert.q
\l utils/atomize.q
\l utils/os.q
\l utils/str.q
\l log4q.q
\l abi.q
\l quartic.q

INFO "msg=\"Initializing bundler\" id=init";

/ load bundle helpers
\l utils/constants.q
\l utils/globals.q
\l utils/state.q
\l utils/simulate.q
\l utils/strategies.q
\l utils/format.q
\l utils/store.q

// @kind function
// @desc Submits a bundle to kafka
// @param kfkBundle {dict} `serialBundle`serialKey!(serialised Bundle; serialised Key)
submitBundle: {[kfkBundle]
  INFO "msg=\"Publishing bundle to kafka\"";
  assert[ type kfkBundle; =; 99h; "bundle must be a dictionary" ];
  assert[ all `serialBundle`serialKey in key kfkBundle; =; 1b; "bundle dictionary must have keys serialBundle & serialKey" ];
  HandleProducer (`publishBundle; kfkBundle`serialBundle; kfkBundle`serialKey); // sync req to flush queue
  };


// @kind function
// @desc Triggered by new liquidity data arrival
processBlock: {
  cleanBundles[];
  cleanSwaps[];
  updatePlatAccState[];
  updateNextBaseFee[];

  DEBUG (
    "id=processBlock platform_account=%1 account_nonce=%2 ether=%3 next_base_fee=%4";
    (PlAcc; "J"$convertToDec PlAccNonce; convertHexStrToFloat PlAccEth; convertHexStrToFloat NextBaseFee));

  // select distinct user swap paths
  swapGroups: select sum chainId by to, path from swaps;
  paths: (key swapGroups)[`path];
  rtrs: (key swapGroups)[`to];
  numPaths: count paths;
  if[0 < numPaths;
    i: 0;
    do[numPaths;
      indy: exec first i from (key swapGroups) where path~\:(reverse paths[i]), to~\:rtrs[i];
      if[ -1 < indy; paths: paths _ indy; rtrs: rtrs _ indy; ];
      i: i+1]; / remove reverse paths, as they are aggregated in calcBundle
    DEBUG ("id=processBlock num_sandwich_bundles_to_process=%1"; i);

    / 1. sandwich batch / swaps
    calcBundle'[rtrs; paths]; / batch and calculate all possible bundles grouped by path
    if[DISABLE_SANDWICHES = 0b;
      pendingBundles: select from bundleStatus where 0i=statusId.statusId; / Get pending bundles
      numBundles: count pendingBundles;    / bundles count
      if[numBundles > 0;                    / profitable bundle produced
        topBundleStatus: first sortTableHexDesc[pendingBundles; `profit_eth]; / get top bundle by profit in eth
        INFO ("id=processBlock num_profitable_sandwich_bundles=%1"; (numBundles));
        INFO ("msg=\"Best sandwich bundle\" id=processBlock est_profit_eth=%1"; (convertHexStrToFloat topBundleStatus`profit_eth)%1e18);
        assert[ cmp[ topBundleStatus`profit_eth; 0x0000 ]; >; 0i; "top bundle must be profitable" ];
        kfkBundle: formatBundle[topBundleStatus]; / format bundle to submit to kafka
        submitBundle[kfkBundle];                  / submit top bundle
        saveBundle[topBundleStatus];              / save bundle status to disk
        ];
      ];

    / 2. back-running
    backRunArbInfo: calcBackRunDexArbs[];
    backRunProfitable: backRunArbInfo[0];
    if[0i < backRunProfitable;                  / Is top dex arb profitable?
      topBackRunDex: backRunArbInfo[1];                / top dex arb record
      kfkBundle: formatBackRunDexBundle[ topBackRunDex]; / format bundle to submit to kafka
      submitBundle[ kfkBundle ];
      saveBackRunDexBundle[topBackRunDex];              / save bundle status to disk
      ];
    ];
  / 3. simple state dex arbs
  dexArbInfo: calcDexArbs[];
  dexProfitable: dexArbInfo[0];
  if[0i < dexProfitable;                  / Is top dex arb profitable?
    topDex: dexArbInfo[1];                / top dex arb record
    kfkBundle: formatDexBundle[ topDex]; / format bundle to submit to kafka
    submitBundle[ kfkBundle ];
    saveDexBundle[topDex];              / save bundle status to disk
    ];
  / 4. state tri arbs
  triArbInfo: calcTriArbs[];
  trigProfitable: triArbInfo[0];
  if[0i < trigProfitable;                  / Is top tri arb profitable?
    topTrig: triArbInfo[1];                / top triangular arb record
    kfkBundle: formatTriBundle[ topTrig]; / format bundle to submit to kafka
    submitBundle[ kfkBundle ];
    saveTriBundle[topTrig];              / save bundle status to disk
    ];

  / cleanup
  cleanData[];
  };

// @kind function
// @desc Sets latest block number and calls processBlock
// @param blkNum {long} current eth block number
setLatestBlock: {[blkNum]
  bNum: `long$blkNum;
  INFO ("msg=\"Received new block data\" id=setLatestBlock received_block_number=%1 previous_latest_block=%2"; (bNum; LatestBlock));

  updateLatestBlockNumber[bNum];

  // Check WETH existence
  if[not isWethIdSet[]; updateWethId[];];

  // Only process block if WETH is set and we have latest information
  if[all (1b = isWethIdSet[]), 1b = shouldProcessBlock[];
    processBlock[];
    ];
  };

// @kind function
// @desc Loads selective state from HDB on startup
loadState: {
  DEBUG "msg=\"Loading HDB state\" id=loadState";

  accs: HandleHDB (`getAccounts;`);
  if[0 < count accs;
    `accounts insert accs;
    ];

  toks: HandleHDB (`getTokens;`);
  if[0 < count toks;
    `tokens insert toks;
    if[not isWethIdSet[]; updateWethId[];];
    ];

  pairs: HandleHDB (`getPairs;`);
  if[0 < count pairs;
    `sushiPairs insert pairs;
    ];

  pltAcc: HandleHDB (`getpltAcc;`);
  if[0 < count pltAcc;
    `platformAccount upsert pltAcc;
    ];

  pltToks: HandleHDB (`getpltToks;`);
  if[0 < count pltToks;
    `platformToken insert pltToks;
    ];

  };

/ load HDB state on startup
loadState[];
