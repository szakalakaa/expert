//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include<Trade\Trade.mqh>
CTrade trade;

input double atr_period = 200;
input double atr_multiplier = 1.7;
input double stoplos=0.02;
input double offset_BS=0.001;  //offset buy sell
//input int offset_SL=0.001;  //offset stoploss

string type_position = "NO POSITION",TMA_signal="";
double ask,bid,last;



int tma_handle;
enum enPrices {pr_weighted};

int laverage = 3;     // lewar początkowy
int laverage_profit=3;  //lewar dla pozycji zyskownych
int laverage_loss=1;    //lewar dla pozycji stratnych
double Lots=AccountInfoDouble(ACCOUNT_BALANCE)/23000;
double saldo=AccountInfoDouble(ACCOUNT_BALANCE); // zmienna przechowująca początkową wartość salda
double TMAbands_down[],TMAbands_up[],TMAbands_middle[];
double spread;

bool saved=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Robot8 started!");
   ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   last=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_LAST),_Digits);
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

   MqlRates candlesticks_info[];
   ArraySetAsSeries(candlesticks_info,true);
   int Data=CopyRates(Symbol(),Period(),0,3,candlesticks_info);

   ArraySetAsSeries(TMAbands_down,true);
   ArraySetAsSeries(TMAbands_up,true);
   ArraySetAsSeries(TMAbands_middle,true);
   CopyBuffer(tma_handle,3,1,2,TMAbands_down);
   CopyBuffer(tma_handle,2,1,2,TMAbands_up);
   CopyBuffer(tma_handle,0,1,2,TMAbands_middle);


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
            saved=false;
            if(OrdersTotal()!=0)
               trade.OrderDelete(OrderGetTicket(0));
            type_position="NO POSITION";
            check_saldo();
           }

         trade.Buy(NormalizeDouble(Lots*laverage,4),NULL,ask,0,0,"standard buy");
         Print("buy1: ask: "+DoubleToString(ask,_Digits)+"        bid:" + DoubleToString(bid,_Digits) +"       last: "+DoubleToString(last,_Digits)+"       tma signal: "+TMA_signal+"        type position: "+type_position);
         Print("buy2: tma_upper: "+DoubleToString(TMAbands_up[0],_Digits)+"        tma_mid"+DoubleToString(TMAbands_middle[0],_Digits)+"        tma_down: "+DoubleToString(TMAbands_down[0],_Digits));
         Print("buy3: spread: "+DoubleToString(spread,_Digits));
         if(OrdersTotal()!=0)
            trade.OrderDelete(OrderGetTicket(0));
         type_position="LONG";
         TMA_signal="";
        }
     }


//---check, to remove later

   if(TMAbands_middle[0]<100)
     {
      Print("Tma mid is low 0: "+DoubleToString(TMAbands_middle[0],_Digits));
      Print("Tma mid is low 1: "+DoubleToString(TMAbands_middle[1],_Digits));
     }

   if(TMA_signal=="sell")
     {

      if((last<candlesticks_info[1].close*(1-offset_BS))&&(last>TMAbands_middle[0]))
        {
         if(type_position=="LONG")
           {
            trade.PositionClose(PositionGetTicket(0));
            saved=false;
            if(OrdersTotal()!=0)
               trade.OrderDelete(OrderGetTicket(0));
            type_position="NO POSITION";
            check_saldo();
           }

         trade.Sell(NormalizeDouble(Lots*laverage,4),NULL,bid,0,0,"standard sell");

         Print("sell1: ask: "+DoubleToString(ask,_Digits)+"        bid:" + DoubleToString(bid,_Digits) +"       last: "+DoubleToString(last,_Digits)+"       tma signal: "+TMA_signal+"        type position: "+type_position);
         Print("sell2: tma_upper: "+DoubleToString(TMAbands_up[0],_Digits)+"        tma_mid"+DoubleToString(TMAbands_middle[0],_Digits)+"        tma_down: "+DoubleToString(TMAbands_down[0],_Digits));
         Print("buy3: spread: "+DoubleToString(spread,_Digits));
         if(OrdersTotal()!=0)
            trade.OrderDelete(OrderGetTicket(0));

         type_position="SHORT";
         TMA_signal="";
        }

     }

//
//   if(PositionsTotal()!=0 && OrdersTotal()!=0 && !saved)
//     {
//      if(type_position=="LONG")
//        {
//         if(last>TMAbands_middle[0])
//           {
//            double newStop=NormalizeDouble(TMAbands_down[0]+offset_SL,0);
//            ulong orderTicket=OrderGetTicket(0);
//            bool modified =trade.OrderModify(orderTicket,newStop,0,0,ORDER_TIME_GTC,0,NULL);
//            saved=true;
//            Print("Buy stop modified");
//            Print("Ask: "+DoubleToString(ask,_Digits)+"\nbid: "+DoubleToString(bid,_Digits)+"\nlast: "+DoubleToString(last,_Digits));
//
//           }
//        }
//      if(type_position=="SHORT")
//        {
//         if(last<TMAbands_middle[0])
//           {
//            double newStop=NormalizeDouble(TMAbands_up[0]-offset_SL,0);
//            ulong orderTicket=OrderGetTicket(0);
//            bool modified =trade.OrderModify(orderTicket,newStop,0,0,ORDER_TIME_GTC,0,NULL);
//            saved=true;
//            Print("Sell stop modified");
//            Print("Ask: "+DoubleToString(ask,_Digits)+"\nbid: "+DoubleToString(bid,_Digits)+"\nlast: "+DoubleToString(last,_Digits));
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
   comment+="\ndawka lots: "+DoubleToString(NormalizeDouble(Lots*laverage*last,5),2)+" usd";
   comment+="\nsaved: "+ DoubleToString(saved);
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
      saved=false;
      if(OrdersTotal()!=0)
        {
         trade.OrderDelete(OrderGetTicket(0));
        }
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void check_saldo()                                       // deklaracja funkcji
  {
   if(saldo>AccountInfoDouble(ACCOUNT_BALANCE))          // jeżeli poprzednie saldo jest większe od obecnenego to znaczy że nastąpiła strata
     {
      laverage=laverage_loss;                            // i zmniejsz lewar
     }
   else
      if(AccountInfoDouble(ACCOUNT_BALANCE)>saldo)   //  jeżeli obecne saldo jest większe od obecnenego to znaczy że nastąpił zysk
        {
         laverage=laverage_profit;
        }                    // i zwiększ lewar
   saldo=AccountInfoDouble(ACCOUNT_BALANCE);            // aktualizuj obecne saldo
  }


//+------------------------------------------------------------------+
