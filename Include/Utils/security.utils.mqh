bool accountGuardian(double InitialAccount, double &CurrentAccount, int InsureProcentOfAccount, double &CurrentBalance, bool &StopExpert)
{
    CurrentAccount = AccountInfoDouble(ACCOUNT_BALANCE);

    CurrentBalance = NormalizeDouble(100 * CurrentAccount / InitialAccount, 2);

    if ((InitialAccount * InsureProcentOfAccount / 100) > CurrentAccount)
    {
        StopExpert = true;
        Print("Saldo konta spadło " + (string)(100 - InsureProcentOfAccount) + " % od początku pracy expert advisora!!!");
        return false;
    }

    // if (!checkPositionAndOrdersAmount())
    // {
    //     StopExpert = true;
    //     return false;
    // }

    if (StopExpert)
    {
        return false;
    }
    return true;
}

bool checkPositionAndOrdersAmount()
{
    if (PositionsTotal())
    {
        PositionGetSymbol(0);
        double lotsPosition = NormalizeDouble(PositionGetDouble(POSITION_VOLUME), 4);
        double lotsOrders = 0;

        int total = OrdersTotal();
        if (total)
        {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
                for (int i = total - 1; i >= 0; i--)
                {
                    OrderGetTicket(i);
                    if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP)
                    {
                        lotsOrders = lotsOrders + OrderGetDouble(ORDER_VOLUME_CURRENT);
                    }
                }
            }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
                for (int i = total - 1; i >= 0; i--)
                {
                    OrderGetTicket(i);
                    if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_STOP)
                    {
                        lotsOrders = lotsOrders + OrderGetDouble(ORDER_VOLUME_CURRENT);
                    }
                }
            }
        }
        lotsOrders = NormalizeDouble(lotsOrders, 4);
        
        if (lotsPosition != lotsOrders)
        {
            Print("lotsPosition: ", lotsPosition);
            Print("lotsOrders: ", lotsOrders);
            Print("Not all positions are covered with stoploss!!");
            return false;
        }

        return true;
    }

    return true;
}