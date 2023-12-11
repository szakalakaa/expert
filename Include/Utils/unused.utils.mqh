//unused
bool removeOrders(CTrade &tradeClass)
{
    int total = OrdersTotal();
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
        if (!tradeClass.OrderDelete(orderTicket))
            Print("--ERROR 69");
    }
    return true;
}


