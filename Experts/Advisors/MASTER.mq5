#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>
#include <Utils\graphicPanel.mqh>

CTrade trade;
CGraphicalPanel panel;

input group "====MAGIC====";
static input long inpMagic = 44444; // magic number
input group "====GENERAL====";
input double stoploss = 0.014;
int offset = 0; // offset buy sell  10000 = 1%
input ENUM_TIMEFRAMES processPeriod = PERIOD_CURRENT;
int inpLevar = 4;
double levar;
input bool addSecondStopLoss = true;
string type_position = "NO POSITION";

// indicators
int tma_handle, stoch_handle;
enum enPrices
{
    pr_weighted
};
MqlTick tick;
input double Lots=0.012;
double ask, last, bid;
bool addSecondStopLossFlag = false;

input group "====TMA====";
input int atr_period = 230;
input double atr_multiplier = 1.3;

string TMA_signal = "";
double TMAbands_down[], TMAbands_up[];

///////STOCH
input group "====STOCH====";
input double stochUpper = 60; // stochUpper
input int KPeriod = 20;
input int DPeriod = 5;
double stochLower = 100 - stochUpper; // deklaracja zmiennej przechowującej wartość dolnej wartosci dla STOCH, domyślnie 20
double K_period[];                    // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
double D_period[];                    // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
string stochSignal = "";
int cntBuy, cntSell;
long openPosMagic;

int OnInit()
{
    Print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    levar = inpLevar;
    // if(stoploss * levar > 0.1){
    //     levar=NormalizeDouble((0.1/stoploss),2);
    //     Print("xxxx",levar);
    // }

    // Checking inputs
    if (!checkInputs(stoploss, atr_period, atr_multiplier, levar, stochUpper, KPeriod, DPeriod))
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
 addStoplosss(type_position, stoploss, trade);
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
                 CopyBuffer(stoch_handle, 0, 0, 3, K_period) +
                 CopyBuffer(stoch_handle, 0, 0, 3, D_period);

    if (values != 10)
    {
        Alert("Failed to get indicator values! ", values);
        return;
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

    datetime time = iTime(_Symbol, PERIOD_M1, 0);
    // Print date
    printTime();

    MqlRates candle[];
    ArraySetAsSeries(candle, true);
    int Data = CopyRates(Symbol(), Period(), 0, 3, candle);

    // TMA INDICATOR
    TMA_signal = getTmaSignal(tick.last, lowerBand, upperBand, type_position);

    if (!countOpenPositions(cntBuy, cntSell))
    {
        Print("countOpenPositions failed");
        return;
    }

    getMagicFromOpenPosition(openPosMagic);

    // update graphical panel
    panel.Update();

    // SIMULATION STOCH
    if ((K_period[0] < stochLower) && (D_period[0] < stochLower))
    {
      
        if ((K_period[0] > D_period[0]) && (K_period[1] < D_period[1]))
        {
            Print("------2");
            stochSignal = "buy"; // jeżeli obie wartości K,D są poniżej bandy a nastepnie następuję przecięcie
            createObject(time, last, 168, clrGreenYellow, "1");
            Alert("ooooooooooooooooooooooooooo");
        }
    }
    if ((K_period[0] > stochUpper) && (D_period[0] > stochUpper))
    {
    
        if ((K_period[0] < D_period[0]) && (K_period[1] > D_period[1]))
        {
            Print("------4");
            stochSignal = "sell"; // jeżeli obie wartości K,D są powyżej bandy a nastepnie następuję przecięcie
            createObject(time, last, 234, clrPink, "2");
            Alert("xxxxxxxxxxxxxxxxxxxxxxxxxx");
        }
    }

    // MAIN BUY
    if (TMA_signal == "buy")
    {
        double offsetForBuy = NormalizeDouble(candle[1].close * (10000 + offset) / 10000, 0);

        printValues(TMA_signal, last, ask, lowerBand, candle[1].close, offsetForBuy);

        if ((last > offsetForBuy) && (last < lowerBand) && (ask > 1000))

        {
            if (type_position == "SHORT")
            {
                trade.PositionClose(PositionGetTicket(0));
                if (OrdersTotal() != 0)
                    removeOrdersMagic(trade);
            }
            // Lots = getLots(tick.last, levar);
            // if (Lots <= 0)
            // {
            //     Print("getLots problem2: ", Lots);
            //     return;
            // }
            if (!trade.Buy(Lots, NULL, ask, 0, 0, "standard buy"))
                Print("--ERROR 5 on standard buy");

            type_position = "LONG";
            TMA_signal = "";
            addSecondStopLossFlag = false;
        }
    }

    // MAIN SELL
    if (TMA_signal == "sell")
    {
        double offsetForSell = NormalizeDouble(candle[1].close * (10000 - offset) / 10000, 0);
        printValues(TMA_signal, last, bid, upperBand, candle[1].close, offsetForSell);
        if ((last < offsetForSell) && (last > upperBand) && (bid > 1000))

        {
            if (type_position == "LONG")
            {
                trade.PositionClose(PositionGetTicket(0));
                if (OrdersTotal() != 0)
                    removeOrdersMagic(trade);
            }
            // Lots = getLots(tick.last, levar);
            // if (Lots <= 0)
            // {
            //     Print("getLots problem1: ", Lots);
            //     return;
            // }
            if (!trade.Sell(Lots, NULL, bid, 0, 0, "standard sell"))
                Print("--ERROR 5 on standard sell");

            type_position = "SHORT";
            TMA_signal = "";
            addSecondStopLossFlag = false;
        }
    }

    // ADD SECOND STOPLOSS
    if (!addSecondStopLossFlag && addSecondStopLoss)
    {
        if (Symbol() == PositionGetSymbol(0))
        {
            double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double triggerBuyPrice = NormalizeDouble(1.01 * positionPrice, 0);
            double triggerSellPrice = NormalizeDouble(0.99 * positionPrice, 0);

            if ((!positionPrice) || (!triggerBuyPrice) || (!triggerSellPrice))
            {
                Print("Get prices failed: ", positionPrice, " ", triggerBuyPrice, " ", triggerSellPrice);
                return;
            }

            // Secure long position
            if ((last > triggerBuyPrice) && (type_position == "LONG"))
            {
                secondStoploss(trade);
                createObject(time, last, 140, clrDodgerBlue, "1");
                addSecondStopLossFlag = true;
            }
            // Secure short position
            if ((last < triggerSellPrice) && (type_position == "SHORT"))
            {

                secondStoploss(trade);
                createObject(time, last, 140, clrIndianRed, "1");
                addSecondStopLossFlag = true;
            }
        }
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

// double OnTester()
// {
//     // if (TesterStatistics(STAT_BALANCEDD_PERCENT) > 22.00)
//     // {
//     //     return 0.03;
//     // }
//     double testCriteria = TesterStatistics(STAT_INITIAL_DEPOSIT) + TesterStatistics(STAT_PROFIT);
//     return testCriteria;
// }
