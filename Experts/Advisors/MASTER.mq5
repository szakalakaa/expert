#include <Trade\Trade.mqh>
#include <Trade\DealInfo.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\crossBandOrder.mqh>
#include <Utils\mainOrder.mqh>
#include <Utils\utils.mqh>
#include <Utils\graphicPanel.mqh>
#include <Utils\check.utils.mqh>
#include <Utils\timers.utils.mqh>

CTrade trade;
CDealInfo m_deal;
CGraphicalPanel panel;

input group "====GENERAL====";
input double stoploss = 0.05;
input ENUM_TIMEFRAMES processPeriod = PERIOD_M1;

input group "====TMA====";
input int atr_period = 270;
input double atr_multiplier = 2.2;

input group "====STOCH====";
double stochUpper = 60; // stochUpper

// safety parameters
double stoplossCross = stoploss;
bool blockSellCross = false;
bool blockBuyCross = false;
bool blockCross = false;
datetime timerStart = 0;
static datetime currentTimer;
int minutesToWait = 60;

bool stopLossWasSchifted = false;
double triggerSLProcent = 0.4;
double newSLProcent = 0.1;

// lots
double lotsCrossBand = 0.001;
double lotsMain = 0.003;
double lotsInPosition = 0;
double positionOpenPrice;

string type_position = "NO POSITION";
int offset = 0; // offset buy/sell  1 = 0.000 1%

// indicators
int tma_handle, stoch_handle;
enum enPrices
{
    pr_weighted
};
MqlTick tick;

// prices
double ask, last, bid;
double TMAbands_down[], TMAbands_up[], TMAbands_middle[];
double upperBand, lowerBand, middleBand;
double sellStopPriceCross, buyStopPriceCross, sellStopPriceMain, buyStopPriceMain;
bool isCrossOrder = false, isMainOrder = false;

// STOCH
int KPeriod = 20;
int DPeriod = 5;
double stochLower = 100 - stochUpper; // deklaracja zmiennej przechowującej wartość dolnej wartosci dla STOCH, domyślnie 20
double K_period[];                    // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
double D_period[];                    // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
string stochSignal = "";

// crossMainFlag?
bool crossBlockadeFlag = false;

int OnInit()
{
    Print("Robot started!");

    // Checking inputs
    if (!checkInputs(stoploss, stoplossCross, atr_period, atr_multiplier, stochUpper, KPeriod, DPeriod, triggerSLProcent, newSLProcent))
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

    // // Ustaw stopLossTime na bieżący czas
    // stopLossTime = TimeCurrent() + StopLossMinutes * 60;

    return (INIT_SUCCEEDED);
}

void OnTick()
{

    // Check if process
    if (!shouldProcess(processPeriod))
        return;

    // update graphical panel
    panel.Update();

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
    getTypePosition(type_position, lotsInPosition, positionOpenPrice);

    // Get price data
    ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
    upperBand = NormalizeDouble(TMAbands_up[0], 0);
    lowerBand = NormalizeDouble(TMAbands_down[0], 0);
    middleBand = NormalizeDouble(TMAbands_middle[0], 0);
    sellStopPriceCross = NormalizeDouble(bid * (1 - stoplossCross), 0);
    buyStopPriceCross = NormalizeDouble(ask * (1 + stoplossCross), 0);
    sellStopPriceMain = NormalizeDouble(bid * (1 - stoploss), 0);
    buyStopPriceMain = NormalizeDouble(ask * (1 + stoploss), 0);
    isCrossOrder = isOrderWithValue(trade, lotsCrossBand, type_position);
    isMainOrder = isOrderWithValue(trade, lotsMain, type_position);

    MqlRates candle[];
    ArraySetAsSeries(candle, true);
    int Data = CopyRates(Symbol(), Period(), 0, 3, candle);

    if (!validVariables(upperBand, lowerBand, middleBand, last, ask, bid, sellStopPriceCross, buyStopPriceCross, sellStopPriceMain, buyStopPriceMain))
    {
        Print("Validate data error!!!!!");
        return;
    }

    // SET TIME BLOCKADE WHEN STOPLOSS TRIGGERS
    setTimerBlockadeForOrders(minutesToWait, currentTimer, timerStart, isMainOrder, blockCross, type_position, ask, bid, lowerBand, upperBand);

    // BUY 1/4 on band cross
    if (!buyOnBand(lowerBand,
                   upperBand,
                   last,
                   ask,
                   bid,
                   sellStopPriceCross,
                   buyStopPriceCross,
                   type_position,
                   trade,
                   lotsMain,
                   lotsCrossBand,
                   stoplossCross,
                   isCrossOrder,
                   isMainOrder,
                   blockCross))
    {
        Print("***ERROR ON BAND CROSS ORDER");
    }

    // MAIN BUY
    if (!mainOrder(lowerBand,
                   upperBand,
                   last,
                   ask,
                   bid,
                   buyStopPriceMain,
                   sellStopPriceMain,
                   type_position,
                   trade,
                   lotsMain,
                   stoploss,
                   offset,
                   candle[1].close,
                   isMainOrder,
                   blockCross,
                   stopLossWasSchifted))
    {
        Print("***ERROR ON MAIN ORDER");
    }

    // INVESTIGATION
    if (!stopLossWasSchifted)
    {
        shiftStoploss(trade, triggerSLProcent, newSLProcent, ask, bid, last, stopLossWasSchifted);
    }

    // TRASH:

    Comment(
        "stopLossWasSchifted:     " + (string)stopLossWasSchifted + "\n" +
        "BlockCross:     " + (string)blockCross + "\n");
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
