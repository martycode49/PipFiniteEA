//+------------------------------------------------------------------+
//|                                         PipFinite_Based_EA 2.mq4 |
//|                                         Copyright 2022, Marty    |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Marty49"
#property link      ""
#property version   "2.00"
#property strict
enum RiskCalc {
	AA = 1//AccountBalance
	, BB = 2//AccountEquity
	, CC = 3//AccountFreeMargin
};
input string NameEA = "PipFinite Breakout EA";//EA Comment
input string Indicators_Parameters_ = "______________________________________________________";//Indicators Settings _______________________________________________
input string                           _ = "<<<<<<<<<<<<<<<<<<<<<->>>>>>>>>>>>>>>>>>>>>";//PipFinite Breakout Analyzer   
input int    Periods = 4;            //Period  
input string                ___________ = "<<<<<<<<<<<<<<<<<<<<<->>>>>>>>>>>>>>>>>>>>>";//PipFinite Strength Meter    
input int    SMPeriod = 7;            //Period 
input int    ThresholdLevel = 2;            //Threshold Level
input string                      ______ = "<<<<<<<<<<<<<<<<<<<<<->>>>>>>>>>>>>>>>>>>>>";//PipFinite Exit Scope 
input int    bb = 1;            //Volume Factor
input string                    ________ = "<<<<<<<<<<<<<<<<<<<<<->>>>>>>>>>>>>>>>>>>>>";//Indicator ATR
input int    ATRPeriod = 14;           //ATR Period
input double ATRMulti = 1.25;            //ATR Multiplier 
input double ATROffset = 0;            //ATR Offset
input string Trade_Parameters_ = "______________________________________________________";//Trade Parameters _______________________________________________
input double StopLoss = 0;            //Stop Loss
input double TakeProfit = 100;          //Take Profit
input bool   ExitOpposite = false;            //Exit by Opposite Signal
input bool   ExitScope = false;            //Exit by PipFinite Exit Scope
input int    MaxOpenOrders = 1;            //Max. Open Orders
input double MinEntryPercent = 78.0;      // Minimum percent for Entry trade
input string Trailing_ = "--------------------< Trailing Stop >--------------------";//Trailing Stop Settings ............................................................................................................
input bool   UseTrailing_Stop = false;        //Use Trailing Stop
input double TrailingStopStart = 10;           //Trailing Stop Start
input double TrailingStopStep = 10;           //Trailing Stop Step
input string MM_Settings = "--------------------< Money Management >--------------------";//Money Management Settings ...........................................................................................................
input double FixedLots = 0.01;          //Fixed Lot 
input bool   RiskLots = false;            //Use Risk % Lot 
input RiskCalc Risk_Type = 1;            //Risk Calculate Type
input double RiskPercent = 1;            //Risk % 
input string Time_Filter = "--------------------< Trade Time >--------------------";//Trade Time Settings ............................................................................................................  
input bool   Use_Time_Filter = false;        //Use Time Filter
input string Time_Start = "06:00";      //Time Start 
input string Time_End = "21:59";      //Time End 
input bool   StoponFriday = false;        //Stop/Close on Friday
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
double Drawdown, AllProfit = 0, point, ClosingArray[100], Lots, Sloss, Tprof, SLBUY = 0, buy = 0, sell = 0, buy1 = 0, sell1 = 0, buy2 = 0, sell2 = 0, buy3 = 0, sell3 = 0, risk, SLL = 0, LastLot = 0, lot = 0, atr = 0, Tp1, Tp1percent;
bool Long = false, Short = false, Long2 = false, Short2 = false, Buy = false, Sell = false, Buy2 = false, Sell2 = false, Buy3 = false, Sell3 = false;
int PipValue = 1, Lot_Digits, signal, digit_lot = 0,zz = 0, xx = 0, supp = 0, arr = 0;
int    MagicNumber;   //Magic Number 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
	if ((Bid < 10 && _Digits == 5) || (Bid>10 && _Digits == 3)) { PipValue = 10; }
	if ((Bid < 10 && _Digits == 4) || (Bid>10 && _Digits == 2)) { PipValue = 1; }
	point = Point*PipValue;
	if (MarketInfo(Symbol(), MODE_LOTSTEP) >= 0.01) digit_lot = 2;
	if (MarketInfo(Symbol(), MODE_LOTSTEP) >= 0.1) digit_lot = 1;
	if (MarketInfo(Symbol(), MODE_LOTSTEP) >= 1) digit_lot = 0;
	clear("el4_");
	return(0);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH 
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
   clear("el4_");
	return(0);
}
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
//+------------------------------------------------------------------+
//| Make Magic Number |
//+------------------------------------------------------------------+
int MakeMagicNumber( int ExpertID, bool TimeSpecific )
{
   int SymbolCode = 0;
   int PeriodCode = 0;
   int MagicNumberInt = 0; 
    
   //---- Symbol Code
   if( Symbol() == "AUDCAD" || Symbol() == "AUDCADm" ) { SymbolCode = 1000; }
   else if( Symbol() == "AUDJPY" || Symbol() == "AUDJPYm" ) { SymbolCode = 2000; }
   else if( Symbol() == "AUDNZD" || Symbol() == "AUDNZDm" ) { SymbolCode = 3000; }
   else if( Symbol() == "AUDUSD" || Symbol() == "AUDUSDm" ) { SymbolCode = 4000; }
   else if( Symbol() == "CHFJPY" || Symbol() == "CHFJPYm" ) { SymbolCode = 5000; }
   else if( Symbol() == "EURAUD" || Symbol() == "EURAUDm" ) { SymbolCode = 6000; }
   else if( Symbol() == "EURCAD" || Symbol() == "EURCADm" ) { SymbolCode = 7000; }
   else if( Symbol() == "EURCHF" || Symbol() == "EURCHFm" ) { SymbolCode = 8000; }
   else if( Symbol() == "EURGBP" || Symbol() == "EURGBPm" ) { SymbolCode = 9000; }
   else if( Symbol() == "EURJPY" || Symbol() == "EURJPYm" ) { SymbolCode = 1000; }
   else if( Symbol() == "EURUSD" || Symbol() == "EURUSDm" ) { SymbolCode = 1100; }
   else if( Symbol() == "GBPCHF" || Symbol() == "GBPCHFm" ) { SymbolCode = 1200; }
   else if( Symbol() == "GBPJPY" || Symbol() == "GBPJPYm" ) { SymbolCode = 1300; }
   else if( Symbol() == "GBPUSD" || Symbol() == "GBPUSDm" ) { SymbolCode = 1400; }
   else if( Symbol() == "NZDJPY" || Symbol() == "NZDJPYm" ) { SymbolCode = 1500; }
   else if( Symbol() == "NZDUSD" || Symbol() == "NZDUSDm" ) { SymbolCode = 1600; }
   else if( Symbol() == "USDCAD" || Symbol() == "USDCADm" ) { SymbolCode = 1700; }
   else if( Symbol() == "USDCHF" || Symbol() == "USDCHFm" ) { SymbolCode = 1800; }
   else if( Symbol() == "USDJPY" || Symbol() == "USDJPYm" ) { SymbolCode = 1900; }
   else { SymbolCode = 9999; }
 
 
//---- Period Code
   if( TimeSpecific )
   {
      if( Period() == 1 ) { PeriodCode = 10; }
      else if( Period() == 5 ) { PeriodCode = 20; }
      else if( Period() == 15 ) { PeriodCode = 30; }
      else if( Period() == 30 ) { PeriodCode = 40; }
      else if( Period() == 60 ) { PeriodCode = 50; }
      else if( Period() == 240 ) { PeriodCode = 60; }
      else if( Period() == 1440 ) { PeriodCode = 70; }
      else if( Period() == 10080 ){ PeriodCode = 80; }
   }
   else
   {
      PeriodCode = 0;
   }
   //---- Calculate MagicNumber
   MagicNumberInt = ExpertID+SymbolCode+PeriodCode;
   return(MagicNumberInt);
}
//+------------------------------------------------------------------+
//| Time limited trading                                             |
//+------------------------------------------------------------------+    
bool GoodTime()
{
	if (!Use_Time_Filter)return(true);
	if (Use_Time_Filter)
	{
		if (TimeGMT() > StrToTime(Time_Start) && TimeGMT() < StrToTime(Time_End))return(true);
	}
	return(false);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//|  Lot Calculate                                                   |
//+------------------------------------------------------------------+
void LotsSize()
{
	Lots = FixedLots;
	if (Risk_Type == 1) { risk = AccountBalance(); }
	if (Risk_Type == 2) { risk = AccountEquity(); }
	if (Risk_Type == 3) { risk = AccountFreeMargin(); }
	if (Lots < MarketInfo(Symbol(), MODE_MINLOT)) Lots = MarketInfo(Symbol(), MODE_MINLOT);
	if (Lots > MarketInfo(Symbol(), MODE_MAXLOT)) Lots = MarketInfo(Symbol(), MODE_MAXLOT);
	if (MarketInfo(Symbol(), MODE_MINLOT) < 0.1)Lot_Digits = 2;
	if (RiskLots) { Lots = NormalizeDouble(risk * RiskPercent / 100000, digit_lot); }
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+----------------------------------------------------------------------------------+
//|  CloseBuy                                                                        |
//+----------------------------------------------------------------------------------+  
int CloseBuyW()
{
	for (int i = OrdersTotal() - 1;i >= 0;i--) {
		bool os = OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderType() == OP_BUY) {
				bool oc = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble
					(MarketInfo(Symbol(), MODE_BID), (int)MarketInfo(Symbol(), MODE_DIGITS)), 1000, Gold);
				Print("Closed by Weekend");
			}
			for (int x = 0;x < 100;x++)
			{
				if (ClosingArray[x] == 0)
				{
					ClosingArray[x] = OrderTicket();
					break;
				}
			}
		}
	}
	return(1);
}
//+----------------------------------------------------------------------------------+
//| CloseSell                                                                        |
//+----------------------------------------------------------------------------------+
int CloseSellW()
{
	for (int i = OrdersTotal() - 1;i >= 0;i--) {
		bool os = OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderType() == OP_SELL) {
				bool oc = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble
					(MarketInfo(Symbol(), MODE_ASK), (int)MarketInfo(Symbol(), MODE_DIGITS)), 1000, Gold);
				Print("Closed by Weekend");
			}
			for (int x = 0;x < 100;x++)
			{
				if (ClosingArray[x] == 0)
				{
					ClosingArray[x] = OrderTicket();
					break;
				}
			}
		}
	}
	return(1);
}
//+----------------------------------------------------------------------------------+
//|  CloseBuy                                                                        |
//+----------------------------------------------------------------------------------+  
int CloseBuyD()
{
	for (int i = OrdersTotal() - 1;i >= 0;i--) {
		bool os = OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderType() == OP_BUY) {
				bool oc = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble
					(MarketInfo(Symbol(), MODE_BID), (int)MarketInfo(Symbol(), MODE_DIGITS)), 1000, Gold);
				Print("Closed by Session End");
			}
			for (int x = 0;x < 100;x++)
			{
				if (ClosingArray[x] == 0)
				{
					ClosingArray[x] = OrderTicket();
					break;
				}
			}
		}
	}
	return(1);
}
//+----------------------------------------------------------------------------------+
//| CloseSell                                                                        |
//+----------------------------------------------------------------------------------+
int CloseSellD()
{
	for (int i = OrdersTotal() - 1;i >= 0;i--) {
		bool os = OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderType() == OP_SELL) {
				bool oc = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble
					(MarketInfo(Symbol(), MODE_ASK), (int)MarketInfo(Symbol(), MODE_DIGITS)), 1000, Gold);
				Print("Closed by Session End");
			}
			for (int x = 0;x < 100;x++)
			{
				if (ClosingArray[x] == 0)
				{
					ClosingArray[x] = OrderTicket();
					break;
				}
			}
		}
	}
	return(1);
}
//+----------------------------------------------------------------------------------+
//|  CloseBuy                                                                        |
//+----------------------------------------------------------------------------------+  
int CloseBuyE()
{
	for (int i = OrdersTotal() - 1;i >= 0;i--) {
		bool os = OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderType() == OP_BUY) {
				bool oc = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble
					(MarketInfo(Symbol(), MODE_BID), (int)MarketInfo(Symbol(), MODE_DIGITS)), 1000, Gold);
				Print("Closed by Exit Scope");
			}
			for (int x = 0;x < 100;x++)
			{
				if (ClosingArray[x] == 0)
				{
					ClosingArray[x] = OrderTicket();
					break;
				}
			}
		}
	}
	return(1);
}
//+----------------------------------------------------------------------------------+
//| CloseSell                                                                        |
//+----------------------------------------------------------------------------------+
int CloseSellE()
{
	for (int i = OrdersTotal() - 1;i >= 0;i--) {
		bool os = OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderType() == OP_SELL) {
				bool oc = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble
					(MarketInfo(Symbol(), MODE_ASK), (int)MarketInfo(Symbol(), MODE_DIGITS)), 1000, Gold);
				Print("Closed by Exit Scope");
			}
			for (int x = 0;x < 100;x++)
			{
				if (ClosingArray[x] == 0)
				{
					ClosingArray[x] = OrderTicket();
					break;
				}
			}
		}
	}
	return(1);
}
//+----------------------------------------------------------------------------------+
//|  CloseBuy                                                                        |
//+----------------------------------------------------------------------------------+  
int CloseBuyO()
{
	for (int i = OrdersTotal() - 1;i >= 0;i--) {
		bool os = OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderType() == OP_BUY) {
				bool oc = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble
					(MarketInfo(Symbol(), MODE_BID), (int)MarketInfo(Symbol(), MODE_DIGITS)), 1000, Gold);
				Print("Closed by Opposite Breakout Analyzer");
			}
			for (int x = 0;x < 100;x++)
			{
				if (ClosingArray[x] == 0)
				{
					ClosingArray[x] = OrderTicket();
					break;
				}
			}
		}
	}
	return(1);
}
//+----------------------------------------------------------------------------------+
//| CloseSell                                                                        |
//+----------------------------------------------------------------------------------+
int CloseSellO()
{
	for (int i = OrdersTotal() - 1;i >= 0;i--) {
		bool os = OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderType() == OP_SELL) {
				bool oc = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble
					(MarketInfo(Symbol(), MODE_ASK), (int)MarketInfo(Symbol(), MODE_DIGITS)), 1000, Gold);
				Print("Closed by Opposite Breakout Analyzer");
			}
			for (int x = 0;x < 100;x++)
			{
				if (ClosingArray[x] == 0)
				{
					ClosingArray[x] = OrderTicket();
					break;
				}
			}
		}
	}
	return(1);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
void TrailingStops()
{
	for (int i = 0; i < OrdersTotal(); i++)
	{
		bool OrSel = OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderType() == OP_BUY && UseTrailing_Stop && TrailingStopStep > 0 && TrailingStopStart > 0)
			{
				if (Bid - OrderOpenPrice() > TrailingStopStart* point && Bid - OrderOpenPrice() > TrailingStopStart * point)
				{
					if (OrderStopLoss() < (Bid - TrailingStopStep* point))
						bool modify = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStopStep* point, OrderTakeProfit(), 0, Lime);
				}
			}
			if (OrderType() == OP_SELL && UseTrailing_Stop && TrailingStopStep > 0 && TrailingStopStart > 0)
			{
				if (OrderOpenPrice() - Ask > TrailingStopStart* point && OrderOpenPrice() - Ask > TrailingStopStart * point)
				{
					if (OrderStopLoss() == 0 || OrderStopLoss() > Ask + TrailingStopStep* point)
						bool modify = OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TrailingStopStep* point, OrderTakeProfit(), 0, Red);
				}
			}
		}
	}
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| get total order                                                  |
//+------------------------------------------------------------------+
int total()
{
	int counter = 0;
	for (int x = OrdersTotal() - 1;x >= 0;x--)
	{
		if (OrderSelect(x, 0) && OrderSymbol() == Symbol() &&
			OrderMagicNumber() == MagicNumber)
		{
			counter++;
		}
	}
	return(counter);
}
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
void Closer() {
	for (int i = 0; i < OrdersTotal(); i++)
	{
		bool os = OrderSelect(i, SELECT_BY_POS);
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderType() == OP_BUY)
			{
				if (Sell3 && ExitScope) { CloseBuyE(); }
			}
			if (OrderType() == OP_SELL)
			{
				if (Buy3 && ExitScope) { CloseSellE(); }
			}
			if (OrderType() == OP_BUY)
			{
				if (Sell2 && ExitOpposite) { CloseBuyO(); }
			}
			if (OrderType() == OP_SELL)
			{
				if (Buy2 && ExitOpposite) { CloseSellO(); }
			}
		}
	}
}
//OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO   
//+------------------------------------------------------------------+
//|  Open Rules                                                      |
//+------------------------------------------------------------------+

void Indicator()
{  
   double buf8 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",8 , 1);
   double buf9 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",9 , 1);
   double buf10 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",10 , 1); // UPTREND
   double buf11 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",11 , 1); // DOWNTREND
   double buf12 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",12 , 1); // TP1 PRICE
   double buf13 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",13 , 1); // TP2 PRICE
   double buf22 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",22 , 1); // TP1 HIT%
   double buf23 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",23 , 1); // TP2 HIT%
   double buf24 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",24 , 1); // EXIT WIN%
   double buf25 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",25 , 1); // EXIT LOSS%
   double buf26 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",26 , 1); // SIGNAL
   double buf27 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",27 , 1); // WINS
   double buf28 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",28 , 1); // LOSS
   double buf29 = iCustom(_Symbol, 0, "Market\\PipFinite Trend PRO",29 , 1); // SUCCESS RATE%*/
   
   

   atr = iATR(NULL, 0, ATRPeriod, 0);
   
   Buy = (buf8 != EMPTY_VALUE);
	Sell = (buf9 != EMPTY_VALUE);
	Tp1 = buf12;
	Tp1percent = buf22;
	
// ---------------------------------------------------+
//                                Display Data list   +
// ---------------------------------------------------+
      //---- Initialisation variables
       Settext(1,"Pipfinite EA Marty ");
       Settext(2,"B: " + DoubleToString(buf8,5)); // Buy
       Settext(3,"S: " + DoubleToString(buf9,5)); // Sell
       Settext(4,"UpTrend: " + DoubleToString(NormalizeDouble(buf10,Digits),Digits));   // UPTREND
       Settext(5,"DownTrend: " + DoubleToString(NormalizeDouble(buf11,Digits),Digits));   // DOWNTREND
       Settext(6,"TP1: " + DoubleToString(NormalizeDouble(buf12,Digits),Digits));   // TP1 PRICE
       Settext(7,"TP2: " + DoubleToString(NormalizeDouble(buf13,Digits),Digits));   // TP2 PRICE
       Settext(8,"TP1 HIT%: " + DoubleToString(buf22,2));   // TP1 HIT%
       Settext(9,"TP2 HIT%: " + DoubleToString(buf23,2));  // TP2 HIT%
       Settext(10,"EXIT WIN%: " + DoubleToString(buf24,2));   // EXIT WIN%
       Settext(11,"EXIT LOSS%: " + DoubleToString(buf25,2));  // EXIT LOSS%
       Settext(12,"SIGNAL: " + DoubleToString(buf26,0));  // SIGNAL
       Settext(13,"WINS: " + DoubleToString(buf27,0));  // WINS
       Settext(14,"LOSS: " + DoubleToString(buf28,0)); // LOSS
       Settext(15,"SUCCESS RATE%: " + DoubleToString(buf29,2));  // SUCCESS RATE% */
       Settext(16,"--------------------");
       Settext(17,"Lots: " + DoubleToString(Lots,2));  // Lots */
       Settext(18,"TP1: " + DoubleToString(NormalizeDouble(Tp1,Digits),Digits));  // Target Profit 1 */
       Settext(19,"TP1% Entry value: " + DoubleToString(MinEntryPercent,2));  // Tp1 % */
       Settext(20,"SL: " + DoubleToString(NormalizeDouble(Sloss,Digits),Digits));  // SL value */
       Settext(21,"Orders: " + DoubleToString(total(),0));  // Order in progress */
       Settext(22,"MagicNumber: " + IntegerToString(MagicNumber));  // Magic Number */
       
}


//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
	bool ban = false, band = false;
	MagicNumber = MakeMagicNumber(123, true);
	LotsSize();Indicator();TrailingStops();
	Closer();
	
	if (!GoodTime()) { CloseBuyD();CloseSellD();return(0); }
	if (StoponFriday && DayOfWeek() == 5) { CloseBuyW();CloseSellW();return(0); }
	//+------------------------------------------------------------------+
	for (int i = OrdersTotal() - 1; i >= 0; i--)
	{
		if (OrderSelect(i, SELECT_BY_POS))
		{
			if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
			{
				if (OrderOpenTime() >= iTime(NULL, 0, 0)) ban = true;
			}
		}
	}if (ban) { return(0); }
	//+------------------------------------------------------------------+
	for (int i = OrdersHistoryTotal() - 1;i >= 0;i--)
	{
		if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false)
		{
			Print("Error in history!"); break;
		}
		if (OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
		if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
			if (OrderOpenTime() >= iTime(NULL, 0, 0)) band = true;
		}
	}if (band) { return(0); }
	//+------------------------------------------------------------------+   
	if (total() < MaxOpenOrders && GoodTime() && Tp1percent >= MinEntryPercent)
	{
		if (Buy) {
			if (StopLoss == 0) { Sloss = Ask - (atr*ATRMulti) + ATROffset; }
			if (StopLoss != 0) { Sloss = Ask - StopLoss * point; }
			/*if (TakeProfit == 0) { Tprof = 0; }
			else { Tprof = Bid + TakeProfit * point; }*/
			Tprof = Tp1;
			int Tiketb = OrderSend(Symbol(), OP_BUY, Lots, Ask, PipValue, Sloss, Tprof, NameEA, MagicNumber, 0, Green);
		}
		if (Sell) {
			if (StopLoss == 0) { Sloss = Bid + (atr*ATRMulti) + ATROffset;; }
			if (StopLoss != 0) { Sloss = Bid + StopLoss * point; }
			/*if (TakeProfit == 0) { Tprof = 0; }
			else { Tprof = Ask - TakeProfit * point; }*/
			Tprof = Tp1;
			int Tikets = OrderSend(Symbol(), OP_SELL, Lots, Bid, PipValue, Sloss, Tprof, NameEA, MagicNumber, 0, Red);
		}
	}
	return(0);
}
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
void Settext(int line, string text)
{   
      string name="el4_"+"symbol"+IntegerToString(line);
      if(ObjectFind(name)==-1)
            ObjectCreate(name,OBJ_LABEL,0,0,0);
      ObjectSet(name,OBJPROP_XDISTANCE,1350);
      ObjectSet(name,OBJPROP_YDISTANCE,25*(line+2));
      ObjectSetText(name,text,10,"Tahoma",clrAquamarine);
      ObjectSet(name,OBJPROP_CORNER,0);
      ObjectSet(name,OBJPROP_BACK,false);
}
void clear(string prefix) // clear("el4_");
  {
   string name;
   int obj_total=ObjectsTotal();
//----
   for(int i=obj_total-1; i>=0; i--)
     {
      name=ObjectName(i);
      if(StringFind(name,prefix)==0)
         ObjectDelete(name);
     }
  }  
//+------------------------------------------------------------------+