#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>

bool buyOnBand(double TMAbands_downL,
               double TMAbands_upL,
               double lastLocal,
               double askLocal,
               double bidLocal,
               double SellStopPriceCross,
               double BuyStopPriceCross,
               string &type_positionL,
               CTrade &tradeL,
               double lotsMainL,
               double lotsL,
               double stoplossCrossL,
               bool crossBlockadeFlagL,
               bool IsCrossOrder,
               bool IsMainOrder)
{

    datetime time = iTime(_Symbol, PERIOD_M1, 0);

    // CLOSE POSITION ->it will be later in different block with parametrers of close pos
    if (IsCrossOrder)
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
                if (!tradeL.Sell(lotsL, NULL, bidLocal, bidLocal + 50, bidLocal - 60, "close only cross band long position"))
                    Print("--ERROR 8D close only cross band long position");
                if (OrdersTotal() != 0)
                    if (removeOrderWithValue(tradeL, lotsL))
                    {
                        Print("--ERROR removeOrderWithValue");
                    };
            }
            return true;
        }
    }

    // OPEN POSITION
    if (!IsCrossOrder && !crossBlockadeFlagL && !IsMainOrder)
    {
        // buy order
        if ((lastLocal < TMAbands_downL) && (type_positionL != "LONG"))
        {
            if (!tradeL.Buy(lotsL, NULL, askLocal, 0, 0, "buy on band cross"))
                Print("--ERROR 6A buy on band cross");

            if (!tradeL.SellStop(lotsL, SellStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop loss for band cross"))
                Print("--ERROR 7A on sell stop loss triggered");

            type_positionL = "LONG";
            createObject(time, lastLocal, 140, clrDodgerBlue, "1");
            crossBlockadeFlagL = true;
            return true;
        }
        // sell
        if ((lastLocal > TMAbands_upL) && (type_positionL != "SHORT"))
        {
            if (!tradeL.Sell(lotsL, NULL, bidLocal, 0, 0, "sell on band cross"))
                Print("--ERROR 6B sell on band cross");
            if (!tradeL.BuyStop(lotsL, BuyStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "buy stop loss on band cross"))
                Print("--ERROR 7B on buy stop loss triggered");

            type_positionL = "SHORT";
            createObject(time, lastLocal, 140, clrIndianRed, "1");
            crossBlockadeFlagL = true;
            return true;
        }
    }

    return true;
}

// gdy sprzeda cross i main, potem po przekroczeniu tmaDown, zostaje mu tylko main i signal do kupna cross -> robi zakup i sprawdza czy jest pozycja po pozycji (a moze trzeba po orderze?)