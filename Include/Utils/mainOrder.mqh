#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>

bool mainOrder(double TMAbands_downL,
               double TMAbands_upL,
               double lastLocal,
               double askLocal,
               double bidLocal,
               double BuyStopPriceMain,
               double SellStopPriceMain,
               string type_positionL,
               CTrade &tradeL,
               double lotsL,
               double stoplossL,
               // new then crossBandOrder
               double orderOffset,
               double lastCandleClose,
               double IsMainOrder)
{

    double offsetForBuy = NormalizeDouble(lastCandleClose * (10000 + orderOffset) / 10000, 0);
    double offsetForSell = NormalizeDouble(lastCandleClose * (10000 - orderOffset) / 10000, 0);
    datetime time = iTime(_Symbol, PERIOD_M1, 0);

    // CLOSE POSITION ->it will be later in different block with parametrers of close pos
    if (IsMainOrder)
    {
        if ((lastLocal < TMAbands_downL) && (lastLocal > offsetForBuy) && (type_positionL != "LONG"))
        {
            if (type_positionL == "SHORT")
            {
                if (!tradeL.Buy(lotsL, NULL, askLocal, 0, 0, "close only main short position "))
                    Print("--ERROR 9D close only main short position");
                if (OrdersTotal() != 0)
                {
                    removeAllOrders(tradeL);
                }
                // if (removeOrderWithValue(tradeL, lotsL))
                // {
                //     Print("--ERROR removeOrderWithValue");
                // };

                type_positionL = "LONG";
            }
            return true;
        }

        if ((lastLocal > TMAbands_upL) && (lastLocal < offsetForSell) && (type_positionL != "SHORT"))
        {
            if (type_positionL == "LONG")
            {
                if (!tradeL.Sell(lotsL, NULL, bidLocal, 0, 0, "close only main long position"))
                    Print("--ERROR 8D close only main long position");
                if (OrdersTotal() != 0)
                {
                    removeAllOrders(tradeL);
                }
                // if (removeOrderWithValue(tradeL, lotsL))
                // {
                //     Print("--ERROR removeOrderWithValue");
                // };
                type_positionL = "SHORT";
            }
        }
    }

    // OPEN POSITION
    if (!IsMainOrder)
    {

        // buy order
        if ((lastLocal > offsetForBuy) && (lastLocal < TMAbands_downL))
        {
            Print("--BUY MAIN: ");
            if (!tradeL.Buy(lotsL, NULL, askLocal, 0, 0, "buy main"))
                Print("--ERROR 33A buy main");

            if (!tradeL.SellStop(lotsL, SellStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop loss for band cross"))
                Print("--ERROR 34A on sell stop loss triggered");
            createObject(time, lastLocal, 141, clrDodgerBlue, "1");
            return true;
        }
        // sell order
        if ((lastLocal < offsetForSell) && (lastLocal > TMAbands_upL))
        {
            Print("--SELL MAIN: ");
            if (!tradeL.Sell(lotsL, NULL, bidLocal, 0, 0, "sell main"))
                Print("--ERROR 35B sell main");
            if (!tradeL.BuyStop(lotsL, BuyStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "buy stop loss main"))
                Print("--ERROR 36B on buy stop loss triggered");
            createObject(time, lastLocal, 141, clrIndianRed, "1");
            return true;
        }
    }

    return true;
}