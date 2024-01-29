#include <Trade\Trade.mqh>
#include <Trade\DealInfo.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\shiftStopLoss.mqh>
#include <Utils\crossBandOrder.mqh>
#include <Utils\mainOrder.mqh>
#include <Utils\secondReverseOrder.mqh>
#include <Utils\utils.mqh>
#include <Utils\graphicPanel.mqh>
#include <Utils\check.utils.mqh>
#include <Utils\timers.utils.mqh>
#include <Utils\settingValues.utils.mqh>
#include <Utils\security.utils.mqh>
#include <Utils\global.variables.mqh>

CTrade trade;
CGraphicalPanel panel;
GlobalStruct global;
InitialStruct initial;

input group "====GENERAL====";
input double stoploss = 0.018;
input int atr_period = 300;
input double atr_multiplier = 2;

input group "====OPTIONS====";
input bool applyCross = true, applyMain = true, applySecondReverse = true;
input bool applyCrossUpdate = true, applyMainUpdate = false, applySecondReverseUpdate = false;

input group "====LOTS====";
input double lotsCrossBand = 0.001;
input double lotsMain = 0.0008;
input double lotsMainAux = 0.0007;
input double lotsSecondReverse = 0.00009;

// safety parameters

string type_position = "NO POSITION";

// indicators
int tma_handle;
enum enPrices
{
    pr_weighted
};
MqlTick tick;

MqlRates candle[];

double TMAbands_down[], TMAbands_up[];

bool isCrossOrder = false, isMainOrder = false, isSecondReverseOrder = false;

// statistics
int crossAmount = 0, mainAmount = 0, shiftAmount = 0, secondReverseAmount = 0;

string sellComment[9];
string buyComment[9];

double targetProfitsCross[] = {1.2, 1.6, 2, 3};           // Lista docelowych zysków w procentach
double stopLossPercentagesCross[] = {0.5, 1.0, 1.5, 2.0}; // Lista nowych poziomów stop loss w procentach

double targetProfitsMain[] = {2, 2.5, 3.0, 4.5};
double stopLossPercentagesMain[] = {0.5, 1, 1.5, 2.0};

double targetProfitsMainAux[] = {1, 1.5, 3.0, 4.5};
double stopLossPercentagesMainAux[] = {0.5, 1, 2.5, 3};

double targetProfitsSecondReverse[] = {1, 1.5, 2.0, 2.5};
double stopLossPercentagesSecondReverse[] = {0.5, 1, 1.5, 2.0};

string crossOrders[10];
string mainOrders[10];
string mainAuxOrders[10];
string isSecondReverseOrders[10];

bool timeBlockadeCross = false;
bool timeBlockadeMain = false;
bool timeBlockadeSecondReverse = false;

double memorySLCross, memorySLMain;
int crossRemainMinutes, mainRemainMinutes;
double initialAccount, currentAccount, currentBalance;

int OnInit()
{
    fillOrdersTable(sellComment, buyComment);
    fillCommentsTable(mainOrders, buyComment[3], sellComment[3], stopLossPercentagesMain);
    fillCommentsTable(mainAuxOrders, buyComment[6], sellComment[6], stopLossPercentagesMainAux);
    fillCommentsTable(crossOrders, buyComment[2], sellComment[2], stopLossPercentagesCross);
    fillCommentsTable(isSecondReverseOrders, buyComment[8], sellComment[8], stopLossPercentagesSecondReverse);

    updateInitial(initial, stoploss, lotsCrossBand, lotsMain, lotsMainAux, lotsSecondReverse, applyCross, applyMain, applySecondReverse);

    global.stopExpert = false;
    initialAccount = AccountInfoDouble(ACCOUNT_BALANCE);

    // Checking inputs
    if (!checkInputs(initial, atr_period, atr_multiplier))
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

    // Setting arrays as series
    ArraySetAsSeries(TMAbands_down, true);
    ArraySetAsSeries(TMAbands_up, true);

    // DEV
    //  orderOnInit(trade, lotsCrossBand, stoploss, sellComment, buyComment);

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
    if (!coppyBuffersAndTick(tma_handle, TMAbands_down, TMAbands_up, tick))
    {
        return;
    }

    // GET TYPE POSITION
    getTypePosition(type_position, global.lotsInPosition, global.positionOpenPrice);

    // Get price data
    updateGlobal(global, initial, TMAbands_down, TMAbands_up);

    ArraySetAsSeries(candle, true);
    int Data = CopyRates(Symbol(), Period(), 0, 3, candle);

    if (!validVariables(global))
    {
        Print("Validate data error!!!!!");
        return;
    }

    // refactor accountGuardian
    if (!accountGuardian(initial, global, trade, initialAccount, currentAccount, currentBalance, global.stopExpert))
    {
        Print("Expert exit");
        return;
    }

    // CROSS
    timeBlockadeCross = setTimerBlockadeForOrders(global, initial.crossMinutesToWait, crossRemainMinutes, buyComment[2], sellComment[2], isCrossOrder, memorySLCross);
    crossOrder(global, initial, type_position, trade, crossAmount, sellComment, buyComment, timeBlockadeCross);
    updateStopLoss(initial.lotsCross, type_position, trade, crossOrders, targetProfitsCross, stopLossPercentagesCross);

    // MAIN
    timeBlockadeMain = setTimerBlockadeForOrders(global, initial.mainMinutesToWait, mainRemainMinutes, buyComment[3], sellComment[3], isMainOrder, memorySLMain);
    mainOrder(global, initial, type_position, trade, candle[1].close, mainAmount, sellComment, buyComment, timeBlockadeMain);

    if (applyMainUpdate)
    {
        updateStopLoss(initial.lotsMain, type_position, trade, mainOrders, targetProfitsMain, stopLossPercentagesMain);
    }

    if (applySecondReverseUpdate)
    {

        updateStopLoss(initial.lotsMainAux, type_position, trade, mainAuxOrders, targetProfitsMainAux, stopLossPercentagesMainAux);
    }

    // SECOND REVERSE
    // secondReverseOrder(global, initial, type_position, trade, candle, secondReverseAmount, sellComment, buyComment);
    // updateStopLoss(initial.lotsSecondReverse, type_position, trade, isSecondReverseOrders, targetProfitsSecondReverse, stopLossPercentagesSecondReverse);

} // end tick

void OnDeinit(const int reason)
{
    panel.Destroy(reason);

    if (tma_handle != INVALID_HANDLE)
    {
        IndicatorRelease(tma_handle);
    }
}

// TODO:

// jak nie ma pokrycia to dodaj stop loss an ie zatrzymuj experta

//  zabezpiecz, zeby przerywal algo jak nie moze kupic + potem zeby dodal stoplossa jak cos wywali
