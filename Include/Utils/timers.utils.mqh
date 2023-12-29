bool setTimerBlockadeForOrders(int MinutesToWait,
                               int &RemainMinutes,
                               string BuyComment,
                               string SellComment,
                               bool isOrder,
                               double &memoryPrice,
                               double LowerBand,
                               double UpperBand,
                               double Last)

{
    bool shouldBlockCross = false;
    double triggerAgainPercent = 0.01;

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

        if (LowerBand > Last && memoryPrice > (1 + triggerAgainPercent) * Last)
        {
            shouldBlockCross = false;
            // memoryPrice = 0;
        }

        if (UpperBand < Last && memoryPrice < (1 - triggerAgainPercent) * Last && memoryPrice > 0)
        {
            shouldBlockCross = false;
            // memoryPrice = 0;
        }
    }

    return shouldBlockCross;
}
