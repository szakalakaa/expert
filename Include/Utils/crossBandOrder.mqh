#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>

bool buyOnBand(double TMAbands_downL,
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

    // CLOSE POSITION ->it will be later in different block with parametrers of close pos
    if ((IsCrossOrder))
    {
        if ((Last < TMAbands_downL) && (type_positionL != "LONG"))
        {
            if (type_positionL == "SHORT")
            {
                // jest short to musimy kupic po tej cenie
                if (!tradeL.Buy(lotsL, NULL, Ask, 0, 0, "close only cross band short position "))
                    Print("--ERROR 8D close only cross band short position");

                CrossAmount += 1;

                // TODO: potrzebne?
                if (OrdersTotal() != 0)
                    if (removeOrderWithValue(tradeL, lotsL))
                    {
                        Print("--ERROR removeOrderWithValue");
                    };
            }
            return true;
        }

        if ((Last > TMAbands_upL) && (type_positionL != "SHORT"))
        {
            if (type_positionL == "LONG")
            {
                if (!tradeL.Sell(lotsL, NULL, Bid, Bid + 50, Bid - 60, "close only cross band long position"))
                    Print("--ERROR 8D close only cross band long position");

                CrossAmount += 1;
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
    if (!IsCrossOrder && !TimeBlockadeCross)
    {
        // buy order when no mainOrder
        if ((Last < TMAbands_downL) && (type_positionL != "LONG") && (!IsMainOrder))
        {
            if (!tradeL.Buy(lotsL, NULL, Ask, 0, 0, BuyComment[0]))
                Print("--ERROR 6A buy on band cross");

            if (!tradeL.SellStop(lotsL, SellStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, SellComment[2]))
                Print("--ERROR 7A on sell stop loss triggered");

            CrossAmount += 1;
            type_positionL = "LONG";
            createObject(time, Last, 140, clrDodgerBlue, "1");
            return true;
        }

        // buy additional piece
        if ((Last < TMAbands_downL) && (type_positionL == "LONG") && (IsMainOrder))
        {
            if (!tradeL.Buy(lotsL, NULL, Ask, 0, 0, BuyComment[1]))
                Print("--ERROR 75A buy on band cross add");

            if (!tradeL.SellStop(lotsL, SellStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, SellComment[2]))
                Print("--ERROR 734A on sell stop loss triggered add");

            CrossAmount += 1;
            createObject(time, Last, 140, clrDodgerBlue, "1");
            return true;
        }

        // sell order when no mainOrder
        if ((Last > TMAbands_upL) && (type_positionL != "SHORT") && (!IsMainOrder))
        {
            if (!tradeL.Sell(lotsL, NULL, Bid, 0, 0, SellComment[0]))
                Print("--ERROR 6B sell on band cross");
            if (!tradeL.BuyStop(lotsL, BuyStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, BuyComment[2]))
                Print("--ERROR 7B on buy stop loss triggered");
            CrossAmount += 1;
            type_positionL = "SHORT";
            createObject(time, Last, 140, clrIndianRed, "1");
            return true;
        }
        // sell additional piece
        if ((Last > TMAbands_upL) && (type_positionL == "SHORT") && (IsMainOrder))
        {
            if (!tradeL.Sell(lotsL, NULL, Bid, 0, 0, SellComment[1]))
                Print("--ERROR 6B sell on band cross");
            if (!tradeL.BuyStop(lotsL, BuyStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, BuyComment[2]))
                Print("--ERROR 7B on buy stop loss triggered");
            CrossAmount += 1;
            type_positionL = "SHORT";
            createObject(time, Last, 140, clrIndianRed, "1");
            return true;
        }
    }

    return true;
}

// gdy sprzeda cross i main, potem po przekroczeniu tmaDown, zostaje mu tylko main i signal do kupna cross -> robi zakup i sprawdza czy jest pozycja po pozycji (a moze trzeba po orderze?)