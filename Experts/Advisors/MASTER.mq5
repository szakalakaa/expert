#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>
#include <Utils\graphicPanel.mqh>

CTrade trade;
CGraphicalPanel panel;

input group "====GENERAL====";
static input long inpMagic = 3434546; // magic number

input group "====TMA====";
input int atr_period = 190;
input double atr_multiplier = 0.7;
input double stoploss = 0.028;
input int offset = 0; // offset buy sell  10000 = 1%
input ENUM_TIMEFRAMES per = PERIOD_M30;
int levar = 4;

datetime openTImeBuy = 0;
datetime openTImeSell = 0;
string type_position = "NO POSITION";
string TMA_signal = "";
// indicators
int tma_handle;
enum enPrices
{
    pr_weighted
};
MqlTick tick;
double Lots = 0.014;
double TMAbands_down[], TMAbands_up[], TMAbands_middle[];
double ask, last, bid;

int OnInit()
{
    Print("Expert started!");
    // Checking inputs
    if (!checkInputs(stoploss, atr_period, atr_multiplier))
    {
        return INIT_PARAMETERS_INCORRECT;
    };

    // Panel initialisation
    panel.Oninit();

    // Indicator initialisation
    tma_handle = iCustom(Symbol(), 0, "tma_indikator.ex5", 12, pr_weighted, atr_period, atr_multiplier, 4, 0);

    if (tma_handle == INVALID_HANDLE)
    {
        Alert("Failed to create indicator");
        return INIT_FAILED;
    }

    ArraySetAsSeries(TMAbands_down, true);
    ArraySetAsSeries(TMAbands_up, true);
    ArraySetAsSeries(TMAbands_middle, true);

    trade.SetExpertMagicNumber(inpMagic);
    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnTick()
{

    addStoplosss(type_position, stoploss, trade);
    // Check if process
    if (!shouldProcess(per))
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
                 CopyBuffer(tma_handle, 0, 0, 2, TMAbands_middle);
    if (values != 6)
    {
        Print("Failed to get indicator values!", values);
        return;
    }

    ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
    double upperBand = NormalizeDouble(TMAbands_up[0], 0);
    double lowerBand = NormalizeDouble(TMAbands_down[0], 0);

    // Print date
    printTime();

    MqlRates candle[];
    ArraySetAsSeries(candle, true);
    int Data = CopyRates(Symbol(), Period(), 0, 3, candle);

    // TMA INDICATOR
    TMA_signal = getTmaSignal(tick.last, lowerBand, upperBand, type_position);

    // update graphical panel
    panel.Update();

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
                    trade.OrderDelete(OrderGetTicket(0));
            }
            Lots = getLots(tick.last, levar);
            if (Lots <= 0)
            {
                Print("12 Lots <0");
                return;
            }
            if (!trade.Buy(Lots, NULL, ask, 0, 0, "standard buy"))
                Print("--ERROR 5 on standard buy");

            type_position = "LONG";
            TMA_signal = "";
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
                    trade.OrderDelete(OrderGetTicket(0));
            }
            Lots = getLots(tick.last, levar);
            if (Lots <= 0)
            {
                Print("12 Lots <0");
                return;
            }
            if (!trade.Sell(Lots, NULL, bid, 0, 0, "standard sell"))
                Print("--ERROR 5 on standard sell");

            type_position = "SHORT";
            TMA_signal = "";
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
}
