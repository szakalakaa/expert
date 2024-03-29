bool setTimerBlockadeForOrders(
    GlobalStruct &G,
    int MinutesToWait,
    int &RemainMinutes,
    string BuyComment,
    string SellComment,
    bool isOrder,
    double &memoryPrice)

{
    bool shouldBlockCross = false;
    double triggerAgainPercent = 0.009;

    HistorySelect((TimeCurrent() - MinutesToWait * 60), TimeCurrent());
    int total = HistoryDealsTotal();

    for (int i = total - 1; i >= 0; i--)
    {
        ulong ticket = HistoryDealGetTicket(i);
        string comment = HistoryDealGetString(ticket, DEAL_COMMENT);

        if (isOrder)
        {
            memoryPrice = 0;
        }

        if ((comment == BuyComment || comment == SellComment) && !isOrder)
        {
            memoryPrice = HistoryDealGetDouble(ticket, DEAL_PRICE);

            RemainMinutes = (int)(MinutesToWait - (TimeCurrent() - HistoryDealGetInteger(ticket, DEAL_TIME)) / 60);
            shouldBlockCross = true;
        }

        if (G.lowerBand > G.last && memoryPrice > (1 + triggerAgainPercent) * G.last)
        {

            shouldBlockCross = false;
        }

        if (G.upperBand < G.last && memoryPrice < (1 - triggerAgainPercent) * G.last && memoryPrice > 0)
        {

            shouldBlockCross = false;
        }
    }

    return shouldBlockCross;
}
