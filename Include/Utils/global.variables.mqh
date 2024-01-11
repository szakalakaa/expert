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
    double lotsInPosition;
    double positionOpenPrice;

    bool isMainOrder;
    bool isMainAuxOrder;

    bool isCrossOrder;

    bool stopExpert;
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