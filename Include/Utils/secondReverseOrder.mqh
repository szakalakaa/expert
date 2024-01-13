#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>
#include <Utils\candles.utils.mqh>

// uzywamy stoplossa takiego jak w main order
void secondReverseOrder(GlobalStruct &G,
                        InitialStruct &I,
                        string type_positionL,
                        CTrade &tradeL,
                        MqlRates &Candle[],
                        int &MainAmount,
                        string &SellComment[],
                        string &BuyComment[])
{

    if (!I.applySecondReverse) //&& !G.timeBlockadeSecondReverse)
    {
        return;
    }

    bool isFirstWickLong = isCandleCloseWickLong(Candle[1], type_positionL, 230);
    bool isSecondWickLong = isCandleCloseWickLong(Candle[2], type_positionL, 230); // czy jest wiekszy niz 230?

    datetime time = iTime(_Symbol, PERIOD_M1, 0);
    if (G.isMainOrder && !G.isSecondReverseOrder && !isSecondWickLong && !isFirstWickLong)
    {
        int firstBodyMinHeight = 50;
        bool isFirstBodyLong = MathAbs(NormalizeDouble((Candle[1].open - Candle[1].close), 0)) > firstBodyMinHeight;

        // OPEN LONG POSITION
        if ((G.last < G.lowerBand) &&
            (Candle[1].close < G.lowerBand) &&
            (Candle[2].close < G.lowerBand) &&
            (Candle[2].close < Candle[1].close) &&
            (G.last > Candle[1].close) &&
            (isFirstBodyLong) &&
            (type_positionL == "LONG"))
        {
            double sl = Candle[2].low - 200;

            if (!tradeL.Buy(I.lotsSecondReverse, NULL, G.ask, 0, 0, BuyComment[7]))
            {
                Print("--ERROR BUY SECOND REVERSE: ", BuyComment[7]);
                G.stopExpert = true;
            }

            if (!tradeL.SellStop(I.lotsSecondReverse, sl, _Symbol, 0, 0, ORDER_TIME_GTC, 0, sellComment[8]))
            {
                Print("--ERROR SELLSTOP SECOND REVERSE: " + sellComment[8]);
                G.stopExpert = true;
            }
            createObject(time, G.last, 141, clrChartreuse, "1");
            Sleep(1000);
            return;
        }

        // OPEN SHORT POSITION
        if ((G.last > G.upperBand) &&
            (Candle[1].close > G.upperBand) &&
            (Candle[2].close > G.upperBand) &&
            (Candle[2].close > Candle[1].close) &&
            (G.last < Candle[1].close) &&
            (isFirstBodyLong) &&
            (type_positionL == "SHORT"))
        {

            double sl = Candle[2].high + 200;

            if (!tradeL.Sell(I.lotsSecondReverse, NULL, G.bid, 0, 0, SellComment[7]))
            {
                Print("--ERROR SELL SECOND REVERSE: " + SellComment[7]);
                G.stopExpert = true;
            }
            if (!tradeL.BuyStop(I.lotsSecondReverse, G.buyStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, buyComment[8]))
            {
                Print("--ERROR BUYSTOP SECOND REVERSE: " + buyComment[8]);
                G.stopExpert = true;
            }
            createObject(time, G.last, 141, clrAqua, "1");
            Sleep(1000);
            return;
        }
    }
}