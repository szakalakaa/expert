// nie skasowal sellstopow (dodanych ) po zamknieciu pozycji

//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
CTrade trade;

input double atr_period = 240;
input double atr_multiplier = 2.8;
input double stoplos = 0.01;
input double offset_BS = 0; // offset buy sell
int laverage = 3;           // lewar początkowy

bool securelPartAfterTMAMiddleFlag = false;

string type_position = "NO POSITION", TMA_signal = "";
double ask, bid, last, Lots;

// indicators
int tma_handle, stoch_handle;
enum enPrices
{
   pr_weighted
};

double lotsSecured, positionOpenPrice, spread;
double saldo = AccountInfoDouble(ACCOUNT_BALANCE); // zmienna przechowująca początkową wartość salda
double TMAbands_down[], TMAbands_up[], TMAbands_middle[];

input double STOCH_up = 75;   // deklaracja zmiennej przechowującej wartość górnej wartosci dla STOCH, domślnie 80
input double STOCH_down = 15; // deklaracja zmiennej przechowującej wartość dolnej wartosci dla STOCH, domyślnie 20
string stochSignal = "";
//+------------------------------------------------------------------+
//|    1000 usd = 0.01Lot
//|   trade.Buy(NormalizeDouble(Lots*laverage,4),NULL,ask,0,0,"standard buy");                                                          |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("Robot 7 started!");
   ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
   spread = (ask - bid);
   tma_handle = iCustom(Symbol(), 0, "tma_indikator.ex5", 12, pr_weighted, atr_period, atr_multiplier, 4, 0);
   stoch_handle = iStochastic(_Symbol, _Period, 13, 3, 3, MODE_SMA, STO_LOWHIGH);
   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnTick()
{
   ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
   Lots = AccountInfoDouble(ACCOUNT_BALANCE) / last / 10;

   MqlRates candlesticks_info[];
   ArraySetAsSeries(candlesticks_info, true);
   int Data = CopyRates(Symbol(), Period(), 0, 3, candlesticks_info);

   ArraySetAsSeries(TMAbands_down, true);
   ArraySetAsSeries(TMAbands_up, true);
   ArraySetAsSeries(TMAbands_middle, true);
   CopyBuffer(tma_handle, 3, 1, 2, TMAbands_down);
   CopyBuffer(tma_handle, 2, 1, 2, TMAbands_up);
   CopyBuffer(tma_handle, 0, 1, 2, TMAbands_middle);

   double K_period[]; // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
   double D_period[]; // deklaracja tablicy przechowującej wartości  %D "wolnej", okresowej średnia kroczącej
   ArraySetAsSeries(K_period, true);
   ArraySetAsSeries(D_period, true);
   CopyBuffer(stoch_handle, 0, 0, 3, K_period);
   CopyBuffer(stoch_handle, 1, 0, 3, D_period);

   addStopLoss();

   // STOCH INDICATOR
   // if((K_period[0]<STOCH_down)&&(D_period[0]<STOCH_down))
   //   {
   //    if((K_period[0]>D_period[0])&&(K_period[1]<D_period[1]))
   //      {
   //       stochSignal="Przeciecie od dołu";  // jeżeli obie wartości K,D są poniżej bandy a nastepnie następuję przecięcie
   //      }
   //   }
   // if((K_period[0]>STOCH_up)&&(D_period[0]>STOCH_up))
   //   {
   //    if((K_period[0]<D_period[0])&&(K_period[1]>D_period[1]))
   //      {
   //        stochSignal="Przeciecie od góry";  // jeżeli obie wartości K,D są powyżej bandy a nastepnie następuję przecięcie
   //      }
   //   }

   // TMA INDICATOR
   if ((last < TMAbands_down[0]) && (type_position != "LONG"))
      TMA_signal = "buy";

   if ((last > TMAbands_up[0]) && (type_position != "SHORT"))
      TMA_signal = "sell";

   // MAIN BUY
   if (TMA_signal == "buy")
   {
      if ((last > candlesticks_info[1].close * (1 + offset_BS)) && (last < TMAbands_down[0]))
      {
         if (type_position == "SHORT")
         {
            trade.PositionClose(PositionGetTicket(0));
            if (OrdersTotal() != 0)
               trade.OrderDelete(OrderGetTicket(0));
            // type_position="NO POSITION";
         }
         trade.Buy(NormalizeDouble(Lots * laverage, 4), NULL, ask, 0, 0, "standard buy");
         Print("Bought: ", NormalizeDouble(Lots * laverage, 4), " lots for the ask price: ", DoubleToString(ask, _Digits), ". Spread is: ", spread, "   Triggered by last price: ", last);
         Print("---buy: tma_upper: " + DoubleToString(TMAbands_up[0], _Digits) + "        tma_mid" + DoubleToString(TMAbands_middle[0], _Digits) + "        tma_down: " + DoubleToString(TMAbands_down[0], _Digits) + "bid:" + DoubleToString(bid, _Digits));
         if (OrdersTotal() != 0)
            trade.OrderDelete(OrderGetTicket(0));
         type_position = "LONG";
         TMA_signal = "";
         securelPartAfterTMAMiddleFlag = false;
      }
   }
   // MAIN SELL
   if (TMA_signal == "sell")
   {
      if ((last < candlesticks_info[1].close * (1 - offset_BS)) && (last > TMAbands_up[0]))
      {
         if (type_position == "LONG")
         {
            trade.PositionClose(PositionGetTicket(0));
            if (OrdersTotal() != 0)
               trade.OrderDelete(OrderGetTicket(0));
            // type_position="NO POSITION";
         }
         trade.Sell(NormalizeDouble(Lots * laverage, 4), NULL, bid, 0, 0, "standard sell");
         Print("Sold: ", NormalizeDouble(Lots * laverage, 4), " lots for the bid price: ", DoubleToString(bid, _Digits), ". Spread is: ", spread, "   Triggered by last price: ", last);
         Print("---sell: tma_upper: " + DoubleToString(TMAbands_up[0], _Digits) + "        tma_mid" + DoubleToString(TMAbands_middle[0], _Digits) + "        tma_down: " + DoubleToString(TMAbands_down[0], _Digits) + "ask:" + DoubleToString(ask, _Digits));

         if (OrdersTotal() != 0)
            trade.OrderDelete(OrderGetTicket(0));
         type_position = "SHORT";
         TMA_signal = "";
         securelPartAfterTMAMiddleFlag = false;
      }
   }

   // HALF SECURE
   if (!securelPartAfterTMAMiddleFlag)
   {
      if (Symbol() == PositionGetSymbol(0))
      {
         lotsSecured = NormalizeDouble((PositionGetDouble(POSITION_VOLUME) / 2), 2);
         positionOpenPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), 0);
         // Secure long position
         if ((last > TMAbands_middle[0]) && (type_position == "LONG"))
         {
            double halfLowerPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_down[0]) / 2, 0);
            if (last > positionOpenPrice)
               trade.SellStop(lotsSecured, halfLowerPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "SS halfLowerPrice");
            else
               trade.SellStop(lotsSecured, NormalizeDouble(TMAbands_down[0], 0), _Symbol, 0, 0, ORDER_TIME_GTC, 0, "SS TMAbands_down price");
            securelPartAfterTMAMiddleFlag = true;
         }
         // Secure short position
         if ((last < TMAbands_middle[0]) && (type_position == "SHORT"))
         {
            double halfUpperPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_up[0]) / 2, 0);
            if (last < positionOpenPrice)
               trade.BuyStop(lotsSecured, halfUpperPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "BS halfUpperPrice");
            else
               trade.BuyStop(lotsSecured, NormalizeDouble(TMAbands_up[0], 0), _Symbol, 0, 0, ORDER_TIME_GTC, 0, "BS TMAbands_up price");
            securelPartAfterTMAMiddleFlag = true;
         }
      }
   }

   string comment;
   comment += "\nbid: " + DoubleToString(bid, _Digits);
   comment += "\nask: " + DoubleToString(ask, _Digits);
   comment += "\nlast: " + DoubleToString(last, _Digits);
   comment += "\n: ";
   comment += "\nspread: " + DoubleToString((ask - bid), _Digits);
   comment += "\nTMA_signal: " + TMA_signal;
   comment += "\ntype position: " + type_position;
   comment += "\nPOSITION_PRICE_OPEN: " + DoubleToString(NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), 0), _Digits);
   comment += "\n: ";
   comment += "\nTMAbands_up[0]: " + DoubleToString(TMAbands_up[0], _Digits);
   comment += "\nTMAbands_middle[0]: " + DoubleToString(TMAbands_middle[0], _Digits);
   comment += "\nTMAbands_down[0]: " + DoubleToString(TMAbands_down[0], _Digits);
   comment += "\n: ";
   comment += "\nAccountInfoDouble(ACCOUNT_BALANCE): " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE)) + " usd";
   comment += "\ndawka lots: " + DoubleToString(NormalizeDouble(Lots * laverage * 100000, 5), 2) + " usd";
   comment += "\nsecurelPartAfterTMAMiddleFlag: " + securelPartAfterTMAMiddleFlag;
   comment += "\n: ";
   comment += "\nlotsSecured : " + lotsSecured;
   comment += "\n positionOpenPrice: " + positionOpenPrice;
   comment += "\nstochSignal: " + stochSignal;
   Comment(comment);
} // end tick

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void addStopLoss()
{
   if ((PositionsTotal() != 0) && (OrdersTotal() == 0))
   {

      if (Symbol() == PositionGetSymbol(0))
      {
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
            trade.SellStop(PositionGetDouble(POSITION_VOLUME), NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN) * (1 - stoplos), 0), _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop loss triggered");
         }
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         {
            trade.BuyStop(PositionGetDouble(POSITION_VOLUME), NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN) * (1 + stoplos), 0), _Symbol, 0, 0, ORDER_TIME_GTC, 0, "buy stop loss triggered");
         }
      }
   }
   if (PositionsTotal() == 0)
   {
      type_position = "NO POSITION";

      if (OrdersTotal() != 0)
      {

         ulong ticket = 0;
         for (int i = 0; i < OrdersTotal(); i++)
         {
            trade.OrderDelete(OrderGetTicket(i));
         }
      }
   }
}

//+------------------------------------------------------------------+
