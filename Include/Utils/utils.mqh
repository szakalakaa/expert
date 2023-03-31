#include <Trade\Trade.mqh>

void fitstStoplosss(string &type_positionL, double stoplossL, CTrade &tradeL)
{
    if ((PositionsTotal() != 0) && (OrdersTotal() == 0))
    {
        if (Symbol() == PositionGetSymbol(0))
        {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
                if (PositionGetDouble(POSITION_VOLUME) > 0.03)
                    tradeL.SellStop(PositionGetDouble(POSITION_VOLUME), NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN) * (1 - stoplossL), 0), _Symbol, 0, 0, ORDER_TIME_GTC, 0, "sell stop loss triggered");
                else
                    tradeL.Sell(PositionGetDouble(POSITION_VOLUME), NULL, 0, 0, 0, "remove rest  buy order");
            }
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
                if (PositionGetDouble(POSITION_VOLUME) > 0.03)
                    tradeL.BuyStop(PositionGetDouble(POSITION_VOLUME), NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN) * (1 + stoplossL), 0), _Symbol, 0, 0, ORDER_TIME_GTC, 0, "buy stop loss triggered");
                else
                    tradeL.Buy(PositionGetDouble(POSITION_VOLUME), NULL, 0, 0, 0, "remove rest  sell order"); // ok
            }
        }
    }
    if (PositionsTotal() == 0)
    {
        type_positionL = "NO POSITION";
        if (OrdersTotal() != 0)
        {
            ulong ticket = 0;
            for (int i = 0; i < OrdersTotal(); i++)
            {
                tradeL.OrderDelete(OrderGetTicket(i));
            }
        }
    }
}

// add new stoploss on the secPrice and shift the primary SL to the half way between sl and op
void secondStoploss(double secPrice, CTrade &tradeL)
{
    if ((PositionsTotal() == 1) && (OrdersTotal() == 1))
    {
        // TODO: probably positionSelect i order select wystarczy
        PositionSelect(_Symbol);
        string posSymbol = PositionGetSymbol(0);
        Print("posSymbol " + posSymbol);
        ulong orderTicket = OrderGetTicket(0);
        Print("orderTicket " + orderTicket);

        double posVolume = NormalizeDouble(PositionGetDouble(POSITION_VOLUME) / 2, 3);
        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            double shiftedPrice = NormalizeDouble((orderPrice + posPrice) / 2, 0);

            if (tradeL.SellStop(posVolume, secPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "SellStop in halfprice added"))
                Print("Successfull SellStop1 added on the new price: " + secPrice);

            if (tradeL.OrderDelete(orderTicket))
                Print("Order:  " + orderTicket + " was closed ");

            if (tradeL.SellStop(posVolume, shiftedPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "SellStop after closing order added"))
                Print("Successfull SellStop2 added on the new price: " + shiftedPrice);
            else
                Print("secondStoploss on BUY failed");
        }

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
            double shiftedPrice = NormalizeDouble((orderPrice + posPrice) / 2, 0);

            if (tradeL.BuyStop(posVolume, secPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "BuyStop  in halfprice triggered"))
                Print("Successfull BuyStop1 added on the new price: " + secPrice);
            if (tradeL.OrderDelete(orderTicket))
                Print("Order:  " + orderTicket + " was closed ");
            if (tradeL.BuyStop(posVolume, shiftedPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "BuyStop after closing order added"))
                Print("Successfull BuyStop2 added on the new price: " + secPrice);
            else
                Print("secondStoploss on SELL failed");
        }
        else
            Print("secondStoploss failed. No type position detected");

        // TODO: check amount of orders

        Print("OrderGetTicket(0) ", OrderGetTicket(0));
        Print("OrderGetTicket(1) ", OrderGetTicket(1));
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
        Print("createObject: objName" + objName + " iconCode: " + iconCode + " clr: " + clr);
    }
    else
        Print("createObject went wrong!");
}