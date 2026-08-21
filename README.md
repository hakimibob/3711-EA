# 3711 Single EA - Professional Multi-Timeframe Trading System

![Version](https://img.shields.io/badge/version-1.01-blue)
![Platform](https://img.shields.io/badge/platform-MetaTrader%205-orange)
![License](https://img.shields.io/badge/license-All%20Rights%20Reserved-red)

**3711 Single EA** is an advanced MetaTrader 5 Expert Advisor designed for professional single-symbol technical analysis, backtesting, and live trading. This sophisticated trading system combines multi-timeframe stochastic signals, divergence detection, ATR-based risk management, and intelligent candle confirmation patterns to execute high-probability trades.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [How It Works](#how-it-works)
- [Repository Layout](#repository-layout)
- [Installation](#installation)
- [Configuration Guide](#configuration-guide)
- [Backtest Guidelines](#backtest-guidelines)
- [Trading Logic Deep Dive](#trading-logic-deep-dive)
- [Risk Management](#risk-management)
- [CSV Research Output](#csv-research-output)
- [GitHub Release Checklist](#github-release-checklist)
- [License](#license)
- [Risk Notice](#risk-notice)
- [Support & Contributions](#support--contributions)

---

## 🎯 Overview

The **3711 Single EA** implements a comprehensive trading strategy built around four core pillars:

1. **Multi-Timeframe Signal Stack** - Analyzes H1, M30, M15, and M5 timeframes simultaneously
2. **Stochastic Reset & Cross Logic** - Identifies overbought/oversold conditions with continuation patterns
3. **Divergence Detection** - Optional RSI and/or Stochastic divergence confirmation
4. **Formula Pack Structure Analysis** - ATR, Bollinger Bands, and swing structure scoring
5. **Candle Confirmation (C1/C2)** - Advanced two-candle pattern validation
6. **Professional Risk Management** - Fixed percentage risk, break-even, and ATR trailing stops

---

## ✨ Key Features

### Signal Generation
- ✅ **4-Timeframe Stochastic Stack**: H1 → M30 → M15 → M5 progressive signal confirmation
- ✅ **Customizable Stochastic Parameters**: K-period, D-period, slowing, method, and price type
- ✅ **Strong Buy/Sell Levels**: Configurable thresholds (default: 20/80)
- ✅ **Continuation Zones**: Smart pullback entry detection (45-55% stochastic range)

### Divergence Detection
- 🔍 **RSI Divergence**: Bullish/Bearish divergence on configurable timeframe
- 🔍 **Stochastic Divergence**: Independent stochastic divergence detection
- 🔍 **Dual Divergence Mode**: Require both RSI AND Stochastic divergence simultaneously

### Formula Pack (Structure Analysis)
- 📊 **ATR-Based Volatility**: Dynamic support/resistance using Average True Range
- 📊 **Bollinger Bands**: 20-period bands with configurable deviation
- 📊 **LWMA Channels**: 5 & 10-period Linear Weighted Moving Average channels
- 📊 **Swing Structure**: Automated swing high/low detection (34-bar lookback)
- 📊 **Break of Structure (BOS)**: Confirmed trend continuation signals
- 📊 **Limit Entry Zones**: Precision entry levels with ATR buffers

### Candle Confirmation System
- 🕯️ **C1 Armed Bar**: Setup candle with minimum body size (0.18 ATR)
- 🕯️ **C2 Break Bar**: Confirmation candle breaking C1 high/low
- 🕯️ **Three Modes**: OFF / SOFT (partial) / HARD (strict)
- 🕯️ **Anti-Chase Protection**: Maximum chase distance (0.60 ATR)

### Execution & Risk Management
- 💰 **Three Entry Modes**: Market Only / Limit Only / Market or Limit
- 💰 **Fixed Risk Position Sizing**: 0.50% default risk per trade
- 💰 **Money Override**: Optional fixed monetary risk instead of percentage
- 💰 **Dynamic Stop Loss**: ATR-based minimum stop (0.70 ATR) + swing buffer
- 💰 **Risk-Reward Ratio**: Default 2.40R target
- 💰 **Spread Filter**: Maximum spread protection in points
- 💰 **Position Limits**: Maximum concurrent positions control
- 💰 **One Trade Per Signal Bar**: Prevents overtrading

### Trade Management
- 🛡️ **Break-Even**: Auto-move SL at 1.00R profit (locks 0.10R)
- 🛡️ **ATR Trailing Stop**: Activates at 1.50R, trails at 1.20 ATR
- 🛡️ **Limit Order Expiry**: 240-minute maximum pending order lifetime
- 🛡️ **Limit Travel Filter**: Minimum/maximum ATR travel validation

### Research & Logging
- 📝 **CSV Export**: Comprehensive backtest data logging
- 📝 **Signal Diagnostics**: Detailed reason codes for every signal
- 📝 **Formula State Tracking**: Complete structure analysis output
- 📝 **Candle State Monitoring**: C1/C2 status tracking

---

## ⚙️ How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    3711 Single EA Flow                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Multi-TF Stochastic Scan                                 │
│     H1 → M30 → M15 → M5 (configurable)                      │
│                                                              │
│  2. Divergence Check (Optional)                              │
│     RSI Div?  Stoch Div?  Dual Div?                         │
│                                                              │
│  3. Formula Pack Analysis                                    │
│     ATR • Bollinger • LWMA • Swing Structure • BOS          │
│                                                              │
│  4. Candle Confirmation (Optional)                           │
│     C1 Armed → C2 Break                                      │
│                                                              │
│  5. Scoring & Threshold                                      │
│     Minimum Score: 4.0 (configurable)                        │
│                                                              │
│  6. Risk Calculation                                         │
│     Position Size = (Equity × Risk%) / Stop Distance        │
│                                                              │
│  7. Entry Execution                                          │
│     Market / Limit / Market-or-Limit                         │
│                                                              │
│  8. Trade Management                                         │
│     Break-Even → ATR Trail → TP/SL Exit                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Layout

```text
/workspace/
├── MQL5/
│   └── Experts/
│       ├── 3711_Single_EA.mq5              # Main EA source code (1,486 lines)
│       └── 3711_Single_EA_Backup_Original.mq5  # Original backup version
├── docs/
│   ├── INPUTS.md                           # Complete input parameters documentation
│   └── NAME_IDEAS.md                       # Naming conventions and ideas
├── CHANGELOG.md                            # Version history and updates
├── README.md                               # This file - comprehensive guide
└── *.csv                                   # Backtest output files (gitignored)
```

---

## 📥 Installation

### Step-by-Step Installation

1. **Copy EA File**
   ```bash
   Copy `MQL5/Experts/3711_Single_EA.mq5` 
   → MetaTrader 5 Data Folder/MQL5/Experts/
   ```

2. **Compile in MetaEditor**
   - Open MetaEditor (F4 in MT5)
   - Navigate to `Experts/3711_Single_EA.mq5`
   - Click **Compile** (F7)
   - Verify: `0 errors, 0 warnings`

3. **Attach to Chart**
   - Open MetaTrader 5
   - Drag `3711 Single EA` from Navigator → Expert Advisors
   - Drop onto desired chart
   - Enable **Auto Trading** button

4. **Configure Settings**
   - Adjust inputs per your strategy (see [Configuration Guide](#configuration-guide))
   - **IMPORTANT**: Keep `InpAllowTrading=false` during initial testing

5. **Run Backtest** (Optional)
   - Open Strategy Tester (Ctrl+R)
   - Select `3711 Single EA`
   - Configure symbol, timeframe, date range
   - Run optimization if needed

---

## ⚙️ Configuration Guide

### Symbol & Timeframe Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| `InpTradeSymbol` | `""` (Chart Symbol) | Custom symbol for trading (blank = current chart) |
| `InpSignalTf1` | `PERIOD_H1` | Primary signal timeframe |
| `InpSignalTf2` | `PERIOD_M30` | Secondary signal timeframe |
| `InpSignalTf3` | `PERIOD_M15` | Tertiary signal timeframe |
| `InpSignalTf4` | `PERIOD_M5` | Fastest signal timeframe |
| `InpDivergenceTf` | `PERIOD_M15` | Divergence detection timeframe |
| `InpUseClosedBarSignals` | `true` | Use closed bar signals (repaint-safe) |

### Stochastic & Divergence Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| `InpKPeriod` | `13` | Stochastic %K period |
| `InpDPeriod` | `3` | Stochastic %D period |
| `InpSlowing` | `3` | Stochastic slowing factor |
| `InpStochMethod` | `MODE_SMA` | Stochastic MA method |
| `InpStochPrice` | `STO_LOWHIGH` | Stochastic price calculation |
| `InpStrongBuyLevel` | `20` | Oversold threshold (buy zone) |
| `InpStrongSellLevel` | `80` | Overbought threshold (sell zone) |
| `InpContinuationBuyMax` | `55` | Max stochastic for buy pullbacks |
| `InpContinuationSellMin` | `45` | Min stochastic for sell pullbacks |
| `InpRSIPeriod` | `13` | RSI period for divergence |
| `InpDivergenceLookback` | `34` | Bars to scan for divergence |
| `InpRequireRsiDivergence` | `false` | Force RSI divergence requirement |
| `InpRequireStochDivergence` | `false` | Force Stochastic divergence requirement |
| `InpRequireDualDivergence` | `false` | Require BOTH divergences |

### Formula Pack (Structure Analysis)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `InpUseFormulaPack` | `true` | Enable structure analysis |
| `InpFormulaTf` | `PERIOD_CURRENT` | Formula calculation timeframe |
| `InpATRPeriod` | `14` | ATR period |
| `InpBandsPeriod` | `20` | Bollinger Bands period |
| `InpBandsDeviation` | `2.0` | Bollinger Bands deviation |
| `InpSwingLookback` | `34` | Swing detection lookback |
| `InpSwingDepth` | `2` | Swing depth (bars each side) |
| `InpBosAtrBuffer` | `0.08` | Break of structure ATR buffer |
| `InpLimitAtrBuffer` | `0.12` | Limit entry ATR buffer |
| `InpFormulaWeight` | `1.0` | Formula score multiplier |

### Candle Confirmation (C1/C2)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `InpCandleMode` | `CANDLE_SOFT` | OFF / SOFT / HARD confirmation |
| `InpCandleBoxLookback` | `8` | Bars to find C1 setup |
| `InpCandleMinBodyAtr` | `0.18` | Minimum C1 body size (in ATR) |
| `InpCandleBreakBufferAtr` | `0.02` | C2 break confirmation buffer |
| `InpCandleMaxChaseAtr` | `0.60` | Maximum chase distance from signal |

### Entry & Risk Management

| Parameter | Default | Description |
|-----------|---------|-------------|
| `InpAllowTrading` | `true` | Enable live order execution |
| `InpTradeDirection` | `BOTH` | LONG_ONLY / SHORT_ONLY / BOTH |
| `InpEntryMode` | `MARKET_ONLY` | MARKET / LIMIT / MARKET_OR_LIMIT |
| `InpMinScore` | `4.0` | Minimum signal score to trade |
| `InpRiskPercent` | `0.50` | Risk per trade (% of equity) |
| `InpRiskMoneyOverride` | `0.0` | Fixed money risk (0 = use %) |
| `InpRR` | `2.40` | Risk-Reward ratio for TP |
| `InpMinStopAtr` | `0.70` | Minimum stop loss (in ATR) |
| `InpSwingStopAtrBuffer` | `0.18` | Additional swing buffer for SL |
| `InpMaxSpreadPoints` | `0` | Maximum allowed spread (0 = unlimited) |
| `InpMaxOpenPositions` | `1` | Maximum concurrent positions |
| `InpOneTradePerSignalBar` | `true` | One trade per signal bar |
| `InpLimitExpiryMinutes` | `240` | Limit order expiry time |
| `InpLimitMinTravelAtr` | `0.12` | Minimum ATR travel for limit |
| `InpLimitMaxTravelAtr` | `0.95` | Maximum ATR travel for limit |
| `InpMagic` | `3711001` | Unique magic number for orders |
| `InpDeviationPoints` | `20` | Slippage tolerance in points |

### Trade Management & Research

| Parameter | Default | Description |
|-----------|---------|-------------|
| `InpUseBreakEven` | `true` | Enable break-even function |
| `InpBreakEvenAtR` | `1.00` | Move SL to BE at this R multiple |
| `InpBreakEvenLockR` | `0.10` | Lock profit when moving to BE |
| `InpUseAtrTrail` | `true` | Enable ATR trailing stop |
| `InpTrailStartR` | `1.50` | Start trailing at this R multiple |
| `InpTrailAtrMult` | `1.20` | Trailing distance (ATR multiplier) |
| `InpWriteCsv` | `true` | Enable CSV research logging |
| `InpCsvName` | `"3711_Single_EA_Backtest.csv"` | Output CSV filename |

---

## 📊 Backtest Guidelines

### Recommended Testing Protocol

1. **Initial Symbol Testing**
   - Set `InpAllowTrading = false`
   - Test on major pairs: EURUSD, GBPUSD, USDJPY, XAUUSD
   - Use 1-year historical data minimum

2. **Timeframe Optimization**
   - Default stack: H1 → M30 → M15 → M5 works well for most pairs
   - For scalping: Consider M15 → M10 → M5 → M1
   - For swing: Consider H4 → H2 → H1 → M30

3. **Spread Sensitivity**
   - Set realistic `InpMaxSpreadPoints` based on your broker
   - Typical values: EURUSD (10-15), GBPJPY (20-30), XAUUSD (30-50)

4. **Risk Calibration**
   - Start with `InpRiskPercent = 0.50` (conservative)
   - Test with `InpRiskMoneyOverride` for fixed monetary risk
   - Never exceed 2% risk per trade without extensive testing

5. **CSV Analysis**
   - Enable `InpWriteCsv = true`
   - Review signal quality, win rate, average R per trade
   - Identify best/worst performing market conditions

### Performance Metrics to Track

- **Win Rate**: Target 45-60% (with 2.4R RR, this is profitable)
- **Average R per Trade**: Should be positive after spreads/commissions
- **Maximum Drawdown**: Keep below 20% for sustainable trading
- **Profit Factor**: Aim for > 1.3 (gross profit / gross loss)
- **Recovery Factor**: Net profit / Max drawdown

---

## 🧠 Trading Logic Deep Dive

### Signal Scoring System

The EA calculates a composite score based on multiple factors:

```
Total Score = Stochastic Alignment + Divergence Bonus + Formula Score + Candle Confirmation

Minimum Required: 4.0 points (configurable via InpMinScore)
```

**Scoring Breakdown:**
- **Stochastic Stack Alignment**: 1 point per aligned timeframe (max 4 points)
- **RSI Divergence**: +1 to +2 points (if enabled and detected)
- **Stochastic Divergence**: +1 to +2 points (if enabled and detected)
- **Formula Structure Score**: 0 to 3 points based on BOS, bands, swings
- **Candle Confirmation**: +1 point (if C1/C2 pattern confirmed)

### Entry Execution Modes

**Market Only (`ENTRY_MARKET_ONLY`)**
- Executes immediately at current market price
- Best for strong momentum signals
- Higher slippage risk during news events

**Limit Only (`ENTRY_LIMIT_ONLY`)**
- Places limit order at calculated retracement level
- Waits for price to come to entry zone
- Better risk-reward, but may miss fast moves
- Expires after `InpLimitExpiryMinutes`

**Market or Limit (`ENTRY_MARKET_OR_LIMIT`)**
- Attempts limit order first
- Converts to market if price travels too far (`InpLimitMaxTravelAtr`)
- Balances precision and execution certainty

### Stop Loss Calculation

```
Initial SL = Entry Price ± max(
    MinStopAtr × ATR,
    SwingHigh/Low ± SwingStopAtrBuffer × ATR
)

Where:
- ATR = Current 14-period Average True Range
- SwingHigh/Low = Recent swing structure level
- Buffer = Additional safety margin
```

### Take Profit Calculation

```
TP = Entry Price ± (Stop Distance × InpRR)

Default RR = 2.40
Example: 50 pip SL → 120 pip TP
```

### Break-Even Logic

When position reaches `InpBreakEvenAtR` (default 1.0R):
```
New SL = Entry Price ± (LockR × Stop Distance)

Default LockR = 0.10
Result: SL moved to entry + 10% of initial risk locked
```

### ATR Trailing Stop

When position reaches `InpTrailStartR` (default 1.5R):
```
Trailing SL = Highest High since trail start - (TrailAtrMult × ATR)

Default TrailAtrMult = 1.20
Updates on every tick for open positions
```

---

## 🛡️ Risk Management

### Position Sizing Formula

**Percentage Risk Mode:**
```
LotSize = (Equity × RiskPercent / 100) / (StopDistance × TickValue)

Example:
- Equity: $10,000
- RiskPercent: 0.50%
- StopDistance: 50 pips
- TickValue: $10 per pip (EURUSD standard lot)

LotSize = ($10,000 × 0.005) / (50 × $10) = $50 / $500 = 0.10 lots
```

**Fixed Money Risk Mode:**
```
LotSize = RiskMoneyOverride / (StopDistance × TickValue)

Example:
- RiskMoneyOverride: $100
- StopDistance: 50 pips
- TickValue: $10 per pip

LotSize = $100 / (50 × $10) = $100 / $500 = 0.20 lots
```

### Built-In Safety Features

✅ **Spread Filter**: Rejects trades if spread exceeds `InpMaxSpreadPoints`  
✅ **Position Limits**: Caps open positions at `InpMaxOpenPositions`  
✅ **One Trade Per Bar**: Prevents overtrading on same signal bar  
✅ **Opposite Position Check**: Avoids hedging unless explicitly allowed  
✅ **Magic Number Isolation**: Only manages trades with matching magic number  
✅ **Volume Normalization**: Automatically adjusts lots to broker's min/max/step  

---

## 📝 CSV Research Output

When `InpWriteCsv = true`, the EA generates detailed CSV logs with columns:

```csv
DateTime,Symbol,Side,EntryPrice,StopLoss,TakeProfit,LotSize,RiskMoney,Score,
Stoch1,Stoch2,Stoch3,Stoch4,RsiDiv,StochDiv,FormulaState,CandleState,Reason,
ExitType,ExitPrice,ExitDateTime,ProfitPoints,ProfitMoney,RAchieved
```

**Column Descriptions:**
- `DateTime`: Signal generation timestamp
- `Symbol`: Traded instrument
- `Side`: BUY or SELL
- `EntryPrice`: Execution price
- `StopLoss`: Initial stop loss level
- `TakeProfit`: Target profit level
- `LotSize`: Position size in lots
- `RiskMoney`: Monetary risk on trade
- `Score`: Total signal score
- `Stoch1-4`: Stochastic values on H1/M30/M15/M5
- `RsiDiv`: RSI divergence state (Bullish/Bearish/None)
- `StochDiv`: Stochastic divergence state
- `FormulaState`: Structure analysis summary
- `CandleState`: C1/C2 confirmation status
- `Reason`: Detailed signal reasoning
- `ExitType`: TP / SL / BE / Trail / Manual
- `ExitPrice`: Closing price
- `ExitDateTime`: Close timestamp
- `ProfitPoints`: Pips gained/lost
- `ProfitMoney`: Monetary P&L
- `RAchieved`: Actual R multiple achieved

CSV files are saved to: `MQL5/Files/` directory (MT5 default location)

---

## ✅ GitHub Release Checklist

Before publishing or sharing this EA:

- [ ] **Compilation**: Verify zero errors/warnings in MetaEditor
- [ ] **Backtest Completed**: Run minimum 1-year backtest with CSV logging
- [ ] **Forward Test**: Validate on demo account (minimum 2 weeks)
- [ ] **Spread Settings**: Document recommended `InpMaxSpreadPoints` per symbol
- [ ] **Risk Disclosure**: Ensure users understand this is not profit-guaranteed
- [ ] **Screenshots**: Add chart examples (hide account details!)
- [ ] **Version Tag**: Update version number in code (`#property version`)
- [ ] **CHANGELOG**: Document all changes from previous version
- [ ] **License Decision**: Choose license or keep "All Rights Reserved"
- [ ] **Documentation**: Verify INPUTS.md matches current parameters

---

## 📜 License

**No open-source license is included.** 

Unless otherwise specified, this software is provided under **All Rights Reserved** copyright. This means:

- ❌ You cannot redistribute modified versions
- ❌ You cannot use this code in commercial products without permission
- ❌ You cannot claim authorship of the original code
- ✅ You can use it for personal trading and backtesting
- ✅ You can learn from the code for educational purposes

**To request licensing options or commercial use permissions, please contact the author.**

---

## ⚠️ Risk Notice

**IMPORTANT DISCLAIMER:**

This EA is **research code** designed for technical backtesting, forward testing, and educational purposes. 

🔴 **What This EA Does NOT Guarantee:**
- ❌ No guaranteed profits or returns
- ❌ No protection against market risk
- ❌ No suitability for your specific financial situation
- ❌ No replacement for professional trading advice

🟢 **Required Testing Before Live Use:**
1. ✅ Extensive backtesting across multiple market conditions
2. ✅ Forward testing on demo account (minimum 1-3 months)
3. ✅ Small position sizing on live account initially
4. ✅ Continuous monitoring and performance review

⚠️ **Trading foreign exchange and CFDs carries substantial risk of loss and is not suitable for all investors.** You should carefully consider whether trading is appropriate for you in light of your circumstances and financial resources. Past performance is not indicative of future results.

**By using this software, you acknowledge that you are solely responsible for any trading decisions and resulting profits or losses.**

---

## ☕ Support & Contributions

### 👨‍💻 Meet the Developer

Hi! I'm the developer behind **3711 Single EA**. I created this tool to help traders like myself conduct rigorous technical analysis and systematic backtesting. My goal is to provide a transparent, well-documented trading system that the community can learn from and build upon.

### 🤝 Why Your Support Matters

Developing and maintaining a professional-grade Expert Advisor requires significant time and effort:

- 🔧 **15+ hours** of coding, testing, and debugging per update
- 📊 **Continuous research** into market behavior and strategy optimization
- 📚 **Documentation** creation and community support
- 🆕 **New features** based on user feedback and market evolution
- 🐛 **Bug fixes** and compatibility updates for MT5 platform changes

Your contributions directly enable me to:
- Dedicate more time to development instead of side projects
- Invest in better testing infrastructure and data sources
- Provide timely support to the community
- Release regular updates with new features and improvements

### 💖 How You Can Support

#### 1. **Buy Me a Coffee** ☕
If **3711 Single EA** has helped you with your trading analysis, journaling, or social media content, consider supporting the development with a coffee!

👉 **Support here:** [https://sociabuzz.com/hakimibob/support](https://sociabuzz.com/hakimibob/support)

Every contribution, no matter how small, makes a huge difference!

#### 2. **Share Your Feedback** 📝
- Report bugs or unexpected behavior
- Suggest new features or improvements
- Share your backtest results (anonymized)
- Help improve documentation

#### 3. **Spread the Word** 📢
- Star this repository on GitHub
- Share with fellow traders who might benefit
- Mention in your trading blog or social media (credit appreciated!)

#### 4. **Contribute Code** 💻
- Submit pull requests for bug fixes
- Propose new features via issues
- Improve documentation or translations

### 🙏 Current Supporters

*Special thanks to all supporters who make this project possible!* 

*(List will be updated as supporters join - consider being the first!)*

### 📞 Get in Touch

Have questions, suggestions, or want to collaborate? 

- 📧 **Contact**: Reach out through Sociabuzz or GitHub Issues
- 🐛 **Bug Reports**: Use GitHub Issues with detailed reproduction steps
- 💡 **Feature Requests**: Submit via GitHub Issues with use case description
- 💬 **Discussions**: Join the conversation in GitHub Discussions

---

<div align="center">

**Made with ❤️ by the Trading Community**

[⬆️ Back to Top](#3711-single-ea---professional-multi-timeframe-trading-system)

</div>
