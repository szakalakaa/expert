struct GlobalStruct
{
    double ask;
    double bid;
    double last;
    double upperBand;
    double lowerBand;
    double sellStopPriceCross;
    double buyStopPriceCross;
    double sellStopPriceMain;
    double buyStopPriceMain;
    double sellStopPriceStoch;
    double buyStopPriceStoch;

    bool isCrossOrder;
    bool isMainOrder;
    bool isStochOrder;
};

struct InitialStruct
{
    double stoplossCross;
    double stoplossMain;
    double stoplossStoch;

    double lotsCross;
    double lotsMain;

    int crossMinutesToWait;
    int mainMinutesToWait;
};