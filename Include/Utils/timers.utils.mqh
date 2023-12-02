bool setTimerBlockadeForOrders(int MinutesToWait,
                               int &RemainMinutes,
                               string BuyComment,
                               string SellComment)

{
    bool shouldBlockCross = false;

    HistorySelect((TimeCurrent() - MinutesToWait * 60), TimeCurrent());
    int total = HistoryDealsTotal();

    for (int i = total - 1; i >= 0; i--)
    {
        ulong ticket = HistoryDealGetTicket(i);
        string comment = HistoryDealGetString(ticket, DEAL_COMMENT);
        if (comment == BuyComment || comment == SellComment)
        {
            RemainMinutes = (int)(MinutesToWait - (TimeCurrent() - HistoryDealGetInteger(ticket, DEAL_TIME)) / 60);
            shouldBlockCross = true;
        }
    }

    return shouldBlockCross;
}
