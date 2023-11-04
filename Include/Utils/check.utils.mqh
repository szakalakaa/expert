bool validVariables(double UpperBand,
                    double LowerBand,
                    double Last,
                    double Ask,
                    double Bid,
                    double SellStopPriceCross,
                    double BuyStopPriceCross,
                    double SellStopPriceMain,
                    double BuyStopPriceMain

)
{

    if (
        LowerBand < 10000 || LowerBand > UpperBand || UpperBand < 10000 ||
        Last < 10000 || Ask < 10000 || Bid < 10000 ||
        SellStopPriceCross < 10000 || BuyStopPriceCross < 10000 ||
        SellStopPriceMain < 10000 || BuyStopPriceMain < 10000)
    {
        Print("----INPUT ERRORS: ");
        Print("UpperBand: ", UpperBand);
        Print("LowerBand: ", LowerBand);
        Print("Last: ", Last);
        Print("Ask: ", Ask);
        Print("Bid: ", Bid);
        Print("SellStopPriceCross: ", SellStopPriceCross);
        Print("BuyStopPriceCross: ", BuyStopPriceCross);
        Print("SellStopPriceMain: ", SellStopPriceMain);
        Print("BuyStopPriceMain: ", BuyStopPriceMain);

        return false;
    }
    return true;
}