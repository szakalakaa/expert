//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include<Trade\Trade.mqh>
CTrade trade;

int laverage = 6;     // lewar początkowy
input double atr_period = 200;
input double atr_multiplier = 3;
input double stoplos=0.005;
input double offset_BS=0.001;  //offset buy sell
double offset_SL=0.001;  //offset stoploss

bool stopLossChanged=false;
bool securelPartAfterTMAMiddleFlag=false;
string type_position = "NO POSITION",TMA_signal="";
double ask,bid,last;

int tma_handle;
enum enPrices {pr_weighted};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double saldo=AccountInfoDouble(ACCOUNT_BALANCE); // zmienna przechowująca początkową wartość salda
double TMAbands_down[],TMAbands_up[],TMAbands_middle[],spread,Lots;


//+------------------------------------------------------------------+
//|    1000 usd = 0.01Lot
//|   trade.Buy(NormalizeDouble(Lots*laverage,4),NULL,ask,0,0,"standard buy");                                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Robot9 started!");
   ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   last=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_LAST),_Digits);
   Lots=0.01;
   spread=(ask-bid);
   tma_handle=iCustom(Symbol(),0,"tma_indikator.ex5",12,pr_weighted,atr_period,atr_multiplier,4,0);
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnTick()
  {
   ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   last=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_LAST),_Digits);
   Lots=AccountInfoDouble(ACCOUNT_BALANCE)/last/10;

   MqlRates candlesticks_info[];
   ArraySetAsSeries(candlesticks_info,true);
   int Data=CopyRates(Symbol(),Period(),0,3,candlesticks_info);

   ArraySetAsSeries(TMAbands_down,true);
   ArraySetAsSeries(TMAbands_up,true);
   ArraySetAsSeries(TMAbands_middle,true);
   CopyBuffer(tma_handle,3,1,2,TMAbands_down);
   CopyBuffer(tma_handle,2,1,2,TMAbands_up);
   CopyBuffer(tma_handle,0,1,2,TMAbands_middle);

   if(TMAbands_up[0]<100)
      Print("LOW TMA :  "+TMAbands_up[0]);

   addStopLoss();

   if((last<TMAbands_down[0])&&(type_position!="LONG"))
      TMA_signal="buy";

   if((last>TMAbands_up[0])&&(type_position!="SHORT"))
      TMA_signal="sell";

   if(TMA_signal=="buy")
     {
      if((last>candlesticks_info[1].close*(1+offset_BS))&&(last<TMAbands_middle[0]))
        {
         if(type_position=="SHORT")
           {
            trade.PositionClose(PositionGetTicket(0));
            stopLossChanged=false;
            securelPartAfterTMAMiddleFlag=false;
            if(OrdersTotal()!=0)
               trade.OrderDelete(OrderGetTicket(0));
            type_position="NO POSITION";
           }

         trade.Buy(NormalizeDouble(Lots*laverage,4),NULL,ask,0,0,"standard buy");
         Print("Bought: ",NormalizeDouble(Lots*laverage,4)," lots for the ask price: ",DoubleToString(ask,_Digits),". Spread is: ",spread," Triggered by last price: ",last);
         Print("---buy: tma_upper: "+DoubleToString(TMAbands_up[0],_Digits)+"        tma_mid"+DoubleToString(TMAbands_middle[0],_Digits)+"        tma_down: "+DoubleToString(TMAbands_down[0],_Digits)+"bid:" + DoubleToString(bid,_Digits));

         if(OrdersTotal()!=0)
            trade.OrderDelete(OrderGetTicket(0));
         type_position="LONG";
         TMA_signal="";
        }
     }

   if(TMA_signal=="sell")
     {
      if((last<candlesticks_info[1].close*(1-offset_BS))&&(last>TMAbands_middle[0]))
        {
         if(type_position=="LONG")
           {
            trade.PositionClose(PositionGetTicket(0));
            stopLossChanged=false;
            securelPartAfterTMAMiddleFlag=false;
            if(OrdersTotal()!=0)
               trade.OrderDelete(OrderGetTicket(0));
            type_position="NO POSITION";
           }

         trade.Sell(NormalizeDouble(Lots*laverage,4),NULL,bid,0,0,"standard sell");

         Print("Sold: ",NormalizeDouble(Lots*laverage,4)," lots for the bid price: ",DoubleToString(bid,_Digits),". Spread is: ",spread," Triggered by last price: ",last);
         Print("---sell: tma_upper: "+DoubleToString(TMAbands_up[0],_Digits)+"        tma_mid"+DoubleToString(TMAbands_middle[0],_Digits)+"        tma_down: "+DoubleToString(TMAbands_down[0],_Digits)+"ask:" + DoubleToString(ask,_Digits));
         if(OrdersTotal()!=0)
            trade.OrderDelete(OrderGetTicket(0));
         type_position="SHORT";
         TMA_signal="";
        }

     }




   if((last>TMAbands_middle[0])&&(type_position=="LONG") && !securelPartAfterTMAMiddleFlag)
     {
      double lotsSecured = PositionGetDouble(POSITION_VOLUME)/2;
      trade.BuyStop(lotsSecured,TMAbands_down[0],_Symbol,0,0,ORDER_TIME_GTC,0,"partly sell stop buy triggered");
      Print("Sell stop for: ",lotsSecured," at the price: ",TMAbands_down[0]);
      securelPartAfterTMAMiddleFlag=true;
     }

   if((last<TMAbands_middle[0])&&(type_position=="SHORT") && !securelPartAfterTMAMiddleFlag)
     {
      double lotsSecured = PositionGetDouble(POSITION_VOLUME)/2;
      trade.BuyStop(lotsSecured,TMAbands_down[0],_Symbol,0,0,ORDER_TIME_GTC,0,"partly buy stop buy triggered");
      Print("Buy stop for: ",lotsSecured," at the price: ",TMAbands_down[0]);
      securelPartAfterTMAMiddleFlag=true;
     }




//   if(PositionsTotal()!=0 && OrdersTotal()!=0 && !stopLossChanged)
//     {
//      if(type_position=="LONG")
//        {
//         if(candlesticks_info[1].close>TMAbands_middle[0])
//           {
//
//            double newStop=NormalizeDouble(TMAbands_middle[0]*(1-offset_SL),0);
//            ulong orderTicket=OrderGetTicket(0);
//            bool modified =trade.OrderModify(orderTicket,newStop,0,0,ORDER_TIME_GTC,0,"Buy stop modified: "+newStop);
//            stopLossChanged=true;
//
//           }
//        }
//      if(type_position=="SHORT")
//        {
//         if(candlesticks_info[1].close<TMAbands_middle[0])
//           {
//            double newStop=NormalizeDouble(TMAbands_middle[0]*(1+offset_SL),0);
//            ulong orderTicket=OrderGetTicket(0);
//            bool modified =trade.OrderModify(orderTicket,newStop,0,0,ORDER_TIME_GTC,0,"Buy stop modified: "+newStop);
//            stopLossChanged=true;
//
//           }
//        }
//     }







   string comment;
   comment+="\nbid: "+DoubleToString(bid,_Digits);
   comment+="\nask: "+DoubleToString(ask,_Digits);
   comment+="\nlast: "+DoubleToString(last,_Digits);
   comment+="\n: ";
   comment+="\nspread: "+DoubleToString((ask-bid),_Digits);
   comment+="\nTMA_signal: "+TMA_signal;
   comment+="\ntype position: "+type_position;
   comment+="\nPOSITION_PRICE_OPEN: "+DoubleToString(NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),0),_Digits);
   comment+="\n: ";
   comment+="\nTMAbands_up[0]: "+DoubleToString(TMAbands_up[0],_Digits);
   comment+="\nTMAbands_middle[0]: "+DoubleToString(TMAbands_middle[0],_Digits);
   comment+="\nTMAbands_down[0]: "+DoubleToString(TMAbands_down[0],_Digits);
   comment+="\n: ";
   comment+="\nAccountInfoDouble(ACCOUNT_BALANCE): "+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE))+" usd";
   comment+="\ndawka lots: "+DoubleToString(NormalizeDouble(Lots*laverage*100000,5),2)+" usd";
   comment+="\n: ";
   Comment(comment);
  } //end tick




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void addStopLoss()
  {
   if((PositionsTotal()!=0)&&(OrdersTotal()==0))
     {

      if(Symbol()==PositionGetSymbol(0))
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            trade.SellStop(PositionGetDouble(POSITION_VOLUME),NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)*(1-stoplos),0),_Symbol,0,0,ORDER_TIME_GTC,0,"sell stop loss triggered");
           }
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            trade.BuyStop(PositionGetDouble(POSITION_VOLUME),NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)*(1+stoplos),0),_Symbol,0,0,ORDER_TIME_GTC,0,"buy stop loss triggered");
           }
        }
     }
   if(PositionsTotal()==0)
     {
      type_position="NO POSITION";

      if(OrdersTotal()!=0)
        {
         trade.OrderDelete(OrderGetTicket(0));
        }
     }
  }

//+------------------------------------------------------------------+
