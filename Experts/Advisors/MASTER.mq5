#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>
#include <Utils\graphicPanel.mqh>

CTrade trade;
CGraphicalPanel panel;

input group "====GENERAL====";
static input long inpMagic = 3434546; // magic number

input group "====TMA====";
input double atr_period = 190;
input double atr_multiplier = 0.9;
input double stoploss = 0.026;
input ENUM_TIMEFRAMES per = PERIOD_M30;
input int levar = 3;

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
double Lots;
double TMAbands_down[], TMAbands_up[], TMAbands_middle[];
double ask, last, bid;

int OnInit()
{
    Print("stoploss ", stoploss);
    panel.Oninit();
    // check inputs
    if (stoploss <= 0 || stoploss > 0.04)
    {
        Alert("stoploss <= 0 || stoploss > 0.04");
        return INIT_PARAMETERS_INCORRECT;
    }

    Print("Robot started!");

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
    panel.Update();
    // check if current tick is a bar open tick
    if (!shouldProcess(per))
        return;

    // get current tick
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

    // print date
    datetime time = iTime(_Symbol, PERIOD_M1, 0);
    Print("time: ", time);

    Lots = getLots(tick.last, levar);
    if (Lots <= 0)
    {
        Print("12 Lots <0");
        return;
    }

    MqlRates candle[];
    ArraySetAsSeries(candle, true);
    int Data = CopyRates(Symbol(), Period(), 0, 3, candle);
    ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
    // TMA INDICATOR
    TMA_signal = getTmaSignal(tick.last, TMAbands_down[0], TMAbands_up[0], type_position);

    // MAIN BUY
    if (TMA_signal == "buy")
    {
        if ((last > candle[1].close) && (last < TMAbands_down[0]) && (ask > 1000))
        {
            if (type_position == "SHORT")
            {
                trade.PositionClose(PositionGetTicket(0));
                if (OrdersTotal() != 0)
                    trade.OrderDelete(OrderGetTicket(0));
            }
            if (!trade.Buy(Lots, NULL, ask, 0, 0, "standard buy"))
                Print("--ERROR 5 on standard buy");

            if (OrdersTotal() != 0)
                trade.OrderDelete(OrderGetTicket(0));
            type_position = "LONG";
            TMA_signal = "";
        }
    }

    // MAIN SELL
    if (TMA_signal == "sell")
    {
        if ((last < candle[1].close) && (last > TMAbands_up[0]) && (bid > 1000))
        {
            if (type_position == "LONG")
            {
                trade.PositionClose(PositionGetTicket(0));
                if (OrdersTotal() != 0)
                    trade.OrderDelete(OrderGetTicket(0));
            }
            if (!trade.Sell(Lots, NULL, bid, 0, 0, "standard sell"))
                Print("--ERROR 5 on standard sell");

            if (OrdersTotal() != 0)
                trade.OrderDelete(OrderGetTicket(0));
            type_position = "SHORT";
            TMA_signal = "";
        }
    }

    addStoplosss(type_position, stoploss, trade);
} // end tick

void OnDeinit(const int reason)
{
    panel.Destroy(reason);
    if (tma_handle != INVALID_HANDLE)
    {
        IndicatorRelease(tma_handle);
    }
}