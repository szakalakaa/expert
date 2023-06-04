#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\crossBandOrder.mqh>
#include <Utils\mainOrder.mqh>
#include <Utils\utils.mqh>
#include <Utils\graphicPanel.mqh>

CTrade trade;
CGraphicalPanel panel;

input group "====MAGIC====";
static input long inpMagic = 44444; // magic number
input group "====GENERAL====";
input double stoploss = 0.001;
input int offset = 0; // offset buy sell  10000 = 1%
input ENUM_TIMEFRAMES processPeriod = PERIOD_M1;
input group "====TMA====";
input int atr_period = 260;
input double atr_multiplier = 2;
int inpLevar = 4;
input bool addSecondStopLoss = true;
string type_position = "NO POSITION";

// indicators
int tma_handle, stoch_handle;
enum enPrices
{
    pr_weighted
};
MqlTick tick;
// normalize lots?
double Lots = 0.012;
double lotsCrossBand = 0.01;
double lotsMain = 0.02;
double lotsInPosition = 0;
double positionOpenPrice;
double ask, last, bid;
bool addSecondStopLossFlag = false;

double TMAbands_down[], TMAbands_up[], TMAbands_middle[];

///////STOCH
// input group "====STOCH====";
double stochUpper = 60; // stochUpper
int KPeriod = 20;
int DPeriod = 5;
double stochLower = 100 - stochUpper; // deklaracja zmiennej przechowującej wartość dolnej wartosci dla STOCH, domyślnie 20
double K_period[];                    // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
double D_period[];                    // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
string stochSignal = "";
int cntBuy, cntSell;
long openPosMagic;

int OnInit()
{
    Print("Robot started!");

    // Checking inputs
    if (!checkInputs(stoploss, atr_period, atr_multiplier, stochUpper, KPeriod, DPeriod))
    {
        return INIT_PARAMETERS_INCORRECT;
    };

    // Panel initialisation
    panel.Oninit();

    // Indicator initialisation
    tma_handle = iCustom(Symbol(), 0, "tma_indikator.ex5", 12, pr_weighted, atr_period, atr_multiplier, 4, 0);

    if (tma_handle == INVALID_HANDLE)
    {
        Alert("Failed to create tma indicator");
        return INIT_FAILED;
    }

    stoch_handle = iStochastic(_Symbol, _Period, KPeriod, DPeriod, 3, MODE_SMA, STO_LOWHIGH);

    if (stoch_handle == INVALID_HANDLE)
    {
        Alert("Failed to create stoch indicator");
        return INIT_FAILED;
    }

    // Setting arrays as series
    ArraySetAsSeries(TMAbands_down, true);
    ArraySetAsSeries(TMAbands_up, true);
    ArraySetAsSeries(K_period, true);
    ArraySetAsSeries(D_period, true);

    // Setting magic number
    trade.SetExpertMagicNumber(inpMagic);
    return (INIT_SUCCEEDED);
}

void OnTick()
{
    // Check if process
    if (!shouldProcess(processPeriod))
        return;

    // Get current tick
    if (!SymbolInfoTick(_Symbol, tick))
    {
        Print("Failed to get tick");
        return;
    }

    // get indicator values
    int values = CopyBuffer(tma_handle, 3, 0, 2, TMAbands_down) +
                 CopyBuffer(tma_handle, 2, 0, 2, TMAbands_up) +
                 CopyBuffer(tma_handle, 0, 0, 2, TMAbands_middle) +
                 CopyBuffer(stoch_handle, 0, 0, 3, K_period) +
                 CopyBuffer(stoch_handle, 0, 0, 3, D_period);

    if (values != 12)
    {
        Alert("Failed to get indicator values! ", values);
        return;
    }

    // Get position data
    // TODO: get orderd data
    // TODO: make a function
    if (PositionsTotal())
    {
        PositionGetSymbol(0);
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            type_position = "LONG";
        }
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
            type_position = "SHORT";
        }
        lotsInPosition = NormalizeDouble(PositionGetDouble(POSITION_VOLUME), 4);
        positionOpenPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), 0);
    }
    else
    {
        type_position = "NO POSITION";
        lotsInPosition = 0;
        positionOpenPrice = 0;
    }

    // Get price data
    ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
    if ((!ask) || (!bid) || (!last))
    {
        Print("failed to get last: ", last);
        Print("failed to get ask: ", ask);
        Print("failed to get bid: ", bid);
        return;
    }
    double upperBand = NormalizeDouble(TMAbands_up[0], 0);
    double lowerBand = NormalizeDouble(TMAbands_down[0], 0);
    double middleBand = NormalizeDouble(TMAbands_middle[0], 0);
    double halfLowerPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_down[0]) / 2, 0);
    double halfUpperPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_up[0]) / 2, 0);

    datetime time = iTime(_Symbol, PERIOD_M1, 0);
    // Print date
    // printTime();

    MqlRates candle[];
    ArraySetAsSeries(candle, true);
    int Data = CopyRates(Symbol(), Period(), 0, 3, candle);

    getMagicFromOpenPosition(openPosMagic);

    // update graphical panel
    panel.Update();

    // TODO: for the signal close only this part of position what signal represents!
    // TODO: reset set typePosition

    // BUY 1/4 on band cross
    // if (!buyOnBand(lowerBand, upperBand, type_position, trade, lotsCrossBand, stoploss))
    // {
    //     Print("***ERROR ON BAND CROSS ORDER");
    // }

    // MAIN BUY
    // TODO: candle[1].close vs tick.last
    if (!mainOrder(lowerBand, upperBand, type_position, trade, lotsMain, stoploss, offset, candle[1].close))
    {
        Print("***ERROR ON MAIN ORDER");
    }

} // end tick

void OnDeinit(const int reason)
{
    panel.Destroy(reason);

    if (tma_handle != INVALID_HANDLE)
    {
        IndicatorRelease(tma_handle);
    }

    if (stoch_handle != INVALID_HANDLE)
    {
        IndicatorRelease(stoch_handle);
    }
}

double OnTester()
{
    if (TesterStatistics(STAT_TRADES) < 10)
    {
        return 0.01;
    }
    double testCriteria = TesterStatistics(STAT_INITIAL_DEPOSIT) + TesterStatistics(STAT_PROFIT);
    return testCriteria;
}
