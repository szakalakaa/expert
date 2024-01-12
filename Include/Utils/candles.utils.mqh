bool isCandleCloseWickLong(MqlRates &Candle, string TypePosition)
{
    int wickLength = 230; // 0.5%
    if (TypePosition == "SHORT")
    {
        if ((Candle.close - Candle.low) > wickLength)
        {
            return true;
        }
    }

    if (TypePosition == "LONG")
    {
        if ((Candle.high - Candle.close) > wickLength)
        {
            return true;
        }
    }

    return false;
}