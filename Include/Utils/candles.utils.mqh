bool isCandleCloseWickLong(MqlRates &Candle, string TypePosition,int WickLength)
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