#include <Utils\ordersUtils.mqh>

void updateStopLoss(double LotsToShift,
                    string Type_position,
                    CTrade &tradeClass,
                    string &CommentOrders[],
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
        ulong orderTicketFor = -1;

        for (int i = ArraySize(targetProfits) - 1; i >= 0; i--)
        {

            if (percentProfit >= targetProfits[i])
            {
                bool hasComment = false;
                string baseComment = Type_position == "LONG" ? (string)CommentOrders[1] : (string)CommentOrders[0];

                for (int j = i; j < ArraySize(targetProfits); j++)
                {

                    string commentFor = baseComment + (string)stopLossPercentages[j];
                    orderTicketFor = getOrderTicketByComment(commentFor);
                    if ((orderTicketFor > 0 && orderTicketFor < 1000))
                    {
                        hasComment = true;
                    }
                }

                if (hasComment && orderTicketFor > 0)
                {
                    return;
                }


                if (Type_position == "LONG")
                {
                    double newStopLossLevel = NormalizeDouble(openPrice + (openPrice * stopLossPercentages[i]), 0);
                    string setComment = (string)CommentOrders[1] + (string)stopLossPercentages[i];

                    if (!tradeClass.OrderDelete(orderTicketFor))
                    {
                        Print("--ERROR ON REMOVE ORDER: orderTicketFor ", orderTicketFor);
                        return;
                    }

                    if (!tradeClass.SellStop(LotsToShift, newStopLossLevel, _Symbol, 0, 0, ORDER_TIME_GTC, 0, setComment))
                    {
                        Print("------Failed to removeee order, last", NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits));
                        return;
                    }
                    createObject(time, last, 140, clrBlueViolet, "3");
                }

                if (Type_position == "SHORT")
                {
                    double newStopLossLevel = NormalizeDouble(openPrice - (openPrice * stopLossPercentages[i]), 0);
                    string setComment = (string)CommentOrders[0] + (string)stopLossPercentages[i];

                    if (!tradeClass.OrderDelete(orderTicketFor))
                    {
                        Print("--ERROR ON REMOVE ORDER: orderTicketFor ", orderTicketFor);
                        return;
                    }

                    if (!tradeClass.BuyStop(LotsToShift, newStopLossLevel, _Symbol, 0, 0, ORDER_TIME_GTC, 0, setComment))
                    {
                        Print("------Failed to removeee order, last 22 ", NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits));
                        return;
                    }
                    createObject(time, last, 140, clrDarkOrange, "3");
                }
                break;
            }
        }
    }
}
