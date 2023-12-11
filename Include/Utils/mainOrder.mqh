#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>

bool mainOrder(double TMAbands_downL,
               double TMAbands_upL,
               double Last,
               double Ask,
               double Bid,
               double BuyStopPriceMain,
               double SellStopPriceMain,
               string type_positionL,
               CTrade &tradeL,
               double LotsMain,
               double stoplossL,
               double orderOffset,
               double lastCandleClose,
               bool IsMainOrder,
               bool IsStochOrder,
               bool &StopLossWasSchifted,
               int &MainAmount,
               bool TimeBlockadeMain,
               string &SellComment[],
               string &BuyComment[])
{

    double offsetForBuy = NormalizeDouble(lastCandleClose * (10000 + orderOffset) / 10000, 0);
    double offsetForSell = NormalizeDouble(lastCandleClose * (10000 - orderOffset) / 10000, 0);
    datetime time = iTime(_Symbol, PERIOD_M1, 0);

    // CLOSE POSITION ->it will be later in different block with parametrers of close pos
    if (IsMainOrder)
    {
        if ((Last < TMAbands_downL) && (Last > offsetForBuy) && (type_positionL != "LONG"))
        {
            if (type_positionL == "SHORT")
            {
                tradeL.PositionClose(PositionGetTicket(0));
                removeAllOrders(tradeL);
                // if (StopLossWasSchifted)
                // {
                //     removeOrderWithValue(tradeL, LotsMain);
                // }
                StopLossWasSchifted = false;
            }
            return true;
        }

        if ((Last > TMAbands_upL) && (Last < offsetForSell) && (type_positionL != "SHORT"))
        {
            if (type_positionL == "LONG")
            {
                tradeL.PositionClose(PositionGetTicket(0));
                removeAllOrders(tradeL);
                // if (StopLossWasSchifted)
                // {
                //     removeOrderWithValue(tradeL, LotsMain);
                // }
                StopLossWasSchifted = false;
            }
        }
    }

    // OPEN POSITION
    if (!IsMainOrder && !TimeBlockadeMain)
    {
        // buy order
        if ((Last > offsetForBuy) && (Last < TMAbands_downL))
        {
            if (!tradeL.Buy(LotsMain, NULL, Ask, 0, 0, BuyComment[5]))
                Print("--ERROR BUY MAIN 1: ", BuyComment[5]);

            if (!tradeL.SellStop(LotsMain, SellStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, sellComment[3]))
                Print("--ERROR SELLSTOP MAIN 2: " + sellComment[3]);
            MainAmount += 1;
            createObject(time, Last, 141, clrDodgerBlue, "1");
            return true;
        }
        // sell order
        if ((Last < offsetForSell) && (Last > TMAbands_upL))
        {
            if (!tradeL.Sell(LotsMain, NULL, Bid, 0, 0, SellComment[5]))
                Print("--ERROR SELL MAIN 3: " + SellComment[5]);
            if (!tradeL.BuyStop(LotsMain, BuyStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, buyComment[3]))
                Print("--ERROR BUYSTOP MAIN 4: " + buyComment[3]);
            MainAmount += 1;
            createObject(time, Last, 141, clrIndianRed, "1");
            return true;
        }
    }

    return true;
}