// INVESTIGATION: SHIFT ORDER DOWN WHEN LAST HITS TRIGGER PRICE   ->tylko main order!
bool shiftStoploss(CTrade &Trade, double TriggerSLProcent, double NewSLProcent, double Ask, double Bid, double Last, double lotsToSchift, bool &StopLossWasSchifted)
{
    if (PositionsTotal())
    {
        PositionGetSymbol(0);
        positionOpenPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), 0);
        datetime time = iTime(_Symbol, PERIOD_M1, 0);
        ulong orderTicket = getOrderTicketByVolume(lotsToSchift);

        if (orderTicket <= 0 || positionOpenPrice <= 0)
        {
            Print("Failed to get orderTicket ", orderTicket, " positionOpenPrice ", positionOpenPrice);
            return false;
        }

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            double triggerPrice = NormalizeDouble(positionOpenPrice * (100 + TriggerSLProcent) / 100, 0);
            double newSLPrice = NormalizeDouble(positionOpenPrice * (100 + NewSLProcent) / 100, 0);

            if (triggerPrice == 0 || newSLPrice == 0)
            {
                Print("Failed to calculate triggerPrice or newSLPrice ", triggerPrice, " ", newSLPrice);
                return false;
            }

            if (Last > triggerPrice)
            {
                createObject(time, newSLPrice, 140, clrSkyBlue, "3");
                if (!Trade.OrderDelete(orderTicket))
                {
                    Print("---ERROR1: Zlecenie: " + (string)orderTicket + " nie zostalo zamkniete ");
                    return false;
                }

                if (!Trade.SellStop(lotsToSchift, newSLPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "SellStop order shifted"))
                    Print("---ERROR: SellStop on the order price: " + (string)newSLPrice);
                StopLossWasSchifted = true;
            }
        }

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
            double triggerPrice = NormalizeDouble(positionOpenPrice * (100 - TriggerSLProcent) / 100, 0);
            double newSLPrice = NormalizeDouble(positionOpenPrice * (100 - NewSLProcent) / 100, 0);

            if (triggerPrice == 0 || newSLPrice == 0)
            {
                Print("Failed to calculate triggerPrice or newSLPrice", triggerPrice, " ", newSLPrice);
                return false;
            }

            if (Last < triggerPrice)
            {
                createObject(time, newSLPrice, 140, clrOrangeRed, "3");
                if (!Trade.OrderDelete(orderTicket))
                {
                    Print("---ERROR2: Zlecenie: " + (string)orderTicket + " nie zostalo zamkniete ");
                    return false;
                }

                if (!Trade.BuyStop(lotsToSchift, newSLPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "BuyStop order shifted"))
                    Print("---ERROR: BuyStop on the order price: " + (string)newSLPrice);
                StopLossWasSchifted = true;
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
