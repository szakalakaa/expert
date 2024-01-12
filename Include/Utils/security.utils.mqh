#include <Utils\global.variables.mqh>

bool accountGuardian(InitialStruct &I, GlobalStruct &G)
{
    G.currentAccount = AccountInfoDouble(ACCOUNT_BALANCE);

    G.currentBalance = NormalizeDouble(100 * G.currentAccount / G.initialAccount, 2);

    if ((G.initialAccount * I.insureProcentOfAccount / 100) > G.currentAccount)
    {
        G.stopExpert = true;
        Print("Saldo konta spadło " + (string)(100 - I.insureProcentOfAccount) + " % od początku pracy expert advisora!!!");
        return false;
    }

    // if (!checkPositionAndOrdersAmount())
    // {
    //     G.stopExpert = true;
    //     return false;
    // }

    if (G.stopExpert)
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