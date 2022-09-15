/ user reserve table for off-chain updates and calculations
AAVE_POLYGON: ([user:(); reserve:()] debt:`float$(); collateral:`float$());

/ table to keep user health
USER_HEALTH: ([user:()] health:`float$(); timestamp:`timestamp$());

/ func to test if a file or object exists
exists: {not () ~ key x};

/ load data
if[exists `:USER_HEALTH;
    load `USER_HEALTH;
    ];
if[exists `:AAVE_POLYGON;
    load `AAVE_POLYGON;
    ];

/ hard-coded token dict
AAVE_TOKENS: (!) . flip(
    (`AAVE; lower "0xD6DF932A45C0f255f85145f286eA0b292B21C90B" );
    (`DAI; lower "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063");
    (`USDC; lower "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174");
    (`USDT; lower "0xc2132D05D31c914a87C6611C10748AEb04B58e8F");
    (`WBTC; lower "0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6");
    (`WETH; lower "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619");
    (`WMATIC; lower "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270"));

/ hard coded liquidation thresholds
AAVE_THRESHOLDS: (!) . flip(
    ( `AAVE; 0.65 );
    ( `DAI; 0.8 );
    ( `USDC; 0.85 );
    ( `USDT; 0.0 );
    ( `WBTC; 0.75 );
    ( `WETH; 0.825 );
    ( `WMATIC; 0.65 ) );

/ hard coded decimals
DECIMALS: (!) . flip(
    ( `AAVE; 18 );
    ( `DAI; 18 );
    ( `USDC; 6 );
    ( `USDT; 6 );
    ( `WBTC; 8 );
    ( `WETH; 18 );
    ( `WMATIC; 18 ) );


/ cast hex symbol or string to bytes for local storage
castToBytes:{[x]
    tp: type x;
    $[4h = tp; / bytes
        x;
        -4h = tp;   / byte
        enlist x;
        10h = tp; / string
        "X"$2 cut 2_x;
        -10h = tp; / char
        "X"$"0",x;
        -11h = tp;   / symbol
        "X"$2 cut 2_ string x;
        '`unknownType
        ]    
    };

/ insert function for user vault balance data from chain
aavePolygonInsertDebt:{[ iUser; iReserve; iDebt ]
    `AAVE_POLYGON upsert (!) . flip(
        (`user; castToBytes iUser);
        (`reserve; castToBytes iReserve);
        (`debt; iDebt)
        );
    };

/ insert function for user vault balance data from chain
aavePolygonInsertCollateral:{[ iUser; iReserve; iCollateral ]
    `AAVE_POLYGON upsert (!) . flip(
        (`user; castToBytes iUser);
        (`reserve; castToBytes iReserve);
        (`collateral; iCollateral)
        );
    };

aavePolygonInsert:{[ iUser; iReserve; iDebt; iCollateral ]
    `AAVE_POLYGON upsert (!) . flip(
        (`user; castToBytes iUser);
        (`reserve; castToBytes iReserve);
        (`debt; iDebt);
        (`collateral; iCollateral)
        );
    };

/ withdraw function from events
aavePolygonWithdraw:{[iUser; iReserve; amount]
    / only update if balances exist
    xUser: castToBytes iUser;
    xReserve: castToBytes iReserve;
    if[0 < count exec user from AAVE_POLYGON where user~\:xUser, reserve~\:xReserve;
        update collateral: collateral - amount from `AAVE_POLYGON where user~\:xUser, reserve~\:xReserve;
        ];
    };

/ deposit function from events
aavePolygonDeposit:{[iUser; iReserve; amount]
    / only update if balances exist
    xUser: castToBytes iUser;
    xReserve: castToBytes iReserve;
    if[0 < count exec user from AAVE_POLYGON where user~\:xUser, reserve~\:xReserve;
        update collateral: collateral + amount from `AAVE_POLYGON where user~\:xUser, reserve~\:xReserve;
        ];
    };

/ repay function from events
aavePolygonRepay:{[iUser; iReserve; amount]
    / only update if balances exist
    xUser: castToBytes iUser;
    xReserve: castToBytes iReserve;
    if[0 < count exec user from AAVE_POLYGON where user~\:xUser, reserve~\:xReserve;
        update debt: debt - amount from `AAVE_POLYGON where user~\:xUser, reserve~\:xReserve;
        ];
    };

/ borrow function from events
aavePolygonBorrow:{[iUser; iReserve; amount]
    / only update if balances exist
    xUser: castToBytes iUser;
    xReserve: castToBytes iReserve;
    xUser: string iUser;
    if[0 < count exec user from AAVE_POLYGON where user~\:xUser, reserve~\:xReserve;
        update debt: debt + amount from `AAVE_POLYGON where user~\:xUser, reserve~\:xReserve;
        ];
    };

/ liquidate function from events
aavePolygonLiquidate:{[iUser; iCollateral; iDebt; debtToCover; liquidatedCollateralAmount]
    / only update if balances exist
    xUser: castToBytes iUser;
    xCollateral: castToBytes iCollateral;
    xDebt: castToBytes iDebt;
    if[0 < count exec user from AAVE_POLYGON where user~\:xUser, reserve~\:xCollateral;
        update collateral: collateral - liquidatedCollateralAmount from `AAVE_POLYGON where user~\:xUser, reserve~\:xCollateral;
        update debt: debt - debtToCover from `AAVE_POLYGON where user~\:xUser, reserve~\:xDebt;
        ];
    };


/ get unhealthy users function
getUnhealthyUsers:{[]
    exec user from USER_HEALTH where health < 1.0
    };


/ get ref prices function for health calculations
getPrices:{[weth]
    coingecko: "https://api.coingecko.com/api/v3/coins/markets?ids=aave,ethereum,bitcoin,matic-network,dai,usd-coin,tether,avalanche-2&vs_currency=usd";
    priceData: .j.k .Q.hg coingecko;
    tokenPricesUsd: select symbol:`$upper symbol,current_price from priceData;
    tokenPricesDict:tokenPricesUsd[`symbol]!(tokenPricesUsd[`current_price]);
    tokenPricesDict[`WETH]:tokenPricesDict[`ETH];
    tokenPricesDict[`WBTC]:tokenPricesDict[`BTC];
    tokenPricesDict[`WMATIC]:tokenPricesDict[`MATIC];
    tokenPricesDict[`WAVAX]:tokenPricesDict[`AVAX];
    / return normalised price in matic
    (key tokenPricesDict)!(value tokenPricesDict) % tokenPricesDict[weth]
    };

getSymbolFromReserve:{[iReserve]
    AAVE_TOKENS?iReserve
    };


/ calculate health factor
updateHealth:{[]
    pricesDict: getPrices(`MATIC);
    / show pricesDict;
    users: exec distinct user from AAVE_POLYGON;
    healths: {[prices; iUser]
        reserves: 0!select from AAVE_POLYGON where user~\:iUser;
        totalColl: sum 0.0^{[prices;iReserve]
            sym: getSymbolFromReserve["0x", raze string iReserve`reserve];
            (prices[sym]) * `float$iReserve[`collateral]
            }[prices] each reserves;
        productSumCollLiq: sum 0.0^{[prices;iReserve]
            sym: getSymbolFromReserve["0x", raze string iReserve`reserve];
            (prices[sym]) * (`float$iReserve[`collateral]) * AAVE_THRESHOLDS[sym]
            }[prices] each reserves;
        avLiqThresh: productSumCollLiq % totalColl;

        totalDebt: sum 0.0^{[prices;iReserve] 
            sym: getSymbolFromReserve["0x", raze string iReserve`reserve];
            (`float$iReserve[`debt]) * prices[sym]
            }[prices] each reserves;
        health: $[totalDebt > 0.0;
            health: ( totalColl * avLiqThresh ) % totalDebt;
            2.0
            ];
        health
        }[pricesDict] each users;
    `USER_HEALTH upsert (
        [user: users]
        health: healths;
        timestamp: (count users)#.z.p );
    };


/ clean dead users
cleanDead:{[]
    / `USER_HEALTH set 0.0^USER_HEALTH;
    update 0.0^health from `USER_HEALTH;
    deadUsers: exec distinct user from USER_HEALTH where health <= 0.0;
    delete from `USER_HEALTH where health <= 0.0;
    delete from `AAVE_POLYGON where user in deadUsers; 
    };

/ repeater function runs on timer
.z.ts:{[]
    updateHealth[];
    cleanDead[];
    save `AAVE_POLYGON;
    save `USER_HEALTH;
    .Q.gc[]; / garbage cleaner
    };

/ timer in ms for repeater function
\t 4000
