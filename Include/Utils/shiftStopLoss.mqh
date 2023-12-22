#include <Utils\ordersUtils.mqh>

void updateStopLoss(double LotsToShift,
                    string Type_position,
                    CTrade &tradeClass,
                    string &SellComment[],
                    string &BuyComment[],
                    double &targetProfits[],
                    double &stopLossPercentages[])
{

    double lastt = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);

    if (PositionGetInteger(POSITION_TICKET) > 0)
    {
        double profit = PositionGetDouble(POSITION_PROFIT);
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double percentProfit = NormalizeDouble((profit / openPrice) * 100, 2);

        datetime time = iTime(_Symbol, PERIOD_M1, 0);

        for (int i = ArraySize(targetProfits) - 1; i >= 0; i--)
        {

            if (percentProfit >= targetProfits[i])
            {
                bool hasComment = false;
                for (int j = i; j < ArraySize(targetProfits); j++)
                {
                    string commentFor = (string)SellComment[3] + (string)stopLossPercentages[j];
                    ulong orderTicketFor = getOrderTicketByComment(commentFor);
                    if ((orderTicketFor > 0 && orderTicketFor < 1000))
                    {
                        hasComment = true;
                    }
                }

                if (hasComment)
                {
                    return;
                }

                double newStopLossLevel = NormalizeDouble(openPrice - (openPrice * stopLossPercentages[i]), 0);

                if (Type_position == "LONG")
                {

                    string setComment = (string)SellComment[3] + (string)stopLossPercentages[i];
                    removeAllOrders(tradeClass);

                    if (!tradeClass.SellStop(LotsToShift, newStopLossLevel, _Symbol, 0, 0, ORDER_TIME_GTC, 0, setComment))
                    {
                        Print("------Failed to removeee order, last", NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits));
                        return;
                    }

                    createObject(time, last, 140, clrBlueViolet, "3");
                }
                break;
            }
        }
    }
}
