#include <Trade\Trade.mqh>

bool mainOrder(double TMAbands_downL,
               double TMAbands_upL,
               string type_positionL,
               CTrade &tradeL,
               double lotsL,
               double stoplossL,
               // new then crossBandOrder
               double orderOffset,
               double lastCandleClose)
{

    double lastLocal = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
    double askLocal = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double bidLocal = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    double sellStopPrice = NormalizeDouble(bidLocal * (1 - stoplossL), 0);
    double buyStopPrice = NormalizeDouble(askLocal * (1 + stoplossL), 0);
    double offsetForBuy = NormalizeDouble(lastCandleClose * (10000 + orderOffset) / 10000, 0);
    double offsetForSell = NormalizeDouble(lastCandleClose * (10000 - orderOffset) / 10000, 0);
    datetime time = iTime(_Symbol, PERIOD_M1, 0);

    // check params
    if (lastLocal < 10000 || askLocal < 10000 || bidLocal < 10000 ||
        lotsL <= 0 || lotsL > 0.5 ||
        stoplossL <= 0 || stoplossL > 0.05 ||
        TMAbands_downL < 10000 || TMAbands_downL > TMAbands_upL || TMAbands_upL < 10000 ||
        sellStopPrice < 10000 || buyStopPrice < 10000 ||
        // new
        offsetForBuy < 10000 || offsetForSell < 10000)
    {
        Print("----INPUT ERRORS on main order: ");
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
        // new
        Print("--offsetForBuy: ", offsetForBuy);
        Print("--offsetForSell: ", offsetForSell);
        return false;
    }
    bool isOrder = isOrderWithValue(tradeL, lotsL, type_positionL);
    Print("main isOrder: ", isOrder);
    Print("--type_positionL: ", type_positionL);
    Print("--lotsL: ", lotsL);
    Print("--lastLocal: ", lastLocal);
    Print("--TMAbands_downL: ", TMAbands_downL);
    Print("--TMAbands_upL: ", TMAbands_upL);
    Print("--offsetForBuy: ", offsetForBuy);
    Print("--offsetForSell: ", offsetForSell);

    // CLOSE POSITION ->it will be later in different block with parametrers of close pos
    if (isOrder)
    {
        if ((lastLocal < TMAbands_downL) && (type_positionL != "LONG"))
        {
            if (type_positionL == "SHORT")
            {
                tradeL.PositionClose(PositionGetTicket(0));
                if (OrdersTotal() != 0)
                    // if (removeOrderWithValue(tradeL, lotsL))
                    // {
                    //     Print("--ERROR main removeOrderWithValue");
                    // };
                    removeAllOrders(tradeL);
                type_position = "LONG";
            }
            return true;
        }

        if ((lastLocal > TMAbands_upL) && (type_positionL != "SHORT"))
        {
            if (type_positionL == "LONG")
            {
                tradeL.PositionClose(PositionGetTicket(0));
                if (OrdersTotal() != 0)
                    // if (removeOrderWithValue(tradeL, lotsL))
                    // {
                    //     Print("--ERROR removeOrderWithValue");
                    // };
                    removeAllOrders(tradeL);

                type_position = "SHORT";
            }
        }
    }

    // OPEN POSITION
    if (!isOrder)
    {

        // buy order
        if ((lastLocal > offsetForBuy) && (lastLocal < TMAbands_downL))
        {
            Print("--2: ");
            if (!tradeL.Buy(lotsL, NULL, askLocal, 0, 0, "buy main"))
                Print("--ERROR 33A buy main");

            if (!tradeL.SellStop(lotsL, sellStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop loss for band cross"))
                Print("--ERROR 34A on sell stop loss triggered");
            createObject(time, last, 141, clrDodgerBlue, "1");
            return true;
        }
        // sell order
        if ((lastLocal < offsetForSell) && (lastLocal > TMAbands_upL))
        {
            if (!tradeL.Sell(lotsL, NULL, bidLocal, 0, 0, "sell main"))
                Print("--ERROR 35B sell main");
            if (!tradeL.BuyStop(lotsL, buyStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "buy stop loss main"))
                Print("--ERROR 36B on buy stop loss triggered");
            createObject(time, last, 141, clrIndianRed, "1");
            return true;
        }
    }

    return true;
}