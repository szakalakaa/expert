
bool shiftStoploss(CTrade &Trade, double TriggerSLProcent, double NewSLProcent, double Ask, double Bid)
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
            double orderPriceOpen = OrderGetDouble(ORDER_PRICE_OPEN);
            if (orderPriceOpen == 0)
            {
                Print("Failed to get ORDER_PRICE_OPEN");
                return false;
            }

            if (OrderGetInteger(ORDER_TYPE) == getOrderType("LONG"))
            {
                double triggerPrice = NormalizeDouble((100 + TriggerSLProcent) * Ask, 0);
                if (triggerPrice == 0)
                {
                    Print("Failed to calculate triggerPrice");
                    return false;
                }
                double newSLPrice = NormalizeDouble(orderPriceOpen * (100 + NewSLProcent), 0);
                if (newSLPrice == 0)
                {
                    Print("Failed to calculate newSLPrice");
                    return false;
                }

                if (triggerPrice > Ask)
                {
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
            if ((orderVolume == lotsOfOrderToFind) && (OrderGetInteger(ORDER_TYPE) == getOrderType(type_positionLL)))
            {

                return true;
            }
        }
    }
    return false;
}

int getOrderType(string type_positionL)
{
    if (type_positionL == "LONG")
        return 5;
    if (type_positionL == "SHORT")
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
