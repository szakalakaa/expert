void setTimerBlockadeForOrders(int MinutesToWait,
                               datetime CurrentTimer,
                               datetime &TimerStart,
                               bool IsMainOrder,
                               bool IsCrossOrder,
                               bool &TimeBlockadeCross,
                               string Type_position,
                               double Last,
                               double Ask,
                               double Bid,
                               double LowerBand,
                               double UpperBand,
                               int &RemainMinutes,
                               double IsBetweenBands)
{

    datetime time = iTime(_Symbol, PERIOD_M1, 0);

    // calculating remain time
    RemainMinutes = (int)((TimerStart - CurrentTimer) / 60);
    if (RemainMinutes < 0)
        RemainMinutes = 0;

    if ((!IsMainOrder) && (!IsCrossOrder) && (!TimeBlockadeCross) && (!IsBetweenBands))
    {
        if (Type_position == "LONG")
        {
            TimerStart = TimeCurrent() + 60 * MinutesToWait;
            TimeBlockadeCross = true;
            createObject(time, Last, 232, clrYellow, "2");
        }
        if ((Type_position == "SHORT"))
        {
            TimerStart = TimeCurrent() + 60 * MinutesToWait; // 60s * 60 min
            TimeBlockadeCross = true;
            createObject(time, Last, 232, clrYellow, "2");
        }
    }

    if ((CurrentTimer > TimerStart) && (TimeBlockadeCross))
    {
        TimeBlockadeCross = false;
        TimerStart = 0;
        createObject(time, Last, 231, clrOrange, "2");
    }
}