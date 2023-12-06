////unused
void addStoplosss(string &type_positionL, double stoplossL, CTrade &tradeL)
{
    // ADD FIRST STOPLOSS
    if ((PositionsTotal() != 0) && (OrdersTotal() == 0))
    {
        if (Symbol() == PositionGetSymbol(0))
        {
            double sellStopPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN) * (1 - stoplossL), 0);
            double buyStopPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN) * (1 + stoplossL), 0);
            double orderLots = NormalizeDouble(PositionGetDouble(POSITION_VOLUME), 4);

            Print("sellStopPrice: ", sellStopPrice);
            Print("buyStopPrice: ", buyStopPrice);
            Print("orderLots: ", orderLots);

            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                if (!tradeL.SellStop(orderLots, sellStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop loss triggered"))
                    Print("--ERROR 7 on sell stop loss triggered");

            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                if (!tradeL.BuyStop(orderLots, buyStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "buy stop loss triggered"))
                    Print("--ERROR 8 on buy stop loss triggered");
        }
        if (!OrdersTotal())
        {
            Print("--ERROR did not open stop losses for the one position");
            return;
        }
    }
    // REMOVE UNNECESERY ORDERS
    if ((PositionsTotal() == 0) && (OrdersTotal() != 0))
    {
        removeAllOrders(tradeL);
    }
}



//unused
// add new stoploss on the secPrice and shift the primary SL to the half way between sl and op
void secondStoploss(CTrade &tradeL)
{
    if ((PositionsTotal() == 1) && (OrdersTotal() == 1))
    {
        PositionSelect(_Symbol);
        ulong orderTicket = OrderGetTicket(0);

        double posVolume = NormalizeDouble(PositionGetDouble(POSITION_VOLUME) / 2, 4);
        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);

        if ((!posVolume) || (!posPrice) || (!orderPrice))
        {
            Alert("prices error3: ", posVolume, "  ", posPrice, "  ", orderPrice);
            return;
        }

        // INFO: for buy 1. order has higher price
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {

            double profitPrice = posPrice + 30;
            double orderHigher = MathMax(profitPrice, orderPrice);
            double orderLower = MathMin(profitPrice, orderPrice);

            if ((!profitPrice) || (!orderHigher) || (!orderLower))
            {
                Alert("prices error1: ", profitPrice, "  ", orderHigher, "  ", orderLower);
                return;
            }

            if (!tradeL.OrderDelete(orderTicket))
                Print("---ERROR3: Zlecenie:  " + (string)orderTicket + " nie zostalo zamkniete ");

            if (!tradeL.SellStop(posVolume, orderHigher, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "SellStop orderHigher"))
                Print("---ERROR: SellStop on the orderHigher price: " + (string)orderHigher);

            if (!tradeL.SellStop(posVolume, orderLower, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "SellStop orderLower"))
                Print("---ERROR: SellStop on the orderLower price: " + (string)orderLower);

            else
                return;
        }

        // INFO: for sell 1 order has lower price
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {

            double profitPrice = posPrice - 30;
            double orderHigher = MathMax(profitPrice, orderPrice);
            double orderLower = MathMin(profitPrice, orderPrice);

            if ((!profitPrice) || (!orderHigher) || (!orderLower))
            {
                Alert("prices error2: ", profitPrice, "  ", orderHigher, "  ", orderLower);
                return;
            }

            if (!tradeL.OrderDelete(orderTicket))
                Print("---ERROR4: Zlecenie: " + (string)orderTicket + " nie zostalo zamkniete ");

            if (!tradeL.BuyStop(posVolume, orderLower, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "BuyStop orderLower"))
                Print("---ERROR: BuyStop on the orderLower price: " + (string)orderLower);

            if (!tradeL.BuyStop(posVolume, orderHigher, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "BuyStop orderHigher"))
                Print("---ERROR: BuyStop on the orderHigher price: " + (string)orderHigher);
            else
                return;
        }
        else
            return;

        // TODO: check amount of orders
    }
    else
        Print("secondStoploss failed. One position and one order required!");
}

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


//unused
bool removeOrdersMagic(CTrade &tradeClass, ulong inpMagicL)
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
        long orderMagic;
        if (!OrderGetInteger(ORDER_MAGIC, orderMagic))
        {
            Print("Failed to get order magic ");
            return false;
        }
        if (orderMagic == inpMagicL)
        {
            if (!tradeClass.OrderDelete(orderTicket))
                Print("--ERROR 69");
        }
    }
    return true;
}
