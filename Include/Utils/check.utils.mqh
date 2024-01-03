bool validVariables(GlobalStruct &G)
{

    if (
        G.lowerBand < 10000 || G.lowerBand > G.upperBand || G.upperBand < 10000 ||
        G.last < 10000 || G.ask < 10000 || G.bid < 10000 ||
        G.sellStopPriceCross < 10000 || G.buyStopPriceCross < 10000 ||
        G.sellStopPriceMain < 10000 || G.buyStopPriceMain < 10000)
    {
        Print("----INPUT ERRORS: ");
        Print("UpperBand: ", G.upperBand);
        Print("LowerBand: ", G.lowerBand);
        Print("Last: ", G.last);
        Print("Ask: ", G.ask);
        Print("Bid: ", G.bid);
        Print("SellStopPriceCross: ", G.sellStopPriceCross);
        Print("BuyStopPriceCross: ", G.buyStopPriceCross);
        Print("SellStopPriceMain: ", G.sellStopPriceMain);
        Print("BuyStopPriceMain: ", G.buyStopPriceMain);

        return false;
    }
    return true;
}