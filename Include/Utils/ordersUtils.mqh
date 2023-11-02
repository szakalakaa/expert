
//INVESTIGATION: SHIFT ORDER DOWN WHEN LAST HITS TRIGGER PRICE
bool shiftStoploss(CTrade &Trade, double TriggerSLProcent, double NewSLProcent, double Ask, double Bid, double Last, bool &StopLossWasSchifted)
{
    PositionsTotal();
    PositionGetSymbol(0);
    positionOpenPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), 0);
    int total = OrdersTotal();
    if (total)
    {
        for (int i = total - 1; i >= 0; i--)
        {
            ulong orderTicket = OrderGetTicket(i);
            if (orderTicket <= 0)
            {
                Print("Failed to get order ticket");
                return false;
            }
            if (!OrderSelect(orderTicket))
            {
                Print("Failed to select order");
                return false;
            }
            double orderVolume = OrderGetDouble(ORDER_VOLUME_CURRENT);
            if (orderVolume == 0)
            {
                Print("Failed to get order volume");
                return false;
            }
            double orderPriceOpen = OrderGetDouble(ORDER_PRICE_OPEN);
            if (orderPriceOpen == 0)
            {
                Print("Failed to get ORDER_PRICE_OPEN");
                return false;
            }

            // POZYCJA SHORT
            if (OrderGetInteger(ORDER_TYPE) == getOrderType("LONG"))
            {
                double stoplos = 0.015;

                double triggerPrice = NormalizeDouble(positionOpenPrice* (100 - TriggerSLProcent) / 100, 0);

                double newSLPrice = NormalizeDouble(positionOpenPrice * (100 - NewSLProcent) / 100, 0);
                if (triggerPrice == 0 || newSLPrice == 0)
                {
                    Print("Failed to calculate triggerPrice or newSLPrice");
                    return false;
                }

                Print("-orderTicket nr: ", i, " - ", orderTicket);
                Print("-positionOpenPrice: ", positionOpenPrice);
                Print("- newSLPrice: ", newSLPrice);
                Print("- triggerPrice: ", triggerPrice);

                Print("-last: ", Last);


                if (Last < triggerPrice)
                {

                    datetime time = iTime(_Symbol, PERIOD_M1, 0);
                    createObject(time, orderPriceOpen, 140, clrCadetBlue, "1");
                    createObject(time, newSLPrice, 140, clrYellow, "2");
                    createObject(time, triggerPrice, 140, clrRosyBrown, "3");

                    StopLossWasSchifted = true;
                    Print("**** SHIFTED *****");

                    if (!Trade.OrderDelete(orderTicket))
                        Print("---ERROR: Order: " + (string)orderTicket + " was closed ");

                    if (!Trade.BuyStop(orderVolume, newSLPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "BuyStop order shifted"))
                        Print("---ERROR: BuyStop on the order price: " + (string)newSLPrice);
                }
            }
        }
    }
    return false;
}

// OrderGetInteger(ORDER_TYPE)=5 for LONG type_position => sellStop order
// OrderGetInteger(ORDER_TYPE)=4 for SHORT type_position => buyStop order
bool isOrderWithValue(CTrade &tradeClass, double lotsOfOrderToFind, string type_positionLL)
{
    int total = OrdersTotal();
    if (total)
    {
        for (int i = total - 1; i >= 0; i--)
        {
            ulong orderTicket = OrderGetTicket(i);
            if (orderTicket <= 0)
            {
                Print("Failed to get order ticket");
                return false;
            }
            if (!OrderSelect(orderTicket))
            {
                Print("Failed to select order");
                return false;
            }
            double orderVolume = OrderGetDouble(ORDER_VOLUME_CURRENT);
            if (orderVolume == 0)
            {
                Print("Failed to get order volume");
                return false;
            }
            if ((orderVolume == lotsOfOrderToFind) && (OrderGetInteger(ORDER_TYPE) == getPositionType(type_positionLL)))
            {

                return true;
            }
        }
    }
    return false;
}

int getPositionType(string type_positionL)
{
    if (type_positionL == "LONG")
        return 5;
    if (type_positionL == "SHORT")
        return 4;
    return 0;
}

int getOrderType(string type_positionL)
{
    if (type_positionL == "SHORT")
        return 5;
    if (type_positionL == "LONG")
        return 4;
    return 0;
}

bool removeOrderWithValue(CTrade &tradeClass, double lotsToRemove)
{
    int total = OrdersTotal();
    if (total)
    {
        for (int i = total - 1; i >= 0; i--)
        {
            ulong orderTicket = OrderGetTicket(i);
            if (orderTicket <= 0)
            {
                Print("Failed to get order ticket");
                return true;
            }
            if (!OrderSelect(orderTicket))
            {
                Print("Failed to select order");
                return true;
            }
            double orderVolume = OrderGetDouble(ORDER_VOLUME_CURRENT);
            if (orderVolume == 0)
            {
                Print("Failed to get order volume");
                return true;
            }
            if (orderVolume == lotsToRemove)
            {
                if (!tradeClass.OrderDelete(orderTicket))
                    Print("--ERROR 88");
                Print("OrderTicket: ", orderTicket, " with volume: ", orderVolume, " lots was removed.");
            }
        }
    }
    return false;
}

void removeAllOrders(CTrade &tradeLL)
{
    if (OrdersTotal() != 0)
    {
        ulong ticket = 0;
        for (int i = 0; i < OrdersTotal(); i++)
        {
            Print("Order ", i, "deleted!");
            if (!tradeLL.OrderDelete(OrderGetTicket(i)))
                Print("--ERROR 9");
        }
    }
}
