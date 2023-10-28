void setTimerBlockadeForOrders(int MinutesToWait,
                               datetime &CurrentTimer,
                               datetime &TimerStart,
                               bool IsMainOrder,
                               bool &BlockCross,
                               string Type_position,
                               double Ask,
                               double Bid,
                               double LowerBand,
                               double UpperBand)
{

    CurrentTimer = TimeCurrent();

    if ((!IsMainOrder) && (!BlockCross))
    {
        if (Type_position == "LONG" && (Ask < (LowerBand - 100)))
        {          
            TimerStart = TimeCurrent() + 60 * MinutesToWait;
            BlockCross = true;
        }
        if ((Type_position == "SHORT") && (Bid > (UpperBand + 100)))
        {           
            TimerStart = TimeCurrent() + 60 * MinutesToWait; // 60s * 60 min
            BlockCross = true;
        }
    }
    if ((CurrentTimer > TimerStart) && (BlockCross))
    {
        BlockCross = false;
        TimerStart = 0;
    }
}