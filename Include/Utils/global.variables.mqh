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

    double lotsInPosition;
    double positionOpenPrice;
 
    bool isMainOrder;
    bool isMainAuxOrder;
    bool isCrossOrder;
    bool isSecondReverseOrder;

    bool stopExpert;

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
    int accountGuardianTriggered;


    bool testBool;
    int testInt;
    double testDouble;
    string testString;

};

struct StatsStruct
{
};