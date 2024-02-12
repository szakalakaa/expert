void manuelBuy(GlobalStruct &G,
               InitialStruct &I,
               CTrade &tradeL,
               MqlRates &Candle[],
               string &SellComment[],
               string &BuyComment[])
{
    double stopLoss = getLowestFrom(Candle) - 100;

    if (stopLoss < 20000)
    {
        Print("stoploss for manuel error:   ", stopLoss);
        return;
    }

    if (!tradeL.SellStop(I.lotsManuel, stopLoss, _Symbol, 0, 0, ORDER_TIME_GTC, 0, sellComment[10]))
    {
        Print("--ERROR SELLSTOP BUY : " + sellComment[10]);
        return;
    }

    if (!tradeL.Buy(I.lotsManuel, NULL, 0, 0, 0, BuyComment[9]))
    {
        Print("--ERROR BUY MANUEL : ", BuyComment[9]);
    }
}

void manuelSell(GlobalStruct &G,
                InitialStruct &I,
                CTrade &tradeL,
                MqlRates &Candle[],
                string &SellComment[],
                string &BuyComment[])
{
    double stopLoss = getHighestFrom(Candle) + 100;

    if (stopLoss < 20000)
    {
        Print("stoploss for manuel error:   ", stopLoss);
        return;
    }

    if (!tradeL.Sell(I.lotsManuel, NULL, 0, 0, 0, SellComment[9]))
    {
        Print("--ERROR SELL MANUELL: " + SellComment[9]);
        return;
    }
    if (!tradeL.BuyStop(I.lotsManuel, stopLoss, _Symbol, 0, 0, ORDER_TIME_GTC, 0, buyComment[10]))
    {
        Print("--ERROR BUYSTOP MANUELL: " + buyComment[10]);
    }
}
