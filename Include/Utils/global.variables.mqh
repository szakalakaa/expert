struct GlobalStruct
{

    int crossRemainMinutes;
    int mainRemainMinutes;
    int secondReverseRemainMinutes;

    double ask;
    double bid;
    double last;
    double upperBand;
    double lowerBand;

    double sellStopPriceCross;
    double buyStopPriceCross;    
    double sellStopPriceMain;
    double buyStopPriceMain;

    double lotsInPosition;
    double positionOpenPrice;
    double memorySLCross;
    double memorySLMain;
    double memorySLSecondReverse;
    double initialAccount;
    double currentAccount;
    double currentBalance;

    bool isMainOrder;
    bool isMainAuxOrder;
    bool isCrossOrder;
    bool isSecondReverseOrder;

    bool stopExpert;
    bool timeBlockadeCross;
    bool timeBlockadeMain;
    bool timeBlockadeSecondReverse;
};

struct InitialStruct
{

    bool applyCross;
    bool applyMain;
    bool applySecondReverse;

    double stoplossCross;
    double stoplossMain;

    double lotsCross;
    double lotsCrossAux;
    double lotsMain;
    double lotsMainAux;
    double lotsSecondReverse;

    int crossMinutesToWait;
    int mainMinutesToWait;

    int offset;
    int insureProcentOfAccount;


    bool testBool;
    int testInt;
    double testDouble;
    string testString;

};

struct StatsStruct
{
};