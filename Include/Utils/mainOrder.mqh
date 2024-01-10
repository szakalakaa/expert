#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>

void mainOrder(GlobalStruct &G,
               InitialStruct &I,
               string type_positionL,
               CTrade &tradeL,
               double lastCandleClose,
               int &MainAmount,
               bool TimeBlockadeMain,
               string &SellComment[],
               string &BuyComment[])
{

    double offsetForBuy = NormalizeDouble(lastCandleClose * (10000 + I.offset) / 10000, 0);
    double offsetForSell = NormalizeDouble(lastCandleClose * (10000 - I.offset) / 10000, 0);
    datetime time = iTime(_Symbol, PERIOD_M1, 0);

    // CLOSE POSITION ->it will be later in different block with parametrers of close pos
    if (G.isMainOrder)
    {
        if ((G.last < G.lowerBand) && (G.last > offsetForBuy) && (type_positionL != "LONG"))
        {
            if (type_positionL == "SHORT")
            {
                tradeL.PositionClose(PositionGetTicket(0));
                removeAllOrders(tradeL);
            }
        }

        if ((G.last > G.upperBand) && (G.last < offsetForSell) && (type_positionL != "SHORT"))
        {
            if (type_positionL == "LONG")
            {
                tradeL.PositionClose(PositionGetTicket(0));
                removeAllOrders(tradeL);
            }
        }
    }
    // OPEN POSITION
    if (!G.isMainOrder && !TimeBlockadeMain)
    {
        // buy order
        if ((G.last > offsetForBuy) && (G.last < G.lowerBand))
        {
            if (!tradeL.Buy((I.lotsMain + I.lotsMainAux), NULL, G.ask, 0, 0, BuyComment[5]))
            {
                Print("--ERROR BUY MAIN 1: ", BuyComment[5]);
                G.stopExpert = true;
            }
            if (!tradeL.SellStop(I.lotsMain, G.sellStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, sellComment[3]))
            {
                Print("--ERROR SELLSTOP MAIN 2: " + sellComment[3]);
                G.stopExpert = true;
            }
            if (!tradeL.SellStop(I.lotsMainAux, G.sellStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, sellComment[6]))
            {
                Print("--ERROR SELLSTOP AUX MAIN 2: " + sellComment[6]);
                G.stopExpert = true;
            }

            MainAmount += 1;
            createObject(time, G.last, 141, clrDodgerBlue, "1");
        }
        // sell order
        if ((G.last < offsetForSell) && (G.last > G.upperBand))
        {
            if (!tradeL.Sell((I.lotsMain + I.lotsMainAux), NULL, G.bid, 0, 0, SellComment[5]))
            {
                Print("--ERROR SELL MAIN 3: " + SellComment[5]);
                G.stopExpert = true;
            }
            if (!tradeL.BuyStop(I.lotsMain, G.buyStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, buyComment[3]))
            {
                Print("--ERROR BUYSTOP MAIN 4: " + buyComment[3]);
                G.stopExpert = true;
            }
            if (!tradeL.BuyStop(I.lotsMainAux, G.buyStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, buyComment[6]))
            {
                Print("--ERROR BUYSTOP MAIN 4: " + buyComment[6]);
                G.stopExpert = true;
            }
            MainAmount += 1;
            createObject(time, G.last, 141, clrIndianRed, "1");
        }
    }
}