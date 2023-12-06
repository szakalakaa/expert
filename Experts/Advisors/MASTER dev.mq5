#include <Trade\Trade.mqh>
#include <Trade\DealInfo.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\shiftStopLoss.mqh>
#include <Utils\crossBandOrder.mqh>
#include <Utils\mainOrder.mqh>
#include <Utils\stochOrder.mqh>
#include <Utils\utils.mqh>
#include <Utils\graphicPanel.mqh>
#include <Utils\check.utils.mqh>
#include <Utils\timers.utils.mqh>
#include <Utils\settingValues.utils.mqh>
#include <Utils\security.utils.mqh>
#include <Utils\comments.mqh>

CTrade trade;
CDealInfo m_deal;
CGraphicalPanel panel;

input group "====GENERAL====";
input ENUM_TIMEFRAMES processPeriod = PERIOD_M1;
input double stoploss = 0.024;
input double newStopLossProcent = 0.5; // triggerSLProcent=3 * newStopLossProcent
input int factor = 2;
int crossMinutesToWait = 90;
int mainMinutesToWait = 30;
int lotsFactor = 3;
input group "====TMA====";
input int atr_period = 240;
input double atr_multiplier = 1.8;

input group "====STOCH====";
int stochUpper = 60; // stochUpper

input group "====OPTIONS====";
input bool applyCross = true, applyMain = true, applyStoch = false;

input group "====LOTS====";
input double lotsCrossBand = 0.0003;
input double lotsStoch = 0.0001;
input double lotsMain = 0.0006;

// general
bool isBetweenBands;

// safety parameters
double stoplossCross = stoploss;
double stoplossMain = 0.02;
double stoplossStoch = stoploss;
bool timeBlockadeCross = false;
bool timeBlockadeMain = false;
datetime timerStart = 0;
static datetime currentTimer;

int crossRemainMinutes, mainRemainMinutes;
bool stopExpert = false;

bool stopLossWasSchifted = false;
double triggerSLProcent = factor * newStopLossProcent;
double newSLProcent = newStopLossProcent;
double initialAccount, currentAccount, currentBalance;
int insureProcentOfAccount = 75;

// lots
double lotsInPosition = 0;
double positionOpenPrice;

// 1000/(lot*37000) = 1000/37

string type_position = "NO POSITION";
int offset = 2; // offset buy/sell  1 = 0.000 1%

// indicators
int tma_handle, stoch_handle;
enum enPrices
{
    pr_weighted
};
MqlTick tick;

// prices
double ask, last, bid;
double TMAbands_down[], TMAbands_up[];
double upperBand, lowerBand;
double sellStopPriceCross, buyStopPriceCross, sellStopPriceMain, buyStopPriceMain, sellStopPriceStoch, buyStopPriceStoch;
bool isCrossOrder = false, isMainOrder = false, isStochOrder = false;

// statistics
int crossAmount = 0, mainAmount = 0, shiftAmount = 0, stochAmount = 0;

// STOCH
int KPeriod = 13;
int DPeriod = 3;
int stochLower = 100 - stochUpper; // deklaracja zmiennej przechowującej wartość dolnej wartosci dla STOCH, domyślnie 20
double K_period[];                 // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
double D_period[];                 // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
string stochSignal = "";

string sellComment[] = {
    "cross sell",
    "cross sell additional",
    "cross sell stop loss",
    "main sell SL "};

string buyComment[] = {
    "cross buy",
    "cross buy additional",
    "cross buy stop loss",
    "main buy SL "};

int OnInit()
{

    // Checking inputs
    if (!checkInputs(stoploss, stoplossCross, stoplossStoch, atr_period, atr_multiplier, stochUpper, KPeriod, DPeriod, triggerSLProcent, newSLProcent, insureProcentOfAccount))
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

    initialAccount = AccountInfoDouble(ACCOUNT_BALANCE);
    Print("Robot started! Initial account: ", initialAccount);
    return (INIT_SUCCEEDED);
}

void OnTick()
{

    // Check if process
    if (!shouldProcess(processPeriod))
        return;

    // update graphical panel
    panel.Update();

    // get indicator values
    if (!coppyBuffersAndTick(tma_handle, TMAbands_down, TMAbands_up, stoch_handle, K_period, D_period, tick))
    {
        return;
    }

    // Get position data
    getTypePosition(type_position, lotsInPosition, positionOpenPrice);

    // SET TIME BLOCKADE WHEN STOPLOSS TRIGGERS
    timeBlockadeCross = setTimerBlockadeForOrders(crossMinutesToWait, crossRemainMinutes, buyComment[2], sellComment[2]);
    timeBlockadeMain = setTimerBlockadeForOrders(mainMinutesToWait, mainRemainMinutes, buyComment[3], sellComment[3]);

    // Get price data
    ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
    upperBand = NormalizeDouble(TMAbands_up[0], 0);
    lowerBand = NormalizeDouble(TMAbands_down[0], 0);
    sellStopPriceCross = NormalizeDouble(bid * (1 - stoplossCross), 0);
    buyStopPriceCross = NormalizeDouble(ask * (1 + stoplossCross), 0);
    sellStopPriceMain = NormalizeDouble(bid * (1 - stoplossMain), 0);
    buyStopPriceMain = NormalizeDouble(ask * (1 + stoplossMain), 0);
    sellStopPriceStoch = NormalizeDouble(bid * (1 - stoplossStoch), 0);
    buyStopPriceStoch = NormalizeDouble(ask * (1 + stoplossStoch), 0);
    isCrossOrder = isOrderWithValue(trade, lotsCrossBand, type_position);
    isMainOrder = isOrderWithValue(trade, lotsMain, type_position);
    isStochOrder = isOrderWithValue(trade, lotsStoch, type_position);
    currentTimer = TimeCurrent();
    isBetweenBands = getIsBetweenBands(last, lowerBand, upperBand);

    MqlRates candle[];
    ArraySetAsSeries(candle, true);
    int Data = CopyRates(Symbol(), Period(), 0, 3, candle);

    if (!validVariables(upperBand, lowerBand, last, ask, bid, sellStopPriceCross, buyStopPriceCross, sellStopPriceMain, buyStopPriceMain))
    {
        Print("Validate data error!!!!!");
        return;
    }

    if (!accountGuardian(initialAccount, currentAccount, insureProcentOfAccount, currentBalance, stopExpert))
    {
        Print("Expert exit");
        return;
    }

    // BUY 1/4 on band cross
    if (applyCross && !buyOnBand(lowerBand, upperBand, last, ask, bid, sellStopPriceCross, buyStopPriceCross, type_position, trade, lotsMain, lotsCrossBand, stoplossCross, isCrossOrder, isMainOrder, timeBlockadeCross, crossAmount, sellComment, buyComment))
    {
        Print("***ERROR ON BAND CROSS ORDER");
        stopExpert = true;
    }

    // MAIN BUY
    if (applyMain && !mainOrder(lowerBand, upperBand, last, ask, bid, buyStopPriceMain, sellStopPriceMain, type_position, trade, lotsMain, stoploss, offset, candle[1].close, isMainOrder, isStochOrder, stopLossWasSchifted, mainAmount, timeBlockadeMain))
    {
        Print("***ERROR ON MAIN ORDER");
        stopExpert = true;
    }

    if (applyStoch && !stochOrder(K_period, D_period, stochUpper, stochLower, last, ask, bid, candle[1].close, isStochOrder, isMainOrder, trade, lotsStoch, sellStopPriceStoch, buyStopPriceStoch, type_position, stochAmount))
    {
        Print("***ERROR ON STOCH");
        stopExpert = true;
    }
    // updateStopLoss(lotsMain, type_position, trade, sellComment, buyComment);

    // TRASH
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

// TODO:
// dodaj  zlecenie na powrocie
// zmien errory na polskie
//  zabezpiecz, zeby przerywal algo jak nie moze kupic + potem zeby dodal stoplossa jak cos wywali
// zamkniecie stoch jak nie ma maina
// TODO: stoplosswasshifted=true (after SL hit) doesnt clear when is set main short  19.10
// IsMainOrder nie odpalil sie, bo nie bylo orderu zadnego bo wczesniej stoploos go zwinal