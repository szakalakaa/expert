void setTimerBlockadeForOrders(int MinutesToWait,
                               datetime &CurrentTimer,
                               datetime &TimerStart,
                               bool IsMainOrder,
                               bool &TimeBlockadeCross,
                               string Type_position,
                               double Ask,
                               double Bid,
                               double LowerBand,
                               double UpperBand,
                               int &RemainMinutes)
{

    CurrentTimer = TimeCurrent();
    
    //calculating remain time
    RemainMinutes = (int)((TimerStart - CurrentTimer) / 60);
    if (RemainMinutes < 0)
        RemainMinutes = 0;

    if ((!IsMainOrder) && (!TimeBlockadeCross))
    {
        if (Type_position == "LONG")
        {
            TimerStart = TimeCurrent() + 60 * MinutesToWait;
            TimeBlockadeCross = true;
        }
        if ((Type_position == "SHORT"))
        {
            TimerStart = TimeCurrent() + 60 * MinutesToWait; // 60s * 60 min
            TimeBlockadeCross = true;
        }
    }

    if ((CurrentTimer > TimerStart) && (TimeBlockadeCross))
    {
        TimeBlockadeCross = false;
        TimerStart = 0;
    }
}