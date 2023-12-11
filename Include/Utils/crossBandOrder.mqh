#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>

bool crossOrder(double TMAbands_downL,
                double TMAbands_upL,
                double Last,
                double Ask,
                double Bid,
                double SellStopPriceCross,
                double BuyStopPriceCross,
                string &type_positionL,
                CTrade &tradeL,
                double lotsMainL,
                double lotsL,
                double stoplossCrossL,
                bool IsCrossOrder,
                bool IsMainOrder,
                bool TimeBlockadeCross,
                int &CrossAmount,
                string &SellComment[], string &BuyComment[])
{
    datetime time = iTime(_Symbol, PERIOD_M1, 0);

    // CLOSE POSITION
    if ((IsCrossOrder))
    {
        if ((Last < TMAbands_downL) && (type_positionL != "LONG"))
        {
            if (type_positionL == "SHORT")
            {
                // jest short to musimy kupic po tej cenie
                if (!tradeL.Buy(lotsL, NULL, Ask, 0, 0, SellComment[4]))
                    Print("--ERROR BUY CROSS 1: " + SellComment[4]);

                CrossAmount += 1;

                removeOrderWithComment(tradeL, BuyComment[2]);
            }
            return true;
        }

        if ((Last > TMAbands_upL) && (type_positionL != "SHORT"))
        {
            if (type_positionL == "LONG")
            {
                if (!tradeL.Sell(lotsL, NULL, Bid, Bid + 50, Bid - 60, BuyComment[4]))
                    Print("--ERROR SELL CROSS 2: " + BuyComment[4]);

                CrossAmount += 1;
                removeOrderWithComment(tradeL, SellComment[2]);
            }
            return true;
        }
    }

    // OPEN POSITION
    if (!IsCrossOrder && !TimeBlockadeCross)
    {
        //OPTIMIZE 
        // buy order when no mainOrder
        if ((Last < TMAbands_downL) && (type_positionL != "LONG") && (!IsMainOrder))
        {
            if (!tradeL.Buy(lotsL, NULL, Ask, 0, 0, BuyComment[0]))
                Print("--ERROR BUY CROSS 3" + BuyComment[0]);

            if (!tradeL.SellStop(lotsL, SellStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, SellComment[2]))
                Print("--ERROR SELLSTOP CROSS 4" + SellComment[2]);

            CrossAmount += 1;
            type_positionL = "LONG";
            createObject(time, Last, 140, clrDodgerBlue, "1");
            return true;
        }

        // buy additional piece
        if ((Last < TMAbands_downL) && (type_positionL == "LONG") && (IsMainOrder))
        {
            if (!tradeL.Buy(lotsL, NULL, Ask, 0, 0, BuyComment[1]))
                Print("--ERROR BUY CROSS 5: " + BuyComment[1]);

            if (!tradeL.SellStop(lotsL, SellStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, SellComment[2]))
                Print("--ERROR SELLSTOP CROSS 6: " + SellComment[2]);

            CrossAmount += 1;
            createObject(time, Last, 140, clrDodgerBlue, "1");
            return true;
        }

        // sell order when no mainOrder
        if ((Last > TMAbands_upL) && (type_positionL != "SHORT") && (!IsMainOrder))
        {
            if (!tradeL.Sell(lotsL, NULL, Bid, 0, 0, SellComment[0]))
                Print("--ERROR SELL CROSS 7: " + SellComment[0]);
            if (!tradeL.BuyStop(lotsL, BuyStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, BuyComment[2]))
                Print("--ERROR BUYSTOP 8: " + BuyComment[2]);
            CrossAmount += 1;
            type_positionL = "SHORT";
            createObject(time, Last, 140, clrIndianRed, "1");
            return true;
        }
        // sell additional piece
        if ((Last > TMAbands_upL) && (type_positionL == "SHORT") && (IsMainOrder))
        {
            if (!tradeL.Sell(lotsL, NULL, Bid, 0, 0, SellComment[1]))
                Print("--ERROR SELL CROSS 9: " + SellComment[1]);
            if (!tradeL.BuyStop(lotsL, BuyStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, BuyComment[2]))
                Print("--ERROR BUYSTOP 10: " + BuyComment[2]);
            CrossAmount += 1;
            type_positionL = "SHORT";
            createObject(time, Last, 140, clrIndianRed, "1");
            return true;
        }
    }

    return true;
}

// gdy sprzeda cross i main, potem po przekroczeniu tmaDown, zostaje mu tylko main i signal do kupna cross -> robi zakup i sprawdza czy jest pozycja po pozycji (a moze trzeba po orderze?)