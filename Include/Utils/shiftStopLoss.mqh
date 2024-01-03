#include <Utils\ordersUtils.mqh>

void updateStopLoss(double LotsToShift,
                    string Type_position,
                    CTrade &tradeClass,
                    string &CommentOrders[],
                    double &targetProfits[],
                    double &stopLossPercentages[],
                    int &IndexMemory)
{

    double lastt = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);

    if (PositionGetInteger(POSITION_TICKET) > 0)
    {
        double percentProfit = getPercentageProfit(Type_position);
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        datetime time = iTime(_Symbol, PERIOD_M1, 0);
        ulong orderTicketFor = -1;
        string commentToRemove;
        
        for (int i = ArraySize(targetProfits) - 1; i >= 0; i--)
        {

            if (percentProfit >= targetProfits[i])
            {

                bool hasComment = false;
                string baseComment = Type_position == "LONG" ? (string)CommentOrders[1] : (string)CommentOrders[0];

                for (int j = i; j < ArraySize(targetProfits); j++)
                {

                    string commentFor = baseComment + (string)stopLossPercentages[j];
                    string commentToRemove = baseComment + (string)stopLossPercentages[j - 1];
                    orderTicketFor = getOrderTicketByComment(commentFor);
                    if (orderTicketFor > 0 && orderTicketFor < MathPow(10, 10))
                    {

                        IndexMemory = 1;
                        hasComment = true;
                    }
                }

                if (hasComment && orderTicketFor > 0)
                {
                    return;
                }
                Print("orderTicketFor : ", orderTicketFor);

                if (Type_position == "LONG")
                {
                    double newStopLossLevel = NormalizeDouble(openPrice + (openPrice * stopLossPercentages[i] * 0.01), 0);
                    string setComment = (string)CommentOrders[1] + (string)stopLossPercentages[i];

                    if (!tradeClass.SellStop(LotsToShift, newStopLossLevel, _Symbol, 0, 0, ORDER_TIME_GTC, 0, setComment))
                    {
                        Print("------Failed to removeee order, last", NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits));
                        return;
                    }
                    ////

                    int total = OrdersTotal();

                    for (int i = total - 1; i >= 0; i--)
                    {
                        ulong orderTicket = OrderGetTicket(i);
                        string comment = OrderGetString(ORDER_COMMENT);
                        Print(":::: i comment  orderTicket ", i, "  -  ", comment, "  ---------  ", orderTicket);
                    }

                    ///

                    Print("commentToRemove ", commentToRemove);
                    orderTicketFor = OrderGetTicket(0);

                    if (!tradeClass.OrderDelete(orderTicketFor))
                    {
                        Print("--ERROR ON REMOVE ORDER: orderTicketFor ", orderTicketFor);
                        return;
                    }

                    createObject(time, last, 140, clrBlueViolet, "3");
                }

                if (Type_position == "SHORT")
                {
                    double newStopLossLevel = NormalizeDouble(openPrice - (openPrice * stopLossPercentages[i] * 0.01), 0);
                    string setComment = (string)CommentOrders[0] + (string)stopLossPercentages[i];

                    if (!tradeClass.BuyStop(LotsToShift, newStopLossLevel, _Symbol, 0, 0, ORDER_TIME_GTC, 0, setComment))
                    {
                        Print("------Failed to removeee order, last 22 ", NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits));
                        return;
                    }
                    if (!tradeClass.OrderDelete(orderTicketFor))
                    {
                        Print("--ERROR ON REMOVE ORDER: orderTicketFor ", orderTicketFor);
                        return;
                    }

                    createObject(time, last, 140, clrDarkOrange, "3");
                }
                break;
            }
        }
    }
}
