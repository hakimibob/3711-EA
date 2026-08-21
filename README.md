# 3711 Single EA

`3711 Single EA` is a MetaTrader 5 Expert Advisor for single-symbol technical research and backtesting. It combines stochastic reset/cross logic, RSI and stochastic divergence checks, ATR/Bollinger/swing structure scoring, C1/C2 candle confirmation, fixed-risk lot sizing, break-even, ATR trailing, and optional CSV research logging.

## Repository Layout

```text
MQL5/
  Experts/
    3711_Single_EA.mq5
docs/
  INPUTS.md
  NAME_IDEAS.md
CHANGELOG.md
README.md
```

## Features

- Single-symbol operation with optional custom `InpTradeSymbol`.
- Multi-timeframe stochastic signal stack.
- Optional RSI, stochastic, or dual divergence requirements.
- Formula pack using ATR, Bollinger Bands, LWMA channels, and swing structure.
- Optional candle confirmation with C1 armed and C2 break states.
- Market, limit, or market-or-limit execution modes.
- Risk-based position sizing with break-even and ATR trailing management.
- Optional CSV logging for backtest research.

## Install

1. Copy `MQL5/Experts/3711_Single_EA.mq5` into your MetaTrader 5 data folder under `MQL5/Experts/`.
2. Open MetaEditor and compile `3711_Single_EA.mq5`.
3. Attach the EA to a chart or run it in Strategy Tester.
4. Keep `InpAllowTrading=false` until you finish testing the symbol, timeframe, spread, and risk settings.

## Backtest Notes

- Default signal stack uses `H1`, `M30`, `M15`, and `M5`.
- Default risk is `0.50%` of account equity per trade unless `InpRiskMoneyOverride` is set.
- `InpMaxSpreadPoints=0` disables spread filtering. Set a broker-specific limit before live or forward testing.
- CSV output is written by MetaTrader when `InpWriteCsv=true`; generated CSV files are intentionally ignored by Git.

## GitHub Release Checklist

- Compile successfully in MetaEditor.
- Run at least one backtest with CSV logging enabled.
- Add screenshots or reports only if they do not expose account details.
- Decide whether this repo should remain private or get a license before making it public.

## License

No open-source license is included yet. Without a license, the code remains all rights reserved by default.

## Risk Notice

This EA is research code for technical backtesting and forward testing. It does not guarantee profit. Test thoroughly before using it on a live account.

---

## ☕ Buy Me a Coffee

If you find **3711 Single EA** useful for your trading analysis, journaling, or social media content, consider supporting the development with a coffee! Your support helps keep this tool free and updated with new features.

### 👉 Support Here: [https://sociabuzz.com/hakimibob/support](https://sociabuzz.com/hakimibob/support)

Your contributions directly support:
- 🛠️ Ongoing development and bug fixes
- ✨ New features and improvements
- 📚 Documentation and community support
- 🔧 Maintenance and updates

Every coffee counts! Thank you for being part of this journey. 🙏
