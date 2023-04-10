#include <Trade\Trade.mqh>

// FirstPrice is price closer to last
void shiftStoplosses(double firstPrice, double secPrice, string &type_positionL, double stoplossL, CTrade &tradeL)
{
    int ordersAmount = OrdersTotal();
    ulong orderTicket1 = OrderGetTicket(0);
    double orderPrice1 = OrderGetDouble(ORDER_PRICE_OPEN);

    if (ordersAmount == 2)
    {
        ulong orderTicket2 = OrderGetTicket(1);
        double orderPrice2 = OrderGetDouble(ORDER_PRICE_OPEN);
        if (type_positionL == "LONG")
        {
            double newPrice1 = MathMax(orderPrice1, firstPrice);
            double newPrice2 = MathMax(orderPrice2, secPrice);

            tradeL.OrderModify(OrderGetTicket(0), newPrice1, 0, 0, ORDER_TIME_GTC, 0, 0);
            tradeL.OrderModify(OrderGetTicket(1), newPrice2, 0, 0, ORDER_TIME_GTC, 0, 0);
        }
        if (type_positionL == "SHORT")
        {
            double newPrice1 = MathMin(orderPrice1, firstPrice);
            double newPrice2 = MathMin(orderPrice2, secPrice);

            tradeL.OrderModify(OrderGetTicket(0), newPrice1, 0, 0, ORDER_TIME_GTC, 0, 0);
            tradeL.OrderModify(OrderGetTicket(1), newPrice2, 0, 0, ORDER_TIME_GTC, 0, 0);
        }
    }
    if (ordersAmount == 1)
        tradeL.OrderModify(OrderGetTicket(0), firstPrice, 0, 0, ORDER_TIME_GTC, 0, 0);
}

void fitstStoplosss(string &type_positionL, double stoplossL, CTrade &tradeL)
{
    // ADD FIRST STOPLOSS
    if ((PositionsTotal() != 0) && (OrdersTotal() == 0))
    {
        if (Symbol() == PositionGetSymbol(0))
        {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                if (!tradeL.SellStop(NormalizeDouble(PositionGetDouble(POSITION_VOLUME), 4), NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN) * (1 - stoplossL), 0), _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop loss triggered"))
                    Print("--ERROR 7 on sell stop loss triggered");

            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                if (!tradeL.BuyStop(NormalizeDouble(PositionGetDouble(POSITION_VOLUME), 4), NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN) * (1 + stoplossL), 0), _Symbol, 0, 0, ORDER_TIME_GTC, 0, "buy stop loss triggered"))
                    Print("--ERROR 8 on buy stop loss triggered");
        }
    }
    // REMOVE ALL ORDERS
    if (PositionsTotal() == 0)
    {
        type_positionL = "NO POSITION";
        removeAllOrders(tradeL);
    }
    // SELLSTOP SUPPLEMENT
    if ((PositionsTotal() != 0) && (OrdersTotal() == 1))
    {
        OrderGetTicket(0);
        PositionSelect(_Symbol);
        double posVolume = PositionGetDouble(POSITION_VOLUME);
        double orderVolume = OrderGetDouble(ORDER_VOLUME_CURRENT);
        double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
        double difVolume = NormalizeDouble(posVolume - orderVolume, 5);

        if (difVolume > 0.001)
        {
            Print("difVolume: ", difVolume, "   type_positionL: ", type_positionL);
            if (type_positionL == "LONG")
            {
                if (!tradeL.SellStop(difVolume, orderPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "SellStop supplement"))
                    Print("---ERROR: SellStop supplement ", (string)difVolume, "lots on the price: " + (string)orderPrice);
            }
            if (type_positionL == "SHORT")
            {
                if (!tradeL.BuyStop(difVolume, orderPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "BuyStop supplement"))
                    Print("---ERROR: BuyStop supplement ", (string)difVolume, "lots on the price: " + (string)orderPrice);
            }
        }
    }
}

// add new stoploss on the secPrice and shift the primary SL to the half way between sl and op
void secondStoploss(double secPrice, CTrade &tradeL)
{
    if ((PositionsTotal() == 1) && (OrdersTotal() == 1))
    {
        PositionSelect(_Symbol);
        ulong orderTicket = OrderGetTicket(0);

        double posVolume = NormalizeDouble(PositionGetDouble(POSITION_VOLUME) / 2, 4);
        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);

        // INFO: for buy 1. order has higher price
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            double shiftedPrice = NormalizeDouble((orderPrice + posPrice) / 2, 0);
            double profitPrice = posPrice + 30;
            double orderHigher = MathMax(profitPrice, shiftedPrice);
            double orderLower = MathMin(profitPrice, shiftedPrice);

            if (!tradeL.OrderDelete(orderTicket))
                Print("---ERROR: Order:  " + (string)orderTicket + " was closed ");

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
            double shiftedPrice = NormalizeDouble((orderPrice + posPrice) / 2, 0);
            double profitPrice = posPrice - 30;
            double orderHigher = MathMax(profitPrice, shiftedPrice);
            double orderLower = MathMin(profitPrice, shiftedPrice);

            if (!tradeL.OrderDelete(orderTicket))
                Print("---ERROR: Order: " + (string)orderTicket + " was closed ");

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

// F1->Wingdings  kody ikon
void createObject(datetime time, double price, int iconCode, color clr, string txt)
{
    string objName = "";
    StringConcatenate(objName, "Signal@", time, "at", DoubleToString(price, _Digits), "(", iconCode, ")");

    if (ObjectCreate(0, objName, OBJ_ARROW, 0, time, price))
    {
        ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, iconCode);
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
    }
    else
        Print("createObject went wrong!");
}

void findOpenPosition(string &type_positionL)
{
    if (PositionsTotal())
        PositionSelect(_Symbol);
    {
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            type_positionL = "LONG";

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            type_positionL = "SHORT";
    }
}

void removeAllOrders(CTrade &tradeLL)
{
    if (OrdersTotal() != 0)
    {
        ulong ticket = 0;
        for (int i = 0; i < OrdersTotal(); i++)
        {
            if (!tradeLL.OrderDelete(OrderGetTicket(i)))
                Print("--ERROR 9");
        }
    }
}

double getLots(double lastL)
{
    double lotsTotal = NormalizeDouble((5 * 0.95 * AccountInfoDouble(ACCOUNT_BALANCE) / lastL), 4);
    double lotsConverted = lotsTotal - NormalizeDouble(MathMod(lotsTotal, 0.0004), 4);
    return NormalizeDouble(lotsConverted, 4);
}

// void check_saldo(double &saldoL)
// {
//     if (saldoL > AccountInfoDouble(ACCOUNT_BALANCE))
//     {
//         laverage = laverage_loss;
//     }
//     else if (AccountInfoDouble(ACCOUNT_BALANCE) > saldoL)
//     {
//         laverage = laverage_profit;
//     }
//     saldoL = AccountInfoDouble(ACCOUNT_BALANCE);
// }

struct statsClass
{
    double highest24;
    double lowest24;

    double spread24;
};

void get24Statistics(statsClass &statsL)
{

    MqlDateTime serverTime;
    TimeToStruct(TimeTradeServer(), serverTime);

    double high = iHigh(_Symbol, PERIOD_M15, 0);
    double low = iLow(_Symbol, PERIOD_M15, 0);

    if (!MathMod(serverTime.min,60) && serverTime.sec==0)
    {
        statsL.highest24 = 0;
        statsL.lowest24 = 99999;
    }

    if (high > statsL.highest24)
        statsL.highest24 = high;
    if (low < statsL.lowest24)
        statsL.lowest24 = low;

    statsL.spread24 = statsL.highest24 - statsL.lowest24;
}