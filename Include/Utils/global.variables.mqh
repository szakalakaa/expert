struct GlobalStruct
{
    int crossRemainMinutes;
    int mainRemainMinutes;

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
    double lotsInPosition;
    double positionOpenPrice;

    double memorySLCross;
    double memorySLMain;
    double initialAccount;
    double currentAccount;
    double currentBalance;

    bool isMainOrder;
    bool isMainAuxOrder;
    bool isCrossOrder;
    bool stopExpert;
    bool timeBlockadeCross;
    bool timeBlockadeMain;
};

struct InitialStruct
{

    bool applyCross;
    bool applyMain;

    double stoplossCross;
    double stoplossMain;

    double lotsCross;
    double lotsCrossAux;
    double lotsMain;
    double lotsMainAux;

    int crossMinutesToWait;
    int mainMinutesToWait;

    int offset;
    int insureProcentOfAccount;
};

struct StatsStruct
{
};