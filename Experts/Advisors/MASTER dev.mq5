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
#include <Utils\global.variables.mqh>
#include <Utils\comments.mqh>

CTrade trade;
CGraphicalPanel panel;
GlobalStruct global;
InitialStruct initial;

input group "====GENERAL====";
ENUM_TIMEFRAMES processPeriod = PERIOD_M1;
input double stoploss = 0.02;

input group "====TMA====";
input int atr_period = 200;
input double atr_multiplier = 2;

input group "====STOCH====";
int stochUpper = 60; // stochUpper

input group "====OPTIONS====";
input bool applyCross = true, applyMain = true, applyStoch = false;

input group "====LOTS====";
input double lotsCrossBand = 0.0001;
input double lotsMain = 0.0003;

// safety parameters
bool timeBlockadeCross = false;
bool timeBlockadeMain = false;
double memorySLCross, memorySLMain;
datetime timerStart = 0;
int crossRemainMinutes, mainRemainMinutes;

double initialAccount, currentAccount, currentBalance;

// lots
double lotsInPosition = 0;
double positionOpenPrice;

// 1000/(lot*37000) = 1000/37

string type_position = "NO POSITION";

// indicators
int tma_handle, stoch_handle;
enum enPrices
{
    pr_weighted
};
MqlTick tick;

// prices

double TMAbands_down[], TMAbands_up[];

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

string sellComment[7];
string buyComment[7];

double targetProfitsCross[] = {1.2, 1.6, 2, 3};           // Lista docelowych zysków w procentach
double stopLossPercentagesCross[] = {0.5, 1.0, 1.5, 2.0}; // Lista nowych poziomów stop loss w procentach

double targetProfitsMain[] = {1, 1.5, 2.0, 2.5};
double stopLossPercentagesMain[] = {0.5, 1, 1.5, 2.0};

string crossOrders[10];
string mainOrders[10];

int OnInit()
{
    fillOrdersTable(sellComment, buyComment);
    fillCommentsTable(crossOrders, buyComment[2], sellComment[2], stopLossPercentagesCross);
    fillCommentsTable(mainOrders, buyComment[3], sellComment[3], stopLossPercentagesMain);

    updateInitial(initial, stoploss, lotsCrossBand, lotsMain);
    global.stopExpert = false;
    // Checking inputs
    if (!checkInputs(initial, atr_period, atr_multiplier, stochUpper, KPeriod, DPeriod))
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

    // DEV
    //  orderOnInit(trade, lotsCrossBand, stoploss, sellComment, buyComment);

    initialAccount = AccountInfoDouble(ACCOUNT_BALANCE);
    Print("Robot started! Initial account: ", initialAccount);
    return (INIT_SUCCEEDED);
}

void OnTick()
{
    // Check if process
    if (!shouldProcess())
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
    timeBlockadeCross = setTimerBlockadeForOrders(global, initial.crossMinutesToWait, crossRemainMinutes, buyComment[2], sellComment[2], isCrossOrder, memorySLCross);
    timeBlockadeMain = setTimerBlockadeForOrders(global, initial.mainMinutesToWait, mainRemainMinutes, buyComment[3], sellComment[3], isMainOrder, memorySLMain);

    // Get price data
    updatePrices(global, initial, TMAbands_down, TMAbands_up);

    MqlRates candle[];
    ArraySetAsSeries(candle, true);
    int Data = CopyRates(Symbol(), Period(), 0, 3, candle);

    if (!validVariables(global))
    {
        Print("Validate data error!!!!!");
        return;
    }

    // refactor accountGuardian
    if (!accountGuardian(initial, initialAccount, currentAccount, currentBalance, global.stopExpert))
    {
        Print("Expert exit");
        return;
    }

    // CROSS ORDER
    if (applyCross)
    {
        crossOrder(global, initial, type_position, trade, timeBlockadeCross, crossAmount, sellComment, buyComment);
    }

    // // MAIN ORDER
    if (applyMain)
    {
        mainOrder(global, initial, type_position, trade, candle[1].close, mainAmount, timeBlockadeMain, sellComment, buyComment);
    }

    // STOCH ORDER
    //    isStochOrder = isOrderWithValue(trade, lotsStoch, type_position);
    // if (applyStoch && !stochOrder(K_period, D_period, stochUpper, stochLower, last, ask, bid, candle[1].close, isStochOrder, isMainOrder, trade, lotsStoch, sellStopPriceStoch, buyStopPriceStoch, type_position, stochAmount))
    // {
    //     Print("***ERROR ON STOCH");
    //     stopExpert = true;
    // }

    // TEST
    updateStopLoss(lotsMain, type_position, trade, mainOrders, targetProfitsMain, stopLossPercentagesMain);
    updateStopLoss(lotsCrossBand, type_position, trade, crossOrders, targetProfitsCross, stopLossPercentagesCross);

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

// przyciski na graphical panel
// jak nie ma pokrycia to dodaj stop loss an ie zatrzymuj experta
// stopExpert propsa uzyj
//  zabezpiecz, zeby przerywal algo jak nie moze kupic + potem zeby dodal stoplossa jak cos wywali
// zamkniecie stoch jak nie ma maina
// TODO: stoplosswasshifted=true (after SL hit) doesnt clear when is set main short  19.10
// IsMainOrder nie odpalil sie, bo nie bylo orderu zadnego bo wczesniej stoploos go zwinal