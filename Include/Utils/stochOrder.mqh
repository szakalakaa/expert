#include <Trade\Trade.mqh>
#include <Utils\ordersUtils.mqh>
#include <Utils\utils.mqh>

bool checkArray(double arg1, double arg2, double arg3, double arg4)
{

    if (arg1 > 100 || arg1 < 0 ||
        arg2 > 100 || arg2 < 0 ||
        arg3 > 100 || arg3 < 0 ||
        arg4 > 100 || arg4 < 0

    )
    {
        Print("Stoch values are wrong!");
        return false;
    }

    return true;
}

bool stochOrder(double &kPeriod[],
                double &dPeriod[],
                int StochUpper,
                int StochLower,
                double Last,
                double Ask,
                double Bid,
                double lastCandleClose,
                bool &IsStochOrder,
                bool IsMainOrder,
                CTrade &Trade,
                double LotsStoch,
                double SellStopPriceStoch,
                double BuyStopPriceStoch,
                string &type_positionL,
                int &StochAmount)
{
    datetime time = iTime(_Symbol, PERIOD_M1, 0);
    kPeriod[0] = NormalizeDouble(kPeriod[0], 0);
    kPeriod[1] = NormalizeDouble(kPeriod[1], 0);
    dPeriod[0] = NormalizeDouble(dPeriod[0], 0);
    dPeriod[1] = NormalizeDouble(dPeriod[1], 0);

    if (!checkArray(kPeriod[0], kPeriod[1], dPeriod[0], dPeriod[1]))
    {
        return false;
    }

    // BUY STOCH
    if (IsMainOrder)
    {
        if (kPeriod[0] < StochLower && dPeriod[0] < StochLower && kPeriod[0] > dPeriod[0] && kPeriod[1] < dPeriod[1])   //cross d and p under stochlower
        {
            if (Last > lastCandleClose && type_positionL=="LONG")
            {
                // OPEN
                if (!IsStochOrder)
                {
                    if (!Trade.Buy(LotsStoch, NULL, Ask, 0, 0, "buy stoch"))
                        Print("--ERROR 52A buy stoch");

                    if (!Trade.SellStop(LotsStoch, SellStopPriceStoch, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop stoch"))
                        Print("--ERROR 62A on sell stop loss stoch triggered");
                    StochAmount += 1;
                    createObject(time, Last, 141, clrGreen, "1"); 
                    return true;
                }
                // CLOSE
                if (IsStochOrder && type_positionL != "LONG")
                {
                    Trade.PositionClose(PositionGetTicket(0));

                    if (OrdersTotal() != 0)
                    {
                        removeAllOrders(Trade);
                    }
                    return true;
                }
            }
        }
    }

    // SELL STOCH
    if (IsMainOrder)
    {
        if (kPeriod[0] > StochUpper && dPeriod[0] > StochUpper && kPeriod[0] < dPeriod[0] && kPeriod[1] > dPeriod[1])
        {
            if (Last < lastCandleClose  && type_positionL=="SHORT")
            {
                // OPEN
                if (!IsStochOrder)
                {
                    if (!Trade.Sell(LotsStoch, NULL, Bid, 0, 0, "sell stoch"))
                        Print("--ERROR 52S sell stoch");

                    if (!Trade.BuyStop(LotsStoch, BuyStopPriceStoch, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop stoch"))
                        Print("--ERROR 62A on sell stop loss stoch triggered");

                    StochAmount += 1;
                    createObject(time, Last, 141, clrGreen, "1");
                    type_positionL = "SHORT";
                    return true;
                }
                // CLOSE
                if (IsStochOrder && type_positionL != "SHORT")
                {
                    Trade.PositionClose(PositionGetTicket(0));
                    if (OrdersTotal() != 0)
                    {
                        removeAllOrders(Trade);
                    }
                    return true;
                }
            }
        }
    }

    return true;
}

// gdy sprzeda cross i main, potem po przekroczeniu tmaDown, zostaje mu tylko main i signal do kupna cross -> robi zakup i sprawdza czy jest pozycja po pozycji (a moze trzeba po orderze?)