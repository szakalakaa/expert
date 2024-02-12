bool isCandleCloseWickLong(MqlRates &Candle, string TypePosition, int WickLength)
{
    if (TypePosition == "SHORT")
    {
        if ((Candle.close - Candle.low) > WickLength)
        {
            return true;
        }
    }

    if (TypePosition == "LONG")
    {
        if ((Candle.high - Candle.close) > WickLength)
        {
            return true;
        }
    }

    return false;
}

double getHighestFrom( const MqlRates &Candle[])
{
    double highest = 0;

    for (int i = 1; i < ArraySize(Candle); i++)
    {
        highest = MathMax(highest, Candle[i].high);
    }

    return highest;
}

double getLowestFrom(const MqlRates &Candle[])
{
    double lowest = 1e10;

    for (int i = 1; i < ArraySize(Candle); i++)
    {
        if (Candle[i].low > 100)
        {
            lowest = MathMin(lowest, Candle[i].low);
        }
    }

    if (lowest > 1e9)
    {
        lowest = 0;
    }

    return lowest;
}