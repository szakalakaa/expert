//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Utils\graphicPanel.mqh>
#include <Utils\utils.mqh>

CTrade trade;
CGraphicalPanel panel;

input group "====TMA====";
input double atr_period = 180;
input double atr_multiplier = 2.0;
input double stoploss = 0.014;
input double offset_BS = 0; // offset buy sell
input group "====STOCH====";
input double STOCH_up = 60;   // deklaracja zmiennej przechowującej wartość górnej wartosci dla STOCH, domślnie 80
input double STOCH_down = 40; // deklaracja zmiennej przechowującej wartość dolnej wartosci dla STOCH, domyślnie 20
string stochSignal = "";
int laverage = 6; // lewar początkowy

// flags
bool securelPartAfterTMAMiddleFlag = false;
bool shiftStopLossFlag = false;
bool shiftStopLossMoreFlag = false;

string type_position = "NO POSITION";
string TMA_signal = "";

// indicators
int tma_handle, stoch_handle;
enum enPrices
  {
   pr_weighted
  };

int barsTotal;
double ask, bid, last, Lots;
double lotsSecured, lotsToShift, positionOpenPrice, spread;
double TMAbands_down[], TMAbands_up[], TMAbands_middle[], dTMA;
/////
int OnInit()
  {
   Print("Robot started!");
   panel.Oninit();
   ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
   spread = (ask - bid);
   tma_handle = iCustom(Symbol(), 0, "tma_indikator.ex5", 12, pr_weighted, atr_period, atr_multiplier, 4, 0);
// stoch_handle = iStochastic(_Symbol, _Period, 13, 3, 3, MODE_SMA, STO_LOWHIGH);
   barsTotal = iBars(_Symbol, PERIOD_CURRENT);

   findOpenPosition(type_position);

   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   panel.Update();
   ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
   datetime time = iTime(_Symbol, PERIOD_M1, 0);
   int bars = iBars(_Symbol, PERIOD_CURRENT);

   if(bars != barsTotal)
     {
      Print("time: ",time);
      barsTotal = bars;
     }


// Lots = NormalizeDouble(laverage * AccountInfoDouble(ACCOUNT_BALANCE) / last / 10, 4);
// Lots = 0.022;
   Lots = NormalizeDouble((5*0.98*AccountInfoDouble(ACCOUNT_BALANCE)/last),4);
   MqlRates candlesticks_info[];
   ArraySetAsSeries(candlesticks_info, true);
   int Data = CopyRates(Symbol(), Period(), 0, 3, candlesticks_info);

   ArraySetAsSeries(TMAbands_down, true);
   ArraySetAsSeries(TMAbands_up, true);
   ArraySetAsSeries(TMAbands_middle, true);
   CopyBuffer(tma_handle, 3, 1, 2, TMAbands_down);
   CopyBuffer(tma_handle, 2, 1, 2, TMAbands_up);
   CopyBuffer(tma_handle, 0, 1, 2, TMAbands_middle);

   dTMA = NormalizeDouble(TMAbands_up[0] - TMAbands_down[0], 0);

// ADD FIRST STOPLOSS
   fitstStoplosss(type_position, stoploss, trade);

// TMA INDICATOR
   if((last < TMAbands_down[0]) && (type_position != "LONG"))
      TMA_signal = "buy";

   if((last > TMAbands_up[0]) && (type_position != "SHORT"))
      TMA_signal = "sell";

// MAIN BUY
   if(TMA_signal == "buy")
     {
      if((last > candlesticks_info[1].close * (1 + offset_BS)) && (last < TMAbands_down[0]))
        {
         if(type_position == "SHORT")
           {
            trade.PositionClose(PositionGetTicket(0));
            if(OrdersTotal() != 0)
               trade.OrderDelete(OrderGetTicket(0));
           }
         if(!trade.Buy(Lots, NULL, ask, 0, 0, "standard buy"))
            Print("--ERROR 5 on standard buy");

         if(OrdersTotal() != 0)
            trade.OrderDelete(OrderGetTicket(0));
         type_position = "LONG";
         TMA_signal = "";
         securelPartAfterTMAMiddleFlag = false;
         shiftStopLossFlag = false;
         shiftStopLossMoreFlag = false;
        }
     }
// MAIN SELL
   if(TMA_signal == "sell")
     {
      if((last < candlesticks_info[1].close * (1 - offset_BS)) && (last > TMAbands_up[0]))
        {
         if(type_position == "LONG")
           {
            trade.PositionClose(PositionGetTicket(0));
            if(OrdersTotal() != 0)
               trade.OrderDelete(OrderGetTicket(0));
           }
         if(!trade.Sell(Lots, NULL, bid, 0, 0, "standard sell"))
            Print("--ERROR 5 on standard sell");

         if(OrdersTotal() != 0)
            trade.OrderDelete(OrderGetTicket(0));
         type_position = "SHORT";
         TMA_signal = "";
         securelPartAfterTMAMiddleFlag = false;
         shiftStopLossFlag = false;
         shiftStopLossMoreFlag = false;
        }
     }

// ADD SECOND STOPLOSS
// if (!securelPartAfterTMAMiddleFlag)
// {
//     if (Symbol() == PositionGetSymbol(0))
//     {
//         lotsSecured = NormalizeDouble((PositionGetDouble(POSITION_VOLUME) / 2), 3);
//         positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
//         double trigPriceShort = positionOpenPrice - 50;
//         double trigPriceLong = positionOpenPrice + 50;

//         // Secure long position
//         if ((last > TMAbands_middle[0]) && (type_position == "LONG"))
//         {
//             double halfLowerPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_down[0]) / 2, 0);

//             if (last > trigPriceLong)
//             {
//                 secondStoploss(halfLowerPrice, trade);
//                 createObject(time, last, 168, clrLightCyan, "1");
//                 securelPartAfterTMAMiddleFlag = true;
//             }
//         }
//         // Secure short position
//         if ((last < TMAbands_middle[0]) && (type_position == "SHORT"))
//         {
//             double halfUpperPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_up[0]) / 2, 0);

//             if (last < trigPriceShort)
//             {
//                 secondStoploss(halfUpperPrice, trade);
//                 createObject(time, last, 168, clrMistyRose, "1");
//                 securelPartAfterTMAMiddleFlag = true;
//             }
//         }
//     }
// }

// SHIFT STOPLOSS
// if (securelPartAfterTMAMiddleFlag && !shiftStopLossFlag)
// {
//     if (Symbol() == PositionGetSymbol(0))
//     {
//         double halfLowerPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_down[0]) / 2, 0);
//         double halfUpperPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_up[0]) / 2, 0);

//         if ((last > halfUpperPrice) && (type_position == "LONG"))
//         {
//             shiftStoplosses(NormalizeDouble(TMAbands_middle[0], 0), halfLowerPrice, type_position, stoploss, trade);
//             shiftStopLossFlag = true;
//             shiftStopLossMoreFlag = true;
//             createObject(time, last, 171, clrLightBlue, "1");
//         }
//         if ((last < halfLowerPrice) && (type_position == "SHORT"))
//         {
//             shiftStoplosses(NormalizeDouble(TMAbands_middle[0], 0), halfUpperPrice, type_position, stoploss, trade);
//             shiftStopLossFlag = true;
//             shiftStopLossMoreFlag = true;
//             createObject(time, last, 171, clrLightPink, "1");
//         }
//     }
// }

// SHIFT STOPLOSS MORE
// if (shiftStopLossMoreFlag)
// {

//     if (Symbol() == PositionGetSymbol(0))
//     {
//         double halfLowerPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_down[0]) / 2, 0);
//         double halfUpperPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_up[0]) / 2, 0);

//         if ((last > TMAbands_up[0]) && (type_position == "LONG"))
//         {
//             shiftStoplosses(halfUpperPrice, NormalizeDouble(TMAbands_middle[0], 0), type_position, stoploss, trade);
//             shiftStopLossMoreFlag = false;
//             createObject(time, last, 174, clrDodgerBlue, "1");
//         }
//         if ((last < TMAbands_down[0]) && (type_position == "SHORT"))
//         {
//             shiftStoplosses(halfLowerPrice, NormalizeDouble(TMAbands_middle[0], 0), type_position, stoploss, trade);
//             shiftStopLossMoreFlag = false;
//             createObject(time, last, 174, clrIndianRed, "1");
//         }
//     }
// }

  } // end tick

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   panel.PanelChartEvent(id, lparam, dparam, sparam);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   panel.Destroy(reason);
  }
//+------------------------------------------------------------------+
