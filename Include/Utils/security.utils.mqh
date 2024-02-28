#include <Utils\global.variables.mqh>

void accountGuardian(InitialStruct &I, GlobalStruct &G, CTrade &Trade, double InitialAccount, double &CurrentAccount, double &CurrentBalance, bool &StopExpert)
{
    CurrentAccount = AccountInfoDouble(ACCOUNT_BALANCE);

    CurrentBalance = NormalizeDouble(100 * CurrentAccount / InitialAccount, 2);


    // stop when balance is low
    if ((InitialAccount * I.insureProcentOfAccount / 100) > CurrentAccount)
    {
        G.stopExpert = true;
        Print("Saldo konta spadło " + (string)(100 - I.insureProcentOfAccount) + " % od początku pracy expert advisora!!!");
    }

    // stop when no stoplosses
    if (!checkPositionAndOrdersAmount())
    {
        G.stopExpert = true;
        // if (I.accountGuardianTriggered == 0)
        // {
        //     I.accountGuardianTriggered += 1;
        //     // I.testInt = I.accountGuardianTriggered;
        //     Print("CLOSING ALL ORDERS AND POSITIONS");
        //     // Trade.PositionClose(PositionGetTicket(0));
        //     // removeAllOrders(Trade);

        // }
        // else
        // {
        //     // G.stopExpert = true;

        // }
    }


    // print message when expert is stopped
    if (G.stopExpert)
    {
        Print("Expert exit");
    }

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

bool addNewStopLoss(CTrade &TradeL, GlobalStruct &Global)
{
    if (PositionsTotal())
    {
        string buyCommentt = "buy stop account guardian";
        string sellCommentt = "sell stop account guardian";
        PositionGetSymbol(0);
        double lotsPosition = NormalizeDouble(PositionGetDouble(POSITION_VOLUME), 4);

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
            if (!TradeL.BuyStop(lotsPosition, Global.buyStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, buyCommentt))
            {
                Print("--ERROR BUYSTOP ACCOUNT GUARDIAN 1: " + buyCommentt);
                return false;
            }
        }

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            if (!TradeL.SellStop(lotsPosition, Global.sellStopPriceMain, _Symbol, 0, 0, ORDER_TIME_GTC, 0, sellCommentt))
            {
                Print("--ERROR SELLSTOP ACCOUNT GUARDIAN 2: " + sellCommentt);
                return false;
            }
        }
    }
    return true;
}