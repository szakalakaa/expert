#include <Trade\Trade.mqh>
#include <Trade\DealInfo.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\crossBandOrder.mqh>
#include <Utils\mainOrder.mqh>
#include <Utils\stochOrder.mqh>
#include <Utils\utils.mqh>
#include <Utils\graphicPanel.mqh>
#include <Utils\check.utils.mqh>
#include <Utils\timers.utils.mqh>
#include <Utils\settingValues.utils.mqh>
#include <Utils\security.utils.mqh>

CTrade trade;
CDealInfo m_deal;
CGraphicalPanel panel;

input group "====GENERAL====";
input ENUM_TIMEFRAMES processPeriod = PERIOD_M1;
input double stoploss = 0.016;
input double newStopLossProcent = 0.2; // triggerSLProcent=2 * newStopLossProcent
input int crossMinutesToWait = 60;

input group "====TMA====";
input int atr_period = 260;
input double atr_multiplier = 2.6;

input group "====STOCH====";
input int stochUpper = 60; // stochUpper

input group "====OPTIONS====";
input bool applyCross = true, applyMain = true, applyShiftStopLoss = true, applyBlockade = true, applyStoch = true;

// safety parameters
double stoplossCross = stoploss;
double stoplossStoch = stoploss;
bool timeBlockadeCross = false;
datetime timerStart = 0;
static datetime currentTimer;
int minutesToWait = crossMinutesToWait;
int remainMinutes;
bool stopExpert = false;

bool stopLossWasSchifted = false;
double triggerSLProcent = 3 * newStopLossProcent;
double newSLProcent = newStopLossProcent;
double initialAccount, currentAccount, currentBalance;
int insureProcentOfAccount = 90;

// lots
double lotsCrossBand = 0.0001;
double lotsStoch = 0.0002;
double lotsMain = 0.0003;
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
double upperBand, lowerBand;
double sellStopPriceCross, buyStopPriceCross, sellStopPriceMain, buyStopPriceMain, sellStopPriceStoch, buyStopPriceStoch;
bool isCrossOrder = false, isMainOrder = false, isStochOrder = false;

// statistics

int crossAmount = 0, mainAmount = 0, shiftAmount = 0, stochAmount = 0;

// STOCH
input int KPeriod = 13;
input int DPeriod = 3;
int stochLower = 100 - stochUpper; // deklaracja zmiennej przechowującej wartość dolnej wartosci dla STOCH, domyślnie 20
double K_period[];                 // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
double D_period[];                 // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
string stochSignal = "";

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

    // Get current tick
    if (!SymbolInfoTick(_Symbol, tick))
    {
        Print("Failed to get tick");
        return;
    }

    // get indicator values
    if (!coppyBuffersAndTick(tma_handle, TMAbands_down, TMAbands_up, stoch_handle, K_period, D_period, tick))
    {
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
    sellStopPriceCross = NormalizeDouble(bid * (1 - stoplossCross), 0);
    buyStopPriceCross = NormalizeDouble(ask * (1 + stoplossCross), 0);
    sellStopPriceMain = NormalizeDouble(bid * (1 - stoploss), 0);
    buyStopPriceMain = NormalizeDouble(ask * (1 + stoploss), 0);
    sellStopPriceStoch = NormalizeDouble(bid * (1 - stoplossStoch), 0);
    buyStopPriceStoch = NormalizeDouble(ask * (1 + stoplossStoch), 0);
    isCrossOrder = isOrderWithValue(trade, lotsCrossBand, type_position);
    isMainOrder = isOrderWithValue(trade, lotsMain, type_position);
    isStochOrder = isOrderWithValue(trade, lotsStoch, type_position);

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

    // SET TIME BLOCKADE WHEN STOPLOSS TRIGGERS
    // TODO: unblock conditionally when price hits max/min
    if (applyBlockade)
    {
        setTimerBlockadeForOrders(minutesToWait, currentTimer, timerStart, isMainOrder, timeBlockadeCross, type_position, last, ask, bid, lowerBand, upperBand, remainMinutes);
    }

    // BUY 1/4 on band cross
    if (applyCross && !buyOnBand(lowerBand, upperBand,
                                 last, ask, bid,
                                 sellStopPriceCross, buyStopPriceCross,
                                 type_position,
                                 trade,
                                 lotsMain, lotsCrossBand,
                                 stoplossCross,
                                 isCrossOrder, isMainOrder,
                                 timeBlockadeCross,
                                 crossAmount))
    {
        Print("***ERROR ON BAND CROSS ORDER");
    }

    // MAIN BUY
    if (applyMain && !mainOrder(lowerBand, upperBand,
                                last, ask, bid,
                                buyStopPriceMain, sellStopPriceMain,
                                type_position,
                                trade,
                                lotsMain,
                                stoploss,
                                offset,
                                candle[1].close,
                                isMainOrder,
                                stopLossWasSchifted,
                                mainAmount))
    {
        Print("***ERROR ON MAIN ORDER");
    }

    if (applyStoch && !stochOrder(K_period, D_period,
                                  stochUpper, stochLower,
                                  last, ask, bid,
                                  candle[1].close, 
                                  isStochOrder,isMainOrder,
                                  trade, lotsStoch,
                                  sellStopPriceStoch, buyStopPriceStoch,
                                  type_position,
                                  stochAmount))
    {
        Print("***ERROR ON STOCH");
        stopExpert = true;
    }

    // TODO: stoplosswasshifted=true (after SL hit) doesnt clear when is set main short  19.10
    // IsMainOrder nie odpalil sie, bo nie bylo orderu zadnego bo wczesniej stoploos go zwinal
    if (applyShiftStopLoss && !stopLossWasSchifted)
    {
        shiftStoploss(trade, triggerSLProcent, newSLProcent, ask, bid, last, lotsMain, stopLossWasSchifted, shiftAmount);
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

// TODO:
// dodaj stoch wskaznik i zlecenie na powrocie
// zmien errory na polskie
//  zabezpiecz, zeby przerywal algo jak nie moze kupic + potem zeby dodal stoplossa jak cos wywali