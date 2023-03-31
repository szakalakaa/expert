#include <Trade\Trade.mqh>
#include <Utils\graphicPanel.mqh>
#include <Utils\utils.mqh>

CTrade trade;
CGraphicalPanel panel;

input group "====TMA====";
input double atr_period = 240;
input double atr_multiplier = 2.0;
input double stoploss = 0.01;
input double offset_BS = 0; // offset buy sell
input group "====STOCH====";
input double STOCH_up = 60;   // deklaracja zmiennej przechowującej wartość górnej wartosci dla STOCH, domślnie 80
input double STOCH_down = 40; // deklaracja zmiennej przechowującej wartość dolnej wartosci dla STOCH, domyślnie 20
string stochSignal = "";
int laverage = 20; // lewar początkowy

bool securelPartAfterTMAMiddleFlag = false;
string type_position = "NO POSITION";
string TMA_signal = "";
double ask, bid, last, Lots;

// indicators
int tma_handle, stoch_handle;
enum enPrices
{
    pr_weighted
};
double lotsSecured, lotsToShift, positionOpenPrice, spread;
double saldo = AccountInfoDouble(ACCOUNT_BALANCE); // zmienna przechowująca początkową wartość salda
double TMAbands_down[], TMAbands_up[], TMAbands_middle[];
int barsTotal;

// TODO: write a function which shifts sl to the price from parameter, two prices

int OnInit()
{
    Print("Robot started!");
    panel.Oninit();
    ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
    spread = (ask - bid);
    tma_handle = iCustom(Symbol(), 0, "tma_indikator.ex5", 12, pr_weighted, atr_period, atr_multiplier, 4, 0);
    stoch_handle = iStochastic(_Symbol, _Period, 13, 3, 3, MODE_SMA, STO_LOWHIGH);
    barsTotal = iBars(_Symbol, PERIOD_CURRENT);

    if (PositionsTotal())
    {
        // PositionGetSymbol(0);
        // type_position = PositionGetInteger(POSITION_TYPE);
    }

    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnTick()
{
    panel.Update();
    ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
    datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
    int bars = iBars(_Symbol, PERIOD_CURRENT);

    Lots = AccountInfoDouble(ACCOUNT_BALANCE) / last / 10;

    MqlRates candlesticks_info[];
    ArraySetAsSeries(candlesticks_info, true);
    int Data = CopyRates(Symbol(), Period(), 0, 3, candlesticks_info);

    ArraySetAsSeries(TMAbands_down, true);
    ArraySetAsSeries(TMAbands_up, true);
    ArraySetAsSeries(TMAbands_middle, true);
    CopyBuffer(tma_handle, 3, 1, 2, TMAbands_down);
    CopyBuffer(tma_handle, 2, 1, 2, TMAbands_up);
    CopyBuffer(tma_handle, 0, 1, 2, TMAbands_middle);

    double K_period[]; // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
    double D_period[]; // deklaracja tablicy przechowującej wartości  %D "wolnej", okresowej średnia kroczącej
    ArraySetAsSeries(K_period, true);
    ArraySetAsSeries(D_period, true);
    CopyBuffer(stoch_handle, 0, 0, 3, K_period);
    CopyBuffer(stoch_handle, 1, 0, 3, D_period);


    // PROGRAM
    fitstStoplosss(type_position, stoploss, trade);

    // STOCH INDICATOR
    if (bars != barsTotal)
    {
        if ((K_period[0] < STOCH_down) && (D_period[0] < STOCH_down))
        {
            if ((K_period[0] > D_period[0]) && (K_period[1] < D_period[1]))
            {
                stochSignal = "BUY"; // jeżeli obie wartości K,D są poniżej bandy a nastepnie następuję przecięcie
                createObject(time, last, 168, clrYellow, "1");
            }
        }
        if ((K_period[0] > STOCH_up) && (D_period[0] > STOCH_up))
        {
            if ((K_period[0] < D_period[0]) && (K_period[1] > D_period[1]))
            {
                stochSignal = "SELL"; // jeżeli obie wartości K,D są powyżej bandy a nastepnie następuję przecięcie
                createObject(time, last, 234, clrGreen, "2");
            }
        }
        barsTotal = bars;
    }

    // TMA INDICATOR
    if ((last < TMAbands_down[0]) && (type_position != "LONG"))
        TMA_signal = "buy";

    if ((last > TMAbands_up[0]) && (type_position != "SHORT"))
        TMA_signal = "sell";

    // MAIN BUY
    if (TMA_signal == "buy")
    {
        if ((last > candlesticks_info[1].close * (1 + offset_BS)) && (last < TMAbands_down[0]))
        {
            if (type_position == "SHORT")
            {
                trade.PositionClose(PositionGetTicket(0));
                if (OrdersTotal() != 0)
                    trade.OrderDelete(OrderGetTicket(0));
            }
            trade.Buy(NormalizeDouble(Lots * laverage, 4), NULL, ask, 0, 0, "standard buy");
            Print("Bought: ", NormalizeDouble(Lots * laverage, 4), " lots for the ask price: ", DoubleToString(ask, _Digits), ". Spread is: ", spread, "   Triggered by last price: ", last);
            Print("---buy: tma_upper: " + DoubleToString(TMAbands_up[0], _Digits) + "        tma_mid" + DoubleToString(TMAbands_middle[0], _Digits) + "        tma_down: " + DoubleToString(TMAbands_down[0], _Digits) + "bid:" + DoubleToString(bid, _Digits));
            if (OrdersTotal() != 0)
                trade.OrderDelete(OrderGetTicket(0));
            type_position = "LONG";
            TMA_signal = "";
            securelPartAfterTMAMiddleFlag = false;
        }
    }
    // MAIN SELL
    if (TMA_signal == "sell")
    {
        if ((last < candlesticks_info[1].close * (1 - offset_BS)) && (last > TMAbands_up[0]))
        {
            if (type_position == "LONG")
            {
                trade.PositionClose(PositionGetTicket(0));
                if (OrdersTotal() != 0)
                    trade.OrderDelete(OrderGetTicket(0));
            }
            trade.Sell(NormalizeDouble(Lots * laverage, 4), NULL, bid, 0, 0, "standard sell");
            Print("Sold: ", NormalizeDouble(Lots * laverage, 4), " lots for the bid price: ", DoubleToString(bid, _Digits), ". Spread is: ", spread, "   Triggered by last price: ", last);
            Print("---sell: tma_upper: " + DoubleToString(TMAbands_up[0], _Digits) + "        tma_mid" + DoubleToString(TMAbands_middle[0], _Digits) + "        tma_down: " + DoubleToString(TMAbands_down[0], _Digits) + "ask:" + DoubleToString(ask, _Digits));

            if (OrdersTotal() != 0)
                trade.OrderDelete(OrderGetTicket(0));
            type_position = "SHORT";
            TMA_signal = "";
            securelPartAfterTMAMiddleFlag = false;
        }
    }

    if (!securelPartAfterTMAMiddleFlag)
    {
        if (Symbol() == PositionGetSymbol(0))
        {
            lotsSecured = NormalizeDouble((PositionGetDouble(POSITION_VOLUME) / 2), 3);
            positionOpenPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), 0);
            // Secure long position
            if ((last > TMAbands_middle[0]) && (type_position == "LONG"))
            {
                double halfLowerPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_down[0]) / 2, 0);

                if (last > positionOpenPrice)
                    secondStoploss(halfLowerPrice, trade);

                else
                    secondStoploss(NormalizeDouble(TMAbands_down[0], 0), trade);

                securelPartAfterTMAMiddleFlag = true;
            }
            // Secure short position
            if ((last < TMAbands_middle[0]) && (type_position == "SHORT"))
            {
                double halfUpperPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_up[0]) / 2, 0);

                if (last < positionOpenPrice)
                    secondStoploss(halfUpperPrice, trade);
                else
                    secondStoploss(NormalizeDouble(TMAbands_up[0], 0), trade);

                securelPartAfterTMAMiddleFlag = true;
            }
        }
    }

} // end tick

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    panel.PanelChartEvent(id, lparam, dparam, sparam);
}

void OnDeinit(const int reason)
{
    panel.Destroy(reason);
}
