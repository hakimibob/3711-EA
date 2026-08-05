#property strict
#property version   "1.01"
#property description "3711 Single EA - technical-only single-symbol backtest Expert Advisor (OPTIMIZED)"

#include <Trade/Trade.mqh>

// Global indicator handles - cached in OnInit() to avoid performance issues
int g_handleStoch1 = INVALID_HANDLE;
int g_handleStoch2 = INVALID_HANDLE;
int g_handleStoch3 = INVALID_HANDLE;
int g_handleStoch4 = INVALID_HANDLE;
int g_handleRsiDiv = INVALID_HANDLE;
int g_handleStochDiv = INVALID_HANDLE;
int g_handleATR = INVALID_HANDLE;
int g_handleBands = INVALID_HANDLE;
int g_handleMA5High = INVALID_HANDLE;
int g_handleMA5Low = INVALID_HANDLE;
int g_handleMA10High = INVALID_HANDLE;
int g_handleMA10Low = INVALID_HANDLE;
int g_handleRSI = INVALID_HANDLE;

enum ENUM_ENTRY_EXECUTION_MODE
{
   ENTRY_MARKET_ONLY = 0,
   ENTRY_LIMIT_ONLY  = 1,
   ENTRY_MARKET_OR_LIMIT = 2
};

enum ENUM_CANDLE_CONFIRM_MODE
{
   CANDLE_OFF  = 0,
   CANDLE_SOFT = 1,
   CANDLE_HARD = 2
};

enum ENUM_SIGNAL_SIDE
{
   SIDE_NONE = 0,
   SIDE_BUY  = 1,
   SIDE_SELL = -1
};

enum ENUM_TRADE_DIRECTION_MODE
{
   TRADE_DIRECTION_BOTH = 0,
   TRADE_DIRECTION_LONG_ONLY = 1,
   TRADE_DIRECTION_SHORT_ONLY = 2
};

input group "3711 Single EA: Symbol"
input string          InpTradeSymbol          = "";        // Blank = chart symbol
input ENUM_TIMEFRAMES InpSignalTf1            = PERIOD_H1;
input ENUM_TIMEFRAMES InpSignalTf2            = PERIOD_M30;
input ENUM_TIMEFRAMES InpSignalTf3            = PERIOD_M15;
input ENUM_TIMEFRAMES InpSignalTf4            = PERIOD_M5;
input ENUM_TIMEFRAMES InpDivergenceTf         = PERIOD_M15;
input bool            InpUseClosedBarSignals  = true;

input group "3711 Single EA: Stoch + Divergence"
input int             InpKPeriod              = 13;
input int             InpDPeriod              = 3;
input int             InpSlowing              = 3;
input ENUM_MA_METHOD  InpStochMethod          = MODE_SMA;
input ENUM_STO_PRICE  InpStochPrice           = STO_LOWHIGH;
input int             InpStrongBuyLevel       = 20;
input int             InpStrongSellLevel      = 80;
input int             InpContinuationBuyMax   = 55;
input int             InpContinuationSellMin  = 45;
input int             InpRSIPeriod            = 13;
input int             InpDivergenceLookback   = 34;
input bool            InpRequireRsiDivergence = false;
input bool            InpRequireStochDivergence = false;
input bool            InpRequireDualDivergence = false;

input group "3711 Single EA: Formula Pack"
input bool            InpUseFormulaPack       = true;
input ENUM_TIMEFRAMES InpFormulaTf            = PERIOD_CURRENT;
input int             InpATRPeriod            = 14;
input int             InpBandsPeriod          = 20;
input double          InpBandsDeviation       = 2.0;
input int             InpSwingLookback        = 34;
input int             InpSwingDepth           = 2;
input double          InpBosAtrBuffer         = 0.08;
input double          InpLimitAtrBuffer       = 0.12;
input double          InpFormulaWeight        = 1.0;

input group "3711 Single EA: Candle C1/C2"
input ENUM_CANDLE_CONFIRM_MODE InpCandleMode  = CANDLE_SOFT;
input int             InpCandleBoxLookback    = 8;
input double          InpCandleMinBodyAtr     = 0.18;
input double          InpCandleBreakBufferAtr = 0.02;
input double          InpCandleMaxChaseAtr    = 0.60;

input group "3711 Single EA: Entry + Risk"
input bool            InpAllowTrading         = true;
input ENUM_TRADE_DIRECTION_MODE InpTradeDirection = TRADE_DIRECTION_BOTH;
input ENUM_ENTRY_EXECUTION_MODE InpEntryMode  = ENTRY_MARKET_ONLY;
input double          InpMinScore             = 4.0;
input double          InpRiskPercent          = 0.50;
input double          InpRiskMoneyOverride    = 0.0;
input double          InpRR                   = 2.40;
input double          InpMinStopAtr           = 0.70;
input double          InpSwingStopAtrBuffer   = 0.18;
input int             InpMaxSpreadPoints      = 0;
input int             InpMaxOpenPositions     = 1;
input bool            InpOneTradePerSignalBar = true;
input int             InpLimitExpiryMinutes   = 240;
input double          InpLimitMinTravelAtr    = 0.12;
input double          InpLimitMaxTravelAtr    = 0.95;
input long            InpMagic                = 3711001;
input int             InpDeviationPoints      = 20;

input group "3711 Single EA: Management + Research"
input bool            InpUseBreakEven         = true;
input double          InpBreakEvenAtR         = 1.00;
input double          InpBreakEvenLockR       = 0.10;
input bool            InpUseAtrTrail          = true;
input double          InpTrailStartR          = 1.50;
input double          InpTrailAtrMult         = 1.20;
input bool            InpWriteCsv             = true;
input string          InpCsvName              = "3711_Single_EA_Backtest.csv";

struct FormulaRead
{
   bool   ok;
   bool   aligned;
   bool   conflict;
   double score;
   double atr;
   double limitEntry;
   double limitLow;
   double limitHigh;
   double limitInvalid;
   double limitTravelAtr;
   string state;
   string structure;
   string reason;
   string entryMap;
};

struct CandleRead
{
   bool   ok;
   bool   c1Armed;
   bool   c2Break;
   bool   failed;
   double c1High;
   double c1Low;
   double c2Close;
   string state;
   string detail;
};

struct SignalRead
{
   bool   valid;
   bool   isBuy;
   bool   executeReady;
   bool   limitReady;
   double score;
   double entry;
   double sl;
   double tp;
   double lot;
   double rr;
   double riskMoney;
   double stoch1;
   double stoch2;
   double stoch3;
   double stoch4;
   string signalType;
   string stage;
   string rsiDiv;
   string stochDiv;
   string stochCross;
   string formulaState;
   string candleState;
   string reason;
};

CTrade trade;
string g_symbol = "";
datetime g_lastSignalBar = 0;
datetime g_lastTradedBar = 0;
datetime g_lastCsvBar = 0;

int SignalShift()
{
   return InpUseClosedBarSignals ? 1 : 0;
}

bool TradeDirectionAllowed(const bool isBuy)
{
   if(InpTradeDirection == TRADE_DIRECTION_LONG_ONLY)
      return isBuy;
   if(InpTradeDirection == TRADE_DIRECTION_SHORT_ONLY)
      return !isBuy;
   return true;
}

ENUM_TIMEFRAMES FormulaTf()
{
   if(InpFormulaTf == PERIOD_CURRENT)
      return InpSignalTf1;
   return InpFormulaTf;
}

bool IsGood(const double v)
{
   return MathIsValidNumber(v) && v != EMPTY_VALUE;
}

string TfText(const ENUM_TIMEFRAMES tf)
{
   string s = EnumToString(tf);
   StringReplace(s, "PERIOD_", "");
   return s;
}

// Read indicator from cached handle - NO IndicatorRelease needed
bool ReadIndicatorCached(const int handle,const int buffer,const int shift,double &out)
{
   out = EMPTY_VALUE;
   if(handle == INVALID_HANDLE)
      return false;
   double values[];
   ArraySetAsSeries(values, true);
   int copied = CopyBuffer(handle, buffer, shift, 1, values);
   // Removed: IndicatorRelease(handle); - handles are now global and persistent
   if(copied != 1 || !IsGood(values[0]))
      return false;
   out = values[0];
   return true;
}

// Legacy wrapper for backward compatibility (still inefficient - should be replaced)
bool ReadIndicator(const int handle,const int buffer,const int shift,double &out)
{
   out = EMPTY_VALUE;
   if(handle == INVALID_HANDLE)
      return false;
   double values[];
   ArraySetAsSeries(values, true);
   int copied = CopyBuffer(handle, buffer, shift, 1, values);
   IndicatorRelease(handle);
   if(copied != 1 || !IsGood(values[0]))
      return false;
   out = values[0];
   return true;
}

bool ReadStochCached(const int handle,const int shift,double &k,double &d)
{
   double kBuf[], dBuf[];
   ArraySetAsSeries(kBuf, true);
   ArraySetAsSeries(dBuf, true);
   bool ok = (CopyBuffer(handle, 0, shift, 1, kBuf) == 1 &&
              CopyBuffer(handle, 1, shift, 1, dBuf) == 1 &&
              IsGood(kBuf[0]) && IsGood(dBuf[0]));
   // Removed: IndicatorRelease(handle); - handle is global and persistent
   if(!ok)
      return false;
   k = kBuf[0];
   d = dBuf[0];
   return true;
}

// Legacy wrapper - creates new handle each call (inefficient)
bool ReadStoch(const string sym,const ENUM_TIMEFRAMES tf,const int shift,double &k,double &d)
{
   int handle = iStochastic(sym, tf, InpKPeriod, InpDPeriod, InpSlowing, InpStochMethod, InpStochPrice);
   if(handle == INVALID_HANDLE)
      return false;

   double kBuf[], dBuf[];
   ArraySetAsSeries(kBuf, true);
   ArraySetAsSeries(dBuf, true);
   bool ok = (CopyBuffer(handle, 0, shift, 1, kBuf) == 1 &&
              CopyBuffer(handle, 1, shift, 1, dBuf) == 1 &&
              IsGood(kBuf[0]) && IsGood(dBuf[0]));
   IndicatorRelease(handle);
   if(!ok)
      return false;
   k = kBuf[0];
   d = dBuf[0];
   return true;
}

bool ReadRSI(const string sym,const ENUM_TIMEFRAMES tf,const int shift,double &rsi)
{
   return ReadIndicatorCached(g_handleRSI, 0, shift, rsi);
}

bool ReadATR(const string sym,const ENUM_TIMEFRAMES tf,const int shift,double &atr)
{
   return ReadIndicatorCached(g_handleATR, 0, shift, atr);
}

bool ReadMA(const string sym,const ENUM_TIMEFRAMES tf,const int period,const int shift,const ENUM_MA_METHOD method,const ENUM_APPLIED_PRICE price,double &ma)
{
   // Select appropriate cached handle based on period and price type
   int handle = INVALID_HANDLE;
   if(period == 5)
      handle = (price == PRICE_HIGH) ? g_handleMA5High : g_handleMA5Low;
   else if(period == 10)
      handle = (price == PRICE_HIGH) ? g_handleMA10High : g_handleMA10Low;
   
   if(handle != INVALID_HANDLE)
      return ReadIndicatorCached(handle, 0, shift, ma);
   
   // Fallback to legacy method for other periods
   int h = iMA(sym, tf, period, 0, method, price);
   return ReadIndicator(h, 0, shift, ma);
}

bool ReadBands(const string sym,const ENUM_TIMEFRAMES tf,const int shift,double &upper,double &mid,double &lower)
{
   if(g_handleBands == INVALID_HANDLE)
      return false;
   double b0[], b1[], b2[];
   ArraySetAsSeries(b0, true);
   ArraySetAsSeries(b1, true);
   ArraySetAsSeries(b2, true);
   bool ok = (CopyBuffer(g_handleBands, 0, shift, 1, b0) == 1 &&
              CopyBuffer(g_handleBands, 1, shift, 1, b1) == 1 &&
              CopyBuffer(g_handleBands, 2, shift, 1, b2) == 1 &&
              IsGood(b0[0]) && IsGood(b1[0]) && IsGood(b2[0]));
   // Removed: IndicatorRelease(g_handleBands); - handle is global
   if(!ok)
      return false;
   mid = b0[0];
   upper = b1[0];
   lower = b2[0];
   if(upper < lower)
   {
      double tmp = upper;
      upper = lower;
      lower = tmp;
   }
   return (upper > lower);
}

bool ReadHLC(const string sym,const ENUM_TIMEFRAMES tf,const int shift,double &high,double &low,double &close)
{
   double h[], l[], c[];
   ArraySetAsSeries(h, true);
   ArraySetAsSeries(l, true);
   ArraySetAsSeries(c, true);
   if(CopyHigh(sym, tf, shift, 1, h) != 1 ||
      CopyLow(sym, tf, shift, 1, l) != 1 ||
      CopyClose(sym, tf, shift, 1, c) != 1)
      return false;
   high = h[0];
   low = l[0];
   close = c[0];
   return IsGood(high) && IsGood(low) && IsGood(close) && high >= low;
}

int VolumeDigits(const double step)
{
   if(step <= 0.0)
      return 2;
   int digits = 0;
   double s = step;
   while(digits < 8 && MathAbs(s - MathRound(s)) > 0.00000001)
   {
      s *= 10.0;
      digits++;
   }
   return digits;
}

double NormalizeVolume(const string sym,const double lots)
{
   double minLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   if(step <= 0.0)
      step = 0.01;
   double out = MathFloor(lots / step) * step;
   if(out < minLot)
      out = minLot;
   if(maxLot > 0.0 && out > maxLot)
      out = maxLot;
   return NormalizeDouble(out, VolumeDigits(step));
}

int CountOpenOrPending(const string sym)
{
   int count = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) == sym && (long)PositionGetInteger(POSITION_MAGIC) == InpMagic)
         count++;
   }
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0 || !OrderSelect(ticket))
         continue;
      if(OrderGetString(ORDER_SYMBOL) != sym || (long)OrderGetInteger(ORDER_MAGIC) != InpMagic)
         continue;
      ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_LIMIT ||
         type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_SELL_STOP ||
         type == ORDER_TYPE_BUY_STOP_LIMIT || type == ORDER_TYPE_SELL_STOP_LIMIT)
         count++;
   }
   return count;
}

bool HasOppositePosition(const string sym,const bool isBuy)
{
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != sym || (long)PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;
      long type = PositionGetInteger(POSITION_TYPE);
      if(isBuy && type == POSITION_TYPE_SELL)
         return true;
      if(!isBuy && type == POSITION_TYPE_BUY)
         return true;
   }
   return false;
}

bool FindTwoSwings(const double &values[],const int count,const int depth,const bool highSide,int &recent,int &previous)
{
   recent = -1;
   previous = -1;
   int dep = MathMax(1, depth);
   for(int i=dep+1; i<count-dep; i++)
   {
      bool swing = true;
      for(int d=1; d<=dep; d++)
      {
         if(highSide)
         {
            if(values[i] <= values[i-d] || values[i] <= values[i+d])
            {
               swing = false;
               break;
            }
         }
         else
         {
            if(values[i] >= values[i-d] || values[i] >= values[i+d])
            {
               swing = false;
               break;
            }
         }
      }
      if(!swing)
         continue;
      if(recent < 0)
         recent = i;
      else
      {
         previous = i;
         return true;
      }
   }
   return false;
}

string DetectRsiDivergence(const string sym,const ENUM_TIMEFRAMES tf,const int lookback)
{
   int count = MathMax(lookback + 8, 24);
   double lows[], highs[], rsi[];
   ArraySetAsSeries(lows, true);
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(rsi, true);

   // Use cached handle instead of creating new one each time
   if(g_handleRsiDiv == INVALID_HANDLE)
      return "None";
   bool ok = (CopyLow(sym, tf, 1, count, lows) == count &&
              CopyHigh(sym, tf, 1, count, highs) == count &&
              CopyBuffer(g_handleRsiDiv, 0, 1, count, rsi) == count);
   // Removed: IndicatorRelease - handle is global and persistent
   if(!ok)
      return "None";

   int recentLow=-1, prevLow=-1, recentHigh=-1, prevHigh=-1;
   bool lowOk = FindTwoSwings(lows, count, 2, false, recentLow, prevLow);
   bool highOk = FindTwoSwings(highs, count, 2, true, recentHigh, prevHigh);
   if(lowOk && lows[recentLow] < lows[prevLow] && rsi[recentLow] > rsi[prevLow])
      return "Bullish";
   if(highOk && highs[recentHigh] > highs[prevHigh] && rsi[recentHigh] < rsi[prevHigh])
      return "Bearish";
   return "None";
}

string DetectStochDivergence(const string sym,const ENUM_TIMEFRAMES tf,const int lookback)
{
   int count = MathMax(lookback + 8, 24);
   double lows[], highs[], k[];
   ArraySetAsSeries(lows, true);
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(k, true);

   // Use cached handle instead of creating new one each time
   if(g_handleStochDiv == INVALID_HANDLE)
      return "None";
   bool ok = (CopyLow(sym, tf, 1, count, lows) == count &&
              CopyHigh(sym, tf, 1, count, highs) == count &&
              CopyBuffer(g_handleStochDiv, 0, 1, count, k) == count);
   // Removed: IndicatorRelease - handle is global and persistent
   if(!ok)
      return "None";

   int recentLow=-1, prevLow=-1, recentHigh=-1, prevHigh=-1;
   bool lowOk = FindTwoSwings(lows, count, 2, false, recentLow, prevLow);
   bool highOk = FindTwoSwings(highs, count, 2, true, recentHigh, prevHigh);
   if(lowOk && lows[recentLow] < lows[prevLow] && k[recentLow] > k[prevLow])
      return "Bullish";
   if(highOk && highs[recentHigh] > highs[prevHigh] && k[recentHigh] < k[prevHigh])
      return "Bearish";
   return "None";
}

string DetectStochCrossCached(const int handle,const int shift)
{
   double k0=0.0, d0=0.0, k1=0.0, d1=0.0;
   if(!ReadStochCached(handle, shift, k0, d0) || !ReadStochCached(handle, shift + 1, k1, d1))
      return "None";
   if(k1 <= d1 && k0 > d0)
      return "Bullish";
   if(k1 >= d1 && k0 < d0)
      return "Bearish";
   return "None";
}

string DetectStochCross(const string sym,const ENUM_TIMEFRAMES tf,const int shift)
{
   // Use cached handle approach based on timeframe to avoid creating handles on every call
   int handle = INVALID_HANDLE;
   
   // Map timeframe to appropriate cached global handle
   if(tf == InpSignalTf1)
      handle = g_handleStoch1;
   else if(tf == InpSignalTf2)
      handle = g_handleStoch2;
   else if(tf == InpSignalTf3)
      handle = g_handleStoch3;
   else if(tf == InpSignalTf4)
      handle = g_handleStoch4;
   else if(tf == InpDivergenceTf)
      handle = g_handleStochDiv;
   
   // If we have a cached handle, use it
   if(handle != INVALID_HANDLE)
   {
      double k0=0.0, d0=0.0, k1=0.0, d1=0.0;
      if(!ReadStochCached(handle, shift, k0, d0) || !ReadStochCached(handle, shift + 1, k1, d1))
         return "None";
      if(k1 <= d1 && k0 > d0)
         return "Bullish";
      if(k1 >= d1 && k0 < d0)
         return "Bearish";
      return "None";
   }
   
   // Fallback to legacy method only if no cached handle available (should rarely happen)
   double k0=0.0, d0=0.0, k1=0.0, d1=0.0;
   if(!ReadStoch(sym, tf, shift, k0, d0) || !ReadStoch(sym, tf, shift + 1, k1, d1))
      return "None";
   if(k1 <= d1 && k0 > d0)
      return "Bullish";
   if(k1 >= d1 && k0 < d0)
      return "Bearish";
   return "None";
}

void ResetFormula(FormulaRead &read)
{
   read.ok = false;
   read.aligned = false;
   read.conflict = false;
   read.score = 0.0;
   read.atr = 0.0;
   read.limitEntry = 0.0;
   read.limitLow = 0.0;
   read.limitHigh = 0.0;
   read.limitInvalid = 0.0;
   read.limitTravelAtr = 0.0;
   read.state = "-";
   read.structure = "-";
   read.reason = "-";
   read.entryMap = "-";
}

bool FindSwingPair(const string sym,const ENUM_TIMEFRAMES tf,const bool highSide,double &recent,double &previous)
{
   int count = MathMax(24, InpSwingLookback + InpSwingDepth * 2 + 8);
   double values[];
   ArraySetAsSeries(values, true);
   int copied = highSide ? CopyHigh(sym, tf, 1, count, values) : CopyLow(sym, tf, 1, count, values);
   if(copied != count)
      return false;
   int r=-1, p=-1;
   if(!FindTwoSwings(values, count, InpSwingDepth, highSide, r, p))
      return false;
   recent = values[r];
   previous = values[p];
   return IsGood(recent) && IsGood(previous);
}

int DetectStructure(const string sym,const ENUM_TIMEFRAMES tf,const double atr,const double closePrice,string &text,double &swingLow,double &swingHigh)
{
   text = "MIX";
   swingLow = 0.0;
   swingHigh = 0.0;
   double recentLow=0.0, prevLow=0.0, recentHigh=0.0, prevHigh=0.0;
   bool lowOk = FindSwingPair(sym, tf, false, recentLow, prevLow);
   bool highOk = FindSwingPair(sym, tf, true, recentHigh, prevHigh);
   if(lowOk)
      swingLow = recentLow;
   if(highOk)
      swingHigh = recentHigh;

   int structure = 0;
   if(lowOk && highOk)
   {
      if(recentLow > prevLow && recentHigh > prevHigh)
         structure = 1;
      else if(recentLow < prevLow && recentHigh < prevHigh)
         structure = -1;
   }

   double buffer = atr * MathMax(0.0, InpBosAtrBuffer);
   if(highOk && closePrice > recentHigh + buffer)
   {
      text = "BOS UP";
      return 1;
   }
   if(lowOk && closePrice < recentLow - buffer)
   {
      text = "BOS DOWN";
      return -1;
   }
   if(structure > 0)
      text = "UP STRUCT";
   else if(structure < 0)
      text = "DOWN STRUCT";
   return structure;
}

bool BuildFormulaRead(const string sym,const bool isBuy,const double entry,FormulaRead &read)
{
   ResetFormula(read);
   if(!InpUseFormulaPack)
   {
      read.ok = true;
      read.aligned = true;
      read.state = "FORMULA OFF";
      read.reason = "Formula pack disabled";
      return true;
   }

   ENUM_TIMEFRAMES tf = FormulaTf();
   int shift = SignalShift();
   double h0=0.0, l0=0.0, c0=0.0, c1=0.0;
   double dummyH=0.0, dummyL=0.0;
   if(!ReadHLC(sym, tf, shift, h0, l0, c0) || !ReadHLC(sym, tf, shift + 1, dummyH, dummyL, c1))
      return false;

   double atr=0.0, rsi=0.0, k=0.0, d=0.0, kPrev=0.0, dPrev=0.0;
   double fastHigh=0.0, fastLow=0.0, slowHigh=0.0, slowLow=0.0;
   double fastHighPrev=0.0, fastLowPrev=0.0, slowHighPrev=0.0, slowLowPrev=0.0;
   double upper=0.0, mid=0.0, lower=0.0;
   if(!ReadATR(sym, tf, shift, atr) || atr <= 0.0)
      return false;
   ReadRSI(sym, tf, shift, rsi);
   // Use a temporary stoch handle for formula pack (not the main signal timeframes)
   int stochHandle = iStochastic(sym, tf, InpKPeriod, InpDPeriod, InpSlowing, InpStochMethod, InpStochPrice);
   if(stochHandle != INVALID_HANDLE)
   {
      ReadStochCached(stochHandle, shift, k, d);
      ReadStochCached(stochHandle, shift + 1, kPrev, dPrev);
      IndicatorRelease(stochHandle);
   }
   bool maOk = ReadMA(sym, tf, 5, shift, MODE_LWMA, PRICE_HIGH, fastHigh)
            && ReadMA(sym, tf, 5, shift, MODE_LWMA, PRICE_LOW, fastLow)
            && ReadMA(sym, tf, 10, shift, MODE_LWMA, PRICE_HIGH, slowHigh)
            && ReadMA(sym, tf, 10, shift, MODE_LWMA, PRICE_LOW, slowLow)
            && ReadMA(sym, tf, 5, shift + 1, MODE_LWMA, PRICE_HIGH, fastHighPrev)
            && ReadMA(sym, tf, 5, shift + 1, MODE_LWMA, PRICE_LOW, fastLowPrev)
            && ReadMA(sym, tf, 10, shift + 1, MODE_LWMA, PRICE_HIGH, slowHighPrev)
            && ReadMA(sym, tf, 10, shift + 1, MODE_LWMA, PRICE_LOW, slowLowPrev);
   bool bbOk = ReadBands(sym, tf, shift, upper, mid, lower);
   if(!maOk)
      return false;

   bool maUp = (fastLow > slowLow && fastHigh > slowHigh && slowLow >= slowLowPrev);
   bool maDown = (fastHigh < slowHigh && fastLow < slowLow && slowHigh <= slowHighPrev);
   bool stResetBuy = (kPrev <= (double)InpStrongBuyLevel && k > (double)InpStrongBuyLevel) || (k > kPrev && k <= 45.0);
   bool stResetSell = (kPrev >= (double)InpStrongSellLevel && k < (double)InpStrongSellLevel) || (k < kPrev && k >= 55.0);

   double swingLow=0.0, swingHigh=0.0;
   string structureText = "-";
   int structure = DetectStructure(sym, tf, atr, c0, structureText, swingLow, swingHigh);

   double score = 0.0;
   if(isBuy)
   {
      if(maUp) score += 0.45; else if(maDown) score -= 0.60;
      if(bbOk && c0 > mid) score += 0.25; else if(bbOk && c0 < lower) score -= 0.25;
      if(stResetBuy) score += 0.45; else if(stResetSell) score -= 0.35;
      if(structure > 0) score += 0.35; else if(structure < 0) score -= 0.35;
      if(IsGood(rsi) && rsi >= 45.0) score += 0.15; else if(IsGood(rsi) && rsi < 40.0) score -= 0.15;
   }
   else
   {
      if(maDown) score += 0.45; else if(maUp) score -= 0.60;
      if(bbOk && c0 < mid) score += 0.25; else if(bbOk && c0 > upper) score -= 0.25;
      if(stResetSell) score += 0.45; else if(stResetBuy) score -= 0.35;
      if(structure < 0) score += 0.35; else if(structure > 0) score -= 0.35;
      if(IsGood(rsi) && rsi <= 55.0) score += 0.15; else if(IsGood(rsi) && rsi > 60.0) score -= 0.15;
   }

   read.ok = true;
   read.score = MathMax(-1.8, MathMin(1.8, score));
   read.atr = atr;
   read.structure = structureText;
   read.aligned = (read.score >= 0.55);
   read.conflict = (read.score <= -0.55);

   if(isBuy)
   {
      if(stResetBuy) read.state = "BUY RESET";
      else if(maUp && c0 > slowHigh) read.state = "BUY MOM";
      else read.state = maUp ? "BUY WATCH" : "MIX";
   }
   else
   {
      if(stResetSell) read.state = "SELL RESET";
      else if(maDown && c0 < slowLow) read.state = "SELL MOM";
      else read.state = maDown ? "SELL WATCH" : "MIX";
   }

   double half = atr * MathMax(0.02, InpLimitAtrBuffer);
   double base = entry;
   if(isBuy)
   {
      base = MathMin(entry, MathMax(swingLow > 0.0 ? swingLow + half : slowLow, MathMin(mid > 0.0 ? mid : slowLow, slowLow)));
      read.limitLow = base - half;
      read.limitHigh = base + half;
      read.limitEntry = base;
      read.limitInvalid = (swingLow > 0.0 ? swingLow : base - atr) - half;
      read.limitTravelAtr = (entry - read.limitEntry) / atr;
   }
   else
   {
      base = MathMax(entry, MathMin(swingHigh > 0.0 ? swingHigh - half : slowHigh, MathMax(mid > 0.0 ? mid : slowHigh, slowHigh)));
      read.limitLow = base - half;
      read.limitHigh = base + half;
      read.limitEntry = base;
      read.limitInvalid = (swingHigh > 0.0 ? swingHigh : base + atr) + half;
      read.limitTravelAtr = (read.limitEntry - entry) / atr;
   }

   int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   read.reason = read.state + " | " + structureText + " | F=" + DoubleToString(read.score, 2);
   read.entryMap = (isBuy ? "BUY LIMIT " : "SELL LIMIT ")
                 + DoubleToString(NormalizeDouble(read.limitEntry, digits), digits)
                 + " zone "
                 + DoubleToString(NormalizeDouble(read.limitLow, digits), digits)
                 + "-"
                 + DoubleToString(NormalizeDouble(read.limitHigh, digits), digits)
                 + " invalid "
                 + DoubleToString(NormalizeDouble(read.limitInvalid, digits), digits)
                 + " travel "
                 + DoubleToString(read.limitTravelAtr, 2) + "ATR";
   return true;
}

void ResetCandle(CandleRead &read)
{
   read.ok = false;
   read.c1Armed = false;
   read.c2Break = false;
   read.failed = false;
   read.c1High = 0.0;
   read.c1Low = 0.0;
   read.c2Close = 0.0;
   read.state = "OFF";
   read.detail = "-";
}

bool EvaluateCandleTrigger(const string sym,const ENUM_TIMEFRAMES tf,const bool isBuy,CandleRead &read)
{
   ResetCandle(read);
   if(InpCandleMode == CANDLE_OFF)
   {
      read.ok = true;
      read.state = "OFF";
      return true;
   }

   double atr=0.0;
   if(!ReadATR(sym, tf, 1, atr) || atr <= 0.0)
   {
      read.state = "NO ATR";
      return false;
   }

   int boxLookback = MathMax(3, InpCandleBoxLookback);
   double highs[], lows[], opens[], closes[];
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   ArraySetAsSeries(opens, true);
   ArraySetAsSeries(closes, true);
   int need = boxLookback + 4;
   if(CopyHigh(sym, tf, 1, need, highs) != need ||
      CopyLow(sym, tf, 1, need, lows) != need ||
      CopyOpen(sym, tf, 1, need, opens) != need ||
      CopyClose(sym, tf, 1, need, closes) != need)
   {
      read.state = "NO DATA";
      return false;
   }

   double boxHigh = highs[2];
   double boxLow = lows[2];
   for(int i=3; i<need; i++)
   {
      if(highs[i] > boxHigh) boxHigh = highs[i];
      if(lows[i] < boxLow) boxLow = lows[i];
   }

   double c1Open = opens[1];
   double c1Close = closes[1];
   double c1High = highs[1];
   double c1Low = lows[1];
   double c2Close = closes[0];
   double body = MathAbs(c1Close - c1Open);
   double buffer = atr * MathMax(0.0, InpCandleBreakBufferAtr);
   double chase = atr * MathMax(0.0, InpCandleMaxChaseAtr);
   read.c1High = c1High;
   read.c1Low = c1Low;
   read.c2Close = c2Close;

   bool bodyOk = (body >= atr * MathMax(0.0, InpCandleMinBodyAtr));
   bool c1Exit = false;
   bool c2Break = false;
   bool chaseOk = true;
   if(isBuy)
   {
      c1Exit = bodyOk && c1Close > c1Open && c1Close > boxHigh;
      c2Break = c1Exit && c2Close > c1High + buffer;
      chaseOk = !c2Break || (c2Close <= c1High + chase);
   }
   else
   {
      c1Exit = bodyOk && c1Close < c1Open && c1Close < boxLow;
      c2Break = c1Exit && c2Close < c1Low - buffer;
      chaseOk = !c2Break || (c2Close >= c1Low - chase);
   }

   read.ok = true;
   read.c1Armed = c1Exit;
   read.c2Break = c2Break && chaseOk;
   read.failed = c2Break && !chaseOk;
   if(read.c2Break)
      read.state = "C2 BREAK";
   else if(read.c1Armed)
      read.state = "C1 ARMED";
   else if(read.failed)
      read.state = "C2 CHASE";
   else
      read.state = "WAIT C1";
   read.detail = read.state + " bodyATR=" + DoubleToString(body / atr, 2);
   return true;
}

bool BuildTradePlan(const string sym,const bool isBuy,const bool useLimit,const FormulaRead &formula,SignalRead &signal,string &err)
{
   err = "";
   int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   if(point <= 0.0 || bid <= 0.0 || ask <= 0.0)
   {
      err = "bad price";
      return false;
   }

   double entry = isBuy ? ask : bid;
   if(useLimit)
      entry = formula.limitEntry;
   if(entry <= 0.0 || !IsGood(entry))
   {
      err = "bad entry";
      return false;
   }

   if(useLimit)
   {
      int stops = (int)SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
      double minDist = MathMax((double)stops * point, point);
      if(isBuy && entry >= bid - minDist)
      {
         err = "buy limit too near/above market";
         return false;
      }
      if(!isBuy && entry <= ask + minDist)
      {
         err = "sell limit too near/below market";
         return false;
      }
      if(formula.limitTravelAtr < InpLimitMinTravelAtr || formula.limitTravelAtr > InpLimitMaxTravelAtr)
      {
         err = "limit travel not in range";
         return false;
      }
   }

   double atr = formula.atr;
   if(atr <= 0.0)
      ReadATR(sym, InpSignalTf1, SignalShift(), atr);
   if(atr <= 0.0)
   {
      err = "no atr";
      return false;
   }

   string structureText = "";
   double swingLow=0.0, swingHigh=0.0;
   DetectStructure(sym, FormulaTf(), atr, entry, structureText, swingLow, swingHigh);
   double sl = 0.0;
   if(isBuy)
   {
      sl = (swingLow > 0.0) ? swingLow - atr * InpSwingStopAtrBuffer : entry - atr * InpMinStopAtr;
      if(useLimit && formula.limitInvalid > 0.0)
         sl = MathMin(sl, formula.limitInvalid);
      double minSl = entry - atr * MathMax(0.10, InpMinStopAtr);
      if(sl > minSl)
         sl = minSl;
   }
   else
   {
      sl = (swingHigh > 0.0) ? swingHigh + atr * InpSwingStopAtrBuffer : entry + atr * InpMinStopAtr;
      if(useLimit && formula.limitInvalid > 0.0)
         sl = MathMax(sl, formula.limitInvalid);
      double minSl = entry + atr * MathMax(0.10, InpMinStopAtr);
      if(sl < minSl)
         sl = minSl;
   }

   double riskDist = MathAbs(entry - sl);
   if(riskDist < point)
   {
      err = "stop distance too small";
      return false;
   }

   double tp = isBuy ? entry + riskDist * InpRR : entry - riskDist * InpRR;
   entry = NormalizeDouble(entry, digits);
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);

   double riskMoney = InpRiskMoneyOverride;
   if(riskMoney <= 0.0)
      riskMoney = AccountInfoDouble(ACCOUNT_EQUITY) * MathMax(0.0, InpRiskPercent) / 100.0;
   if(riskMoney <= 0.0)
   {
      err = "risk money <= 0";
      return false;
   }

   double loss = 0.0;
   ENUM_ORDER_TYPE type = isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   if(!OrderCalcProfit(type, sym, 1.0, entry, sl, loss))
   {
      err = "risk calc failed";
      return false;
   }
   double riskPerLot = MathAbs(loss);
   if(riskPerLot <= 0.0)
   {
      err = "risk per lot <= 0";
      return false;
   }

   double lot = NormalizeVolume(sym, riskMoney / riskPerLot);
   if(lot <= 0.0)
   {
      err = "lot <= 0";
      return false;
   }

   signal.entry = entry;
   signal.sl = sl;
   signal.tp = tp;
   signal.lot = lot;
   signal.rr = InpRR;
   signal.riskMoney = riskMoney;
   return true;
}

bool BuildSignal(const string sym,SignalRead &signal)
{
   ZeroMemory(signal);
   signal.valid = false;
   signal.isBuy = true;
   signal.executeReady = false;
   signal.limitReady = false;
   signal.signalType = "-";
   signal.stage = "-";
   signal.rsiDiv = "None";
   signal.stochDiv = "None";
   signal.stochCross = "None";
   signal.formulaState = "-";
   signal.candleState = "-";
   signal.reason = "";

   int shift = SignalShift();
   double k1=0.0,d1=0.0,k1Prev=0.0,d1Prev=0.0;
   // Use cached handles for stochastics - major performance improvement
   if(!ReadStochCached(g_handleStoch1, shift, k1, d1) || !ReadStochCached(g_handleStoch1, shift + 1, k1Prev, d1Prev))
   {
      signal.reason = "no stoch";
      return false;
   }
   signal.stoch1 = k1;
   double k=0.0,d=0.0;
   if(ReadStochCached(g_handleStoch2, shift, k, d)) signal.stoch2 = k; else signal.stoch2 = EMPTY_VALUE;
   if(ReadStochCached(g_handleStoch3, shift, k, d)) signal.stoch3 = k; else signal.stoch3 = EMPTY_VALUE;
   if(ReadStochCached(g_handleStoch4, shift, k, d)) signal.stoch4 = k; else signal.stoch4 = EMPTY_VALUE;

   signal.stochCross = DetectStochCrossCached(g_handleStoch1, shift);
   bool buyReset = ((k1Prev <= (double)InpStrongBuyLevel && k1 > (double)InpStrongBuyLevel) ||
                    (signal.stochCross == "Bullish" && k1 <= (double)InpContinuationBuyMax));
   bool sellReset = ((k1Prev >= (double)InpStrongSellLevel && k1 < (double)InpStrongSellLevel) ||
                     (signal.stochCross == "Bearish" && k1 >= (double)InpContinuationSellMin));

   bool buyBias = buyReset;
   bool sellBias = sellReset;
   double avg = 0.0;
   int n = 0;
   double vals[4];
   vals[0] = signal.stoch1;
   vals[1] = signal.stoch2;
   vals[2] = signal.stoch3;
   vals[3] = signal.stoch4;
   for(int i=0; i<4; i++)
   {
      if(IsGood(vals[i]))
      {
         avg += vals[i];
         n++;
      }
   }
   if(n > 0)
      avg /= (double)n;
   if(!buyBias && avg <= 35.0 && signal.stochCross == "Bullish")
      buyBias = true;
   if(!sellBias && avg >= 65.0 && signal.stochCross == "Bearish")
      sellBias = true;

   if(!buyBias && !sellBias)
   {
      signal.reason = "no reset/cross";
      return false;
   }
   if(buyBias && sellBias)
   {
      signal.reason = "mixed reset";
      return false;
   }

   bool isBuy = buyBias;
   signal.isBuy = isBuy;
   signal.signalType = "REV";
   signal.stage = "WATCH";
   if(!TradeDirectionAllowed(isBuy))
   {
      signal.reason = isBuy ? "long disabled by trade direction input" : "short disabled by trade direction input";
      return false;
   }

   double score = 0.0;
   score += isBuy ? (buyReset ? 2.0 : 1.2) : (sellReset ? 2.0 : 1.2);
   if((isBuy && avg <= 45.0) || (!isBuy && avg >= 55.0))
      score += 0.4;

   signal.rsiDiv = DetectRsiDivergence(sym, InpDivergenceTf, InpDivergenceLookback);
   signal.stochDiv = DetectStochDivergence(sym, InpDivergenceTf, InpDivergenceLookback);
   bool rsiAligned = (isBuy && signal.rsiDiv == "Bullish") || (!isBuy && signal.rsiDiv == "Bearish");
   bool stochAligned = (isBuy && signal.stochDiv == "Bullish") || (!isBuy && signal.stochDiv == "Bearish");
   bool crossAligned = (isBuy && signal.stochCross == "Bullish") || (!isBuy && signal.stochCross == "Bearish");

   if(rsiAligned) score += 2.0;
   else if(signal.rsiDiv != "None") score -= 1.5;
   if(stochAligned) score += 1.2;
   else if(signal.stochDiv != "None") score -= 0.9;
   if(crossAligned) score += 0.8;

   if(InpRequireRsiDivergence && !rsiAligned)
   {
      signal.reason = "RSI divergence not aligned";
      return false;
   }
   if(InpRequireStochDivergence && !stochAligned)
   {
      signal.reason = "Stoch divergence not aligned";
      return false;
   }
   if(InpRequireDualDivergence && !(rsiAligned && stochAligned))
   {
      signal.reason = "Dual divergence not aligned";
      return false;
   }

   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   double entry = isBuy ? ask : bid;
   FormulaRead formula;
   ResetFormula(formula);
   if(BuildFormulaRead(sym, isBuy, entry, formula))
   {
      score += formula.score * MathMax(0.0, InpFormulaWeight);
      signal.formulaState = formula.state;
      if(formula.aligned) score += 0.4;
      if(formula.conflict) score -= 0.8;
   }

   CandleRead candle;
   ResetCandle(candle);
   EvaluateCandleTrigger(sym, InpSignalTf1, isBuy, candle);
   signal.candleState = candle.state;
   if(InpCandleMode != CANDLE_OFF)
   {
      if(candle.c2Break)
      {
         score += 1.0;
         signal.stage = "CONFIRM";
      }
      else if(candle.c1Armed)
      {
         score += 0.35;
         signal.stage = "ARMED";
      }
      else if(InpCandleMode == CANDLE_HARD)
      {
         signal.reason = "candle trigger waiting";
         return false;
      }
   }

   if(signal.stage == "WATCH")
   {
      if((rsiAligned && stochAligned) || (crossAligned && score >= InpMinScore))
         signal.stage = "CONFIRM";
      else if(rsiAligned || stochAligned || crossAligned)
         signal.stage = "EARLY";
   }

   signal.score = score;
   signal.valid = (score >= InpMinScore);
   signal.executeReady = signal.valid;
   signal.reason = "Score=" + DoubleToString(score, 2)
                 + " | Stoch " + DoubleToString(k1, 1)
                 + " avg " + DoubleToString(avg, 1)
                 + " | RSIdiv " + signal.rsiDiv
                 + " | STdiv " + signal.stochDiv
                 + " | X " + signal.stochCross
                 + " | F " + signal.formulaState
                 + " | CND " + signal.candleState;
   if(!signal.valid)
      return true;

   string err = "";
   bool marketOk = BuildTradePlan(sym, isBuy, false, formula, signal, err);
   bool limitOk = false;
   SignalRead limitPlan = signal;
   if(formula.ok && formula.aligned)
      limitOk = BuildTradePlan(sym, isBuy, true, formula, limitPlan, err);
   signal.limitReady = limitOk;

   if(InpEntryMode == ENTRY_LIMIT_ONLY)
   {
      if(limitOk)
      {
         signal.entry = limitPlan.entry;
         signal.sl = limitPlan.sl;
         signal.tp = limitPlan.tp;
         signal.lot = limitPlan.lot;
         signal.rr = limitPlan.rr;
         signal.riskMoney = limitPlan.riskMoney;
      }
      else
      {
         signal.executeReady = false;
         signal.reason += " | Limit not ready: " + err;
      }
   }
   else if(InpEntryMode == ENTRY_MARKET_OR_LIMIT && limitOk && signal.stage != "CONFIRM")
   {
      signal.entry = limitPlan.entry;
      signal.sl = limitPlan.sl;
      signal.tp = limitPlan.tp;
      signal.lot = limitPlan.lot;
      signal.rr = limitPlan.rr;
      signal.riskMoney = limitPlan.riskMoney;
   }
   else if(!marketOk)
   {
      signal.executeReady = false;
      signal.reason += " | Plan fail: " + err;
   }

   return true;
}

bool SpreadOk(const string sym,string &reason)
{
   reason = "";
   if(InpMaxSpreadPoints <= 0)
      return true;
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   if(point <= 0.0)
      return true;
   double spread = (ask - bid) / point;
   if(spread > (double)InpMaxSpreadPoints)
   {
      reason = "spread " + DoubleToString(spread, 1) + " > " + IntegerToString(InpMaxSpreadPoints);
      return false;
   }
   return true;
}

bool ExecuteSignal(const string sym,const SignalRead &signal)
{
   if(!InpAllowTrading || !signal.valid || !signal.executeReady)
      return false;
   if(!TradeDirectionAllowed(signal.isBuy))
      return false;
   if(InpOneTradePerSignalBar && g_lastTradedBar == g_lastSignalBar)
      return false;
   if(CountOpenOrPending(sym) >= InpMaxOpenPositions)
      return false;
   if(HasOppositePosition(sym, signal.isBuy))
      return false;
   string spreadReason = "";
   if(!SpreadOk(sym, spreadReason))
      return false;

   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpDeviationPoints);
   string comment = "3711 Single EA " + signal.stage;
   bool useLimit = false;
   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   if(signal.isBuy && signal.entry < bid)
      useLimit = true;
   if(!signal.isBuy && signal.entry > ask)
      useLimit = true;

   bool ok = false;
   if(useLimit)
   {
      datetime exp = 0;
      ENUM_ORDER_TYPE_TIME t = ORDER_TIME_GTC;
      if(InpLimitExpiryMinutes > 0)
      {
         t = ORDER_TIME_SPECIFIED;
         exp = TimeCurrent() + InpLimitExpiryMinutes * 60;
      }
      if(signal.isBuy)
         ok = trade.BuyLimit(signal.lot, signal.entry, sym, signal.sl, signal.tp, t, exp, comment);
      else
         ok = trade.SellLimit(signal.lot, signal.entry, sym, signal.sl, signal.tp, t, exp, comment);
   }
   else
   {
      if(signal.isBuy)
         ok = trade.Buy(signal.lot, sym, 0.0, signal.sl, signal.tp, comment);
      else
         ok = trade.Sell(signal.lot, sym, 0.0, signal.sl, signal.tp, comment);
   }

   if(ok)
      g_lastTradedBar = g_lastSignalBar;
   else
      Print("3711 Single EA trade failed: ", trade.ResultRetcode(), " ", trade.ResultRetcodeDescription());
   return ok;
}

void ManageOpenPositions(const string sym)
{
   if(!InpUseBreakEven && !InpUseAtrTrail)
      return;
   double atr=0.0;
   ReadATR(sym, InpSignalTf1, 1, atr);
   if(atr <= 0.0)
      return;
   int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != sym || (long)PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;

      long type = PositionGetInteger(POSITION_TYPE);
      bool isBuy = (type == POSITION_TYPE_BUY);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      double price = isBuy ? SymbolInfoDouble(sym, SYMBOL_BID) : SymbolInfoDouble(sym, SYMBOL_ASK);
      if(entry <= 0.0 || price <= 0.0 || sl <= 0.0)
         continue;
      double risk = MathAbs(entry - sl);
      if(risk <= 0.0)
         continue;
      double r = isBuy ? (price - entry) / risk : (entry - price) / risk;
      double newSl = sl;
      if(InpUseBreakEven && r >= InpBreakEvenAtR)
      {
         double be = isBuy ? entry + risk * InpBreakEvenLockR : entry - risk * InpBreakEvenLockR;
         if((isBuy && be > newSl) || (!isBuy && be < newSl))
            newSl = be;
      }
      if(InpUseAtrTrail && r >= InpTrailStartR)
      {
         double trail = isBuy ? price - atr * InpTrailAtrMult : price + atr * InpTrailAtrMult;
         if((isBuy && trail > newSl) || (!isBuy && trail < newSl))
            newSl = trail;
      }
      newSl = NormalizeDouble(newSl, digits);
      if(MathAbs(newSl - sl) > SymbolInfoDouble(sym, SYMBOL_POINT))
         trade.PositionModify(ticket, newSl, tp);
   }
}

void WriteCsv(const string sym,const SignalRead &signal)
{
   if(!InpWriteCsv || g_lastCsvBar == g_lastSignalBar)
      return;
   int h = FileOpen(InpCsvName, FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ, ',');
   if(h == INVALID_HANDLE)
   {
      Print("CSV open failed: ", InpCsvName, " err=", GetLastError());
      return;
   }
   if(FileSize(h) <= 0)
   {
      FileWrite(h,
                "timestamp","bar_time","symbol","side","valid","stage","score",
                "entry","sl","tp","lot","rr","risk_money",
                "stoch_tf1","stoch_tf2","stoch_tf3","stoch_tf4",
                "rsi_div","stoch_div","stoch_cross","formula","candle","reason");
   }
   FileSeek(h, 0, SEEK_END);
   FileWrite(h,
             TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS),
             TimeToString(g_lastSignalBar, TIME_DATE|TIME_SECONDS),
             sym,
             signal.isBuy ? "BUY" : "SELL",
             signal.valid ? "1" : "0",
             signal.stage,
             DoubleToString(signal.score, 2),
             DoubleToString(signal.entry, (int)SymbolInfoInteger(sym, SYMBOL_DIGITS)),
             DoubleToString(signal.sl, (int)SymbolInfoInteger(sym, SYMBOL_DIGITS)),
             DoubleToString(signal.tp, (int)SymbolInfoInteger(sym, SYMBOL_DIGITS)),
             DoubleToString(signal.lot, 2),
             DoubleToString(signal.rr, 2),
             DoubleToString(signal.riskMoney, 2),
             DoubleToString(signal.stoch1, 1),
             DoubleToString(signal.stoch2, 1),
             DoubleToString(signal.stoch3, 1),
             DoubleToString(signal.stoch4, 1),
             signal.rsiDiv,
             signal.stochDiv,
             signal.stochCross,
             signal.formulaState,
             signal.candleState,
             signal.reason);
   FileClose(h);
   g_lastCsvBar = g_lastSignalBar;
}

int OnInit()
{
   g_symbol = InpTradeSymbol;
   if(StringLen(g_symbol) <= 0)
      g_symbol = Symbol();
   if(!SymbolSelect(g_symbol, true))
   {
      Print("Cannot select symbol: ", g_symbol);
      return INIT_FAILED;
   }
   
   // Initialize all indicator handles ONCE at startup for optimal performance
   // This eliminates the major performance bottleneck of creating/destroying handles on every tick
   
   // Stochastic handles for each timeframe
   g_handleStoch1 = iStochastic(g_symbol, InpSignalTf1, InpKPeriod, InpDPeriod, InpSlowing, InpStochMethod, InpStochPrice);
   g_handleStoch2 = iStochastic(g_symbol, InpSignalTf2, InpKPeriod, InpDPeriod, InpSlowing, InpStochMethod, InpStochPrice);
   g_handleStoch3 = iStochastic(g_symbol, InpSignalTf3, InpKPeriod, InpDPeriod, InpSlowing, InpStochMethod, InpStochPrice);
   g_handleStoch4 = iStochastic(g_symbol, InpSignalTf4, InpKPeriod, InpDPeriod, InpSlowing, InpStochMethod, InpStochPrice);
   
   // Divergence detection handles
   g_handleRsiDiv = iRSI(g_symbol, InpDivergenceTf, InpRSIPeriod, PRICE_CLOSE);
   g_handleStochDiv = iStochastic(g_symbol, InpDivergenceTf, InpKPeriod, InpDPeriod, InpSlowing, InpStochMethod, InpStochPrice);
   
   // Formula pack handles
   g_handleATR = iATR(g_symbol, FormulaTf(), InpATRPeriod);
   g_handleBands = iBands(g_symbol, FormulaTf(), InpBandsPeriod, 0, InpBandsDeviation, PRICE_CLOSE);
   g_handleMA5High = iMA(g_symbol, FormulaTf(), 5, 0, MODE_LWMA, PRICE_HIGH);
   g_handleMA5Low = iMA(g_symbol, FormulaTf(), 5, 0, MODE_LWMA, PRICE_LOW);
   g_handleMA10High = iMA(g_symbol, FormulaTf(), 10, 0, MODE_LWMA, PRICE_HIGH);
   g_handleMA10Low = iMA(g_symbol, FormulaTf(), 10, 0, MODE_LWMA, PRICE_LOW);
   g_handleRSI = iRSI(g_symbol, FormulaTf(), InpRSIPeriod, PRICE_CLOSE);
   
   // Validate critical handles
   if(g_handleStoch1 == INVALID_HANDLE || g_handleATR == INVALID_HANDLE || g_handleBands == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles. Error code: ", GetLastError());
      return INIT_FAILED;
   }
   
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpDeviationPoints);
   Print("3711 Single EA OPTIMIZED initialized on ", g_symbol,
         " | TF ", TfText(InpSignalTf1),
         " | Direction ", EnumToString(InpTradeDirection),
         " | Mode ", EnumToString(InpEntryMode),
         " | CSV ", InpCsvName,
         " | Handles cached for performance");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   // Release all indicator handles on deinitialization
   if(g_handleStoch1 != INVALID_HANDLE) IndicatorRelease(g_handleStoch1);
   if(g_handleStoch2 != INVALID_HANDLE) IndicatorRelease(g_handleStoch2);
   if(g_handleStoch3 != INVALID_HANDLE) IndicatorRelease(g_handleStoch3);
   if(g_handleStoch4 != INVALID_HANDLE) IndicatorRelease(g_handleStoch4);
   if(g_handleRsiDiv != INVALID_HANDLE) IndicatorRelease(g_handleRsiDiv);
   if(g_handleStochDiv != INVALID_HANDLE) IndicatorRelease(g_handleStochDiv);
   if(g_handleATR != INVALID_HANDLE) IndicatorRelease(g_handleATR);
   if(g_handleBands != INVALID_HANDLE) IndicatorRelease(g_handleBands);
   if(g_handleMA5High != INVALID_HANDLE) IndicatorRelease(g_handleMA5High);
   if(g_handleMA5Low != INVALID_HANDLE) IndicatorRelease(g_handleMA5Low);
   if(g_handleMA10High != INVALID_HANDLE) IndicatorRelease(g_handleMA10High);
   if(g_handleMA10Low != INVALID_HANDLE) IndicatorRelease(g_handleMA10Low);
   if(g_handleRSI != INVALID_HANDLE) IndicatorRelease(g_handleRSI);
   
   Print("3711 Single EA deinit reason=", reason, " - all handles released");
}

void OnTick()
{
   if(StringLen(g_symbol) <= 0)
      return;
   ManageOpenPositions(g_symbol);

   datetime barTime = iTime(g_symbol, InpSignalTf1, 0);
   if(barTime <= 0 || barTime == g_lastSignalBar)
      return;
   g_lastSignalBar = barTime;

   SignalRead signal;
   if(!BuildSignal(g_symbol, signal))
   {
      WriteCsv(g_symbol, signal);
      return;
   }
   WriteCsv(g_symbol, signal);
   ExecuteSignal(g_symbol, signal);
}
