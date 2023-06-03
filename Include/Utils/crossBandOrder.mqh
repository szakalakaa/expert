#include <Trade\Trade.mqh>

bool buyOnBand(double TMAbands_downL,
               double TMAbands_upL,
               string &type_positionL,
               CTrade &tradeL,
               double lotsL,
               double stoplossL)
{

    double lastLocal = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
    double askLocal = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double bidLocal = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    double sellStopPrice = NormalizeDouble(bidLocal * (1 - stoplossL), 0);
    double buyStopPrice = NormalizeDouble(askLocal * (1 + stoplossL), 0);
    datetime time = iTime(_Symbol, PERIOD_M1, 0);

    // check params
    if (lastLocal < 10000 || askLocal < 10000 || bidLocal < 10000 ||
        lotsL <= 0 || lotsL > 0.5 ||
        stoplossL <= 0 || stoplossL > 0.05 ||
        TMAbands_downL < 10000 || TMAbands_downL > TMAbands_upL || TMAbands_upL < 10000 ||
        sellStopPrice < 10000 || buyStopPrice < 10000)
    {
        Print("----INPUT ERRORS on cross band order: ");
        Print("--lastLocal: ", lastLocal);
        Print("--askLocal: ", askLocal);
        Print("--bidLocal: ", bidLocal);
        Print("--sellStopPrice: ", sellStopPrice);
        Print("--buyStopPrice: ", buyStopPrice);
        Print("--TMAbands_downL: ", TMAbands_downL);
        Print("--TMAbands_upL: ", TMAbands_upL);
        Print("--type_positionL: ", type_positionL);
        Print("--lotsL: ", lotsL);
        Print("--stoplossL: ", stoplossL);
        return false;
    }
    bool isOrder = isOrderWithValue(tradeL, lotsL, type_positionL);
    Print("cross isOrder: ", isOrder);

    // CLOSE POSITION ->it will be later in different block with parametrers of close pos
    if (isOrder)
    {
        if ((lastLocal < TMAbands_downL) && (type_positionL != "LONG"))
        {
            if (type_positionL == "SHORT")
            {
                // jest short to musimy kupic po tej cenie
                if (!tradeL.Buy(lotsL, NULL, askLocal, 0, 0, "close only cross band short position "))
                    Print("--ERROR 8D close only cross band short position");
                if (OrdersTotal() != 0)
                    if (removeOrderWithValue(tradeL, lotsL))
                    {
                        Print("--ERROR removeOrderWithValue");
                    };
            }
            return true;
        }

        if ((lastLocal > TMAbands_upL) && (type_positionL != "SHORT"))
        {
            if (type_positionL == "LONG")
            {
                if (!tradeL.Sell(lotsL, NULL, bidLocal, 0, 0, "close only cross band long position"))
                    Print("--ERROR 8D close only cross band long position");
                if (OrdersTotal() != 0)
                    if (removeOrderWithValue(tradeL, lotsL))
                    {
                        Print("--ERROR removeOrderWithValue");
                    };
            }
        }
    }

    // OPEN POSITION
    if (!isOrder)
    {
        // buy order
        if ((lastLocal < TMAbands_downL) && (type_positionL != "LONG"))
        {
            if (!tradeL.Buy(lotsL, NULL, askLocal, 0, 0, "buy on band cross"))
                Print("--ERROR 6A buy on band cross");

            if (!tradeL.SellStop(lotsL, sellStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop loss for band cross"))
                Print("--ERROR 7A on sell stop loss triggered");

            type_positionL = "LONG";
            createObject(time, last, 140, clrDodgerBlue, "1");

            return true;
        }
        // sell
        if ((lastLocal > TMAbands_upL) && (type_positionL != "SHORT"))
        {
            if (!tradeL.Sell(lotsL, NULL, bidLocal, 0, 0, "sell on band cross"))
                Print("--ERROR 6B sell on band cross");
            if (!tradeL.BuyStop(lotsL, buyStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "buy stop loss on band cross"))
                Print("--ERROR 7B on buy stop loss triggered");

            type_positionL = "SHORT";
            createObject(time, last, 140, clrIndianRed, "1");
            return true;
        }
    }

    return true;
}