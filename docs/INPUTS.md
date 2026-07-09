# Input Reference

This file summarizes the main input groups exposed by `MQL5/Experts/3711_Single_EA.mq5`.

## Symbol

| Input | Default | Purpose |
| --- | --- | --- |
| `InpTradeSymbol` | blank | Blank uses the chart symbol. Set a symbol name to trade a fixed instrument. |
| `InpSignalTf1` | `PERIOD_H1` | Primary signal timeframe and new-bar trigger. |
| `InpSignalTf2` | `PERIOD_M30` | Secondary stochastic context timeframe. |
| `InpSignalTf3` | `PERIOD_M15` | Third stochastic context timeframe. |
| `InpSignalTf4` | `PERIOD_M5` | Fourth stochastic context timeframe. |
| `InpDivergenceTf` | `PERIOD_M15` | Timeframe used for divergence detection. |
| `InpUseClosedBarSignals` | `true` | Uses closed candles for signals when enabled. |

## Stochastic And Divergence

| Input | Default | Purpose |
| --- | --- | --- |
| `InpKPeriod` | `13` | Stochastic K period. |
| `InpDPeriod` | `3` | Stochastic D period. |
| `InpSlowing` | `3` | Stochastic slowing. |
| `InpStrongBuyLevel` | `20` | Oversold reset threshold for buy logic. |
| `InpStrongSellLevel` | `80` | Overbought reset threshold for sell logic. |
| `InpContinuationBuyMax` | `55` | Maximum K value for continuation buy cross. |
| `InpContinuationSellMin` | `45` | Minimum K value for continuation sell cross. |
| `InpRSIPeriod` | `13` | RSI period used for divergence checks. |
| `InpDivergenceLookback` | `34` | Lookback range for swing divergence. |
| `InpRequireRsiDivergence` | `false` | Requires RSI divergence alignment. |
| `InpRequireStochDivergence` | `false` | Requires stochastic divergence alignment. |
| `InpRequireDualDivergence` | `false` | Requires both RSI and stochastic divergence alignment. |

## Formula Pack

| Input | Default | Purpose |
| --- | --- | --- |
| `InpUseFormulaPack` | `true` | Enables extra structure scoring. |
| `InpFormulaTf` | `PERIOD_CURRENT` | Formula timeframe; current means primary signal timeframe. |
| `InpATRPeriod` | `14` | ATR period for stops, trailing, and buffers. |
| `InpBandsPeriod` | `20` | Bollinger Bands period. |
| `InpBandsDeviation` | `2.0` | Bollinger Bands deviation. |
| `InpSwingLookback` | `34` | Swing scan lookback. |
| `InpSwingDepth` | `2` | Swing confirmation depth. |
| `InpBosAtrBuffer` | `0.08` | ATR buffer for break-of-structure detection. |
| `InpLimitAtrBuffer` | `0.12` | ATR buffer for limit-entry zone. |
| `InpFormulaWeight` | `1.0` | Weight applied to formula score. |

## Candle C1/C2

| Input | Default | Purpose |
| --- | --- | --- |
| `InpCandleMode` | `CANDLE_SOFT` | Candle confirmation mode. |
| `InpCandleBoxLookback` | `8` | Lookback box used before C1 breakout. |
| `InpCandleMinBodyAtr` | `0.18` | Minimum C1 body as ATR fraction. |
| `InpCandleBreakBufferAtr` | `0.02` | ATR buffer for C2 break. |
| `InpCandleMaxChaseAtr` | `0.60` | Maximum allowed C2 chase distance. |

## Entry And Risk

| Input | Default | Purpose |
| --- | --- | --- |
| `InpAllowTrading` | `true` | Master trading switch. |
| `InpTradeDirection` | `TRADE_DIRECTION_BOTH` | Allows both, long-only, or short-only trading. |
| `InpEntryMode` | `ENTRY_MARKET_ONLY` | Market, limit, or market-or-limit execution. |
| `InpMinScore` | `4.0` | Minimum score required for a valid trade. |
| `InpRiskPercent` | `0.50` | Equity percentage risked per trade. |
| `InpRiskMoneyOverride` | `0.0` | Fixed money risk override. |
| `InpRR` | `2.40` | Reward-to-risk target. |
| `InpMinStopAtr` | `0.70` | Minimum stop distance as ATR fraction. |
| `InpSwingStopAtrBuffer` | `0.18` | Extra ATR buffer beyond swing stop. |
| `InpMaxSpreadPoints` | `0` | Maximum spread in points; zero disables filter. |
| `InpMaxOpenPositions` | `1` | Maximum open/pending positions for this EA magic number. |
| `InpOneTradePerSignalBar` | `true` | Prevents repeated entries on the same signal bar. |
| `InpMagic` | `3711001` | Magic number used to identify EA positions and orders. |
| `InpDeviationPoints` | `20` | Maximum trade deviation in points. |

## Management And Research

| Input | Default | Purpose |
| --- | --- | --- |
| `InpUseBreakEven` | `true` | Enables break-even stop movement. |
| `InpBreakEvenAtR` | `1.00` | R multiple where break-even activates. |
| `InpBreakEvenLockR` | `0.10` | R amount locked after break-even. |
| `InpUseAtrTrail` | `true` | Enables ATR trailing stop. |
| `InpTrailStartR` | `1.50` | R multiple where trailing activates. |
| `InpTrailAtrMult` | `1.20` | ATR multiplier for trailing distance. |
| `InpWriteCsv` | `true` | Writes signal data to CSV for research. |
| `InpCsvName` | `3711_Single_EA_Backtest.csv` | CSV file name used by MetaTrader. |
