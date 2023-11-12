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
               double orderOffset,
               double lastCandleClose,
               bool IsMainOrder,
               bool IsStochOrder,
               bool &StopLossWasSchifted,
               int &MainAmount)
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
                tradeL.PositionClose(PositionGetTicket(0));
                removeAllOrders(tradeL);
                removeOrderWithValue(tradeL,lotsL);
                StopLossWasSchifted = false;
            }
            return true;
        }

        if ((lastLocal > TMAbands_upL) && (lastLocal < offsetForSell) && (type_positionL != "SHORT"))
        {
            if (type_positionL == "LONG")
            {
                tradeL.PositionClose(PositionGetTicket(0));
                removeAllOrders(tradeL);
                removeOrderWithValue(tradeL,lotsL);
                StopLossWasSchifted = false;
            }
        }
    }

    // OPEN POSITION
    if (!IsMainOrder)
    {
        // buy order
        if ((lastLocal > offsetForBuy) && (lastLocal < TMAbands_downL))
        {
            // removeAllOrders(tradeL);
            if (!tradeL.Buy(lotsL, NULL, askLocal, 0, 0, "buy main"))
                Print("--ERROR 33A buy main");

            if (!tradeL.SellStop(lotsL, SellStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop loss main"))
                Print("--ERROR 34A on sell stop loss triggered");
            MainAmount += 1;
            createObject(time, lastLocal, 141, clrDodgerBlue, "1");
            return true;
        }
        // sell order
        if ((lastLocal < offsetForSell) && (lastLocal > TMAbands_upL))
        {
            // removeAllOrders(tradeL);
            if (!tradeL.Sell(lotsL, NULL, bidLocal, 0, 0, "sell main"))
                Print("--ERROR 35B sell main");
            if (!tradeL.BuyStop(lotsL, BuyStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "buy stop loss main"))
                Print("--ERROR 36B on buy stop loss triggered");
            MainAmount += 1;
            createObject(time, lastLocal, 141, clrIndianRed, "1");
            return true;
        }
    }

    return true;
}