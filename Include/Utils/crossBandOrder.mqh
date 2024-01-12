#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>
#include <Utils\global.variables.mqh>

void crossOrder(GlobalStruct &G,
                InitialStruct &I,
                string &type_positionL,
                CTrade &tradeL,
                int &CrossAmount,
                string &SellComment[], string &BuyComment[])
{

    if (!I.applyCross)
    {
        return;
    }

    datetime time = iTime(_Symbol, PERIOD_M1, 0);

    // CLOSE POSITION
    if ((G.isCrossOrder))
    {
        if ((G.last < G.lowerBand) && (type_positionL != "LONG"))
        {
            if (type_positionL == "SHORT")
            {
                // jest short to musimy kupic po tej cenie
                if (!tradeL.Buy(I.lotsCross, NULL, G.ask, 0, 0, SellComment[4]))
                {
                    Print("--ERROR BUY CROSS 1: " + SellComment[4]);
                    G.stopExpert = true;
                }

                CrossAmount += 1;
                removeOrderWithValue(tradeL, I.lotsCross);
                Sleep(3000);
                removeAllOrders(tradeL);
            }
        }

        if ((G.last > G.upperBand) && (type_positionL != "SHORT"))
        {
            if (type_positionL == "LONG")
            {
                if (!tradeL.Sell(I.lotsCross, NULL, G.bid, 0, 0, BuyComment[4]))
                {
                    Print("--ERROR SELL CROSS 2: " + BuyComment[4]);
                    G.stopExpert = true;
                }

                CrossAmount += 1;
                removeOrderWithValue(tradeL, I.lotsCross);
                Sleep(3000);
                removeAllOrders(tradeL);
            }
        }
    }
    // OPEN POSITION
    if (!G.isCrossOrder && !G.timeBlockadeCross)
    {
        // OPTIMIZE
        //  buy order when no mainOrder
        if ((G.last < G.lowerBand) && (type_positionL != "LONG") && (!G.isMainOrder && !G.isMainAuxOrder))
        {
            if (!tradeL.Buy(I.lotsCross, NULL, G.ask, 0, 0, BuyComment[0]))
            {
                Print("--ERROR BUY CROSS 3" + BuyComment[0]);
                G.stopExpert = true;
            }

            if (!tradeL.SellStop(I.lotsCross, G.sellStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, SellComment[2]))
            {
                Print("--ERROR SELLSTOP CROSS 4" + SellComment[2]);
                G.stopExpert = true;
            }
            CrossAmount += 1;
            type_positionL = "LONG";
            Sleep(1000);
            return;
        }

        // buy additional piece
        if ((G.last < G.lowerBand) && (type_positionL == "LONG") && (G.isMainOrder && !G.isMainAuxOrder))
        {
            if (!tradeL.Buy(I.lotsCross, NULL, G.ask, 0, 0, BuyComment[1]))
            {
                Print("--ERROR BUY CROSS 5: " + BuyComment[1]);
                G.stopExpert = true;
            }

            if (!tradeL.SellStop(I.lotsCross, G.sellStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, SellComment[2]))
            {
                Print("--ERROR SELLSTOP CROSS 6: " + SellComment[2]);
                G.stopExpert = true;
            }
            CrossAmount += 1;      
            Sleep(1000);
            return;
        }

        // sell order when no mainOrder
        if ((G.last > G.upperBand) && (type_positionL != "SHORT") && (!G.isMainOrder && !G.isMainAuxOrder))
        {
            if (!tradeL.Sell(I.lotsCross, NULL, G.bid, 0, 0, SellComment[0]))
            {
                Print("--ERROR SELL CROSS 7: " + SellComment[0]);
                G.stopExpert = true;
            }
            if (!tradeL.BuyStop(I.lotsCross, G.buyStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, BuyComment[2]))
            {
                Print("--ERROR BUYSTOP 8: " + BuyComment[2]);
                G.stopExpert = true;
            }
            CrossAmount += 1;
            type_positionL = "SHORT";
            Sleep(1000);
            return;
        }
        // sell additional piece
        if ((G.last > G.upperBand) && (type_positionL == "SHORT") && (G.isMainOrder && !G.isMainAuxOrder))
        {
            if (!tradeL.Sell(I.lotsCross, NULL, G.bid, 0, 0, SellComment[1]))
            {
                Print("--ERROR SELL CROSS 9: " + SellComment[1]);
                G.stopExpert = true;
            }
            if (!tradeL.BuyStop(I.lotsCross, G.buyStopPriceCross, _Symbol, 0, 0, ORDER_TIME_GTC, 0, BuyComment[2]))
            {
                Print("--ERROR BUYSTOP 10: " + BuyComment[2]);
                G.stopExpert = true;
            }
            CrossAmount += 1;
            type_positionL = "SHORT";
            Sleep(1000);
            return;
        }
    }
}

// gdy sprzeda cross i main, potem po przekroczeniu tmaDown, zostaje mu tylko main i signal do kupna cross -> robi zakup i sprawdza czy jest pozycja po pozycji (a moze trzeba po orderze?)