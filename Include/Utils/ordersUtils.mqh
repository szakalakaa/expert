
// OrderGetInteger(ORDER_TYPE)=5 for LONG type_position => sellStop order
// OrderGetInteger(ORDER_TYPE)=4 for SHORT type_position => buyStop order
bool isOrderWithComments(CTrade &tradeClass, string &commentsToFind[], string type_positionLL)
{
    bool hasOrder = false;
    int total = OrdersTotal();
    if (total)
    {
        for (int i = total - 1; i >= 0; i--)
        {
            ulong orderTicket = OrderGetTicket(i);
            if (orderTicket <= 0)
            {
                Print("Failed to get order ticket");
                return hasOrder;
            }
            if (!OrderSelect(orderTicket))
            {
                Print("Failed to select order");
                return hasOrder;
            }

            string comment = OrderGetString(ORDER_COMMENT);

            for (int i = ArraySize(commentsToFind) - 1; i >= 0; i--)
            {

                if ((comment == commentsToFind[i]))
                {
                    hasOrder = true;
                    return hasOrder;
                }
            }
        }
    }
    return hasOrder;
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

ulong getOrderTicketByVolume(double lotsOfOrderToFind)
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
                return -1;
            }
            if (!OrderSelect(orderTicket))
            {
                Print("Failed to select order");
                return -1;
            }
            double orderVolume = OrderGetDouble(ORDER_VOLUME_CURRENT);
            if (orderVolume == 0)
            {
                Print("Failed to get order volume");
                return -1;
            }
            if ((orderVolume == lotsOfOrderToFind))
            {

                return orderTicket;
            }
        }
    }
    return -1;
}

ulong getOrderTicketByComment(string commentToFind)
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
                return -1;
            }
            if (!OrderSelect(orderTicket))
            {
                Print("Failed to select order");
                return -1;
            }
            string comment = OrderGetString(ORDER_COMMENT);

            if ((comment == commentToFind))
            {
                return orderTicket;
            }
        }
        return -1;
    }
    else
        return -1;
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
                {
                    Print("--ERROR 88");
                    Print("OrderTicket: ", orderTicket, " with volume: ", orderVolume, " lots was removed.");
                    return true;
                }
            }
        }
    }
    return false;
}

bool removeOrderWithComment(CTrade &Trade, string commentToRemove)
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
            string comment = OrderGetString(ORDER_COMMENT);

            if (comment == commentToRemove)
            {
                if (!Trade.OrderDelete(orderTicket))
                    Print("--ERROR ON REMOVE ORDER: commentToRemove ", commentToRemove);
            }
        }
    }
    return false;
}

void removeAllOrders(CTrade &tradeLL)
{
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (!tradeLL.OrderDelete(OrderGetTicket(i)))
            Print("--ERROR 9");
    }
  
}
