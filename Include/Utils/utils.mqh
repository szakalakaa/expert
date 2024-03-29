#include <Utils\global.variables.mqh>

void fillOrdersTable(string &SellComment[], string &BuyComment[])
{
    SellComment[0] = "cross sell";
    SellComment[1] = "cross sell";
    SellComment[2] = "cross sell stop loss ";
    SellComment[3] = "main sell SL ";
    SellComment[4] = "close cross sell";
    SellComment[5] = "main sell";
    SellComment[6] = "main aux sell stop ";

    BuyComment[0] = "cross buy";
    BuyComment[1] = "cross buy"; // additional
    BuyComment[2] = "cross buy stop loss ";
    BuyComment[3] = "main buy SL ";
    BuyComment[4] = "close cross buy";
    BuyComment[5] = "main buy";
    BuyComment[6] = "main aux buy stop ";
}

void fillCommentsTable(
    string &tableOrderToUpdate[],
    string BuyComment,
    string SellComment,
    double &StopLossPercentageTable[])
{
    tableOrderToUpdate[0] = BuyComment;
    tableOrderToUpdate[1] = SellComment;

    tableOrderToUpdate[2] = BuyComment + (string)StopLossPercentageTable[0];
    tableOrderToUpdate[3] = BuyComment + (string)StopLossPercentageTable[1];
    tableOrderToUpdate[4] = BuyComment + (string)StopLossPercentageTable[2];
    tableOrderToUpdate[5] = BuyComment + (string)StopLossPercentageTable[3];

    tableOrderToUpdate[6] = SellComment + (string)StopLossPercentageTable[0];
    tableOrderToUpdate[7] = SellComment + (string)StopLossPercentageTable[1];
    tableOrderToUpdate[8] = SellComment + (string)StopLossPercentageTable[2];
    tableOrderToUpdate[9] = SellComment + (string)StopLossPercentageTable[3];
}

//
//
void getTypePosition(string &Type_position, double &LotsInPosition, double &PositionOpenPrice)
{
    if (PositionsTotal())
    {
        PositionGetSymbol(0);
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            Type_position = "LONG";
        }
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
            Type_position = "SHORT";
        }
        LotsInPosition = NormalizeDouble(PositionGetDouble(POSITION_VOLUME), 4);
        PositionOpenPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN), 0);
    }
    else
    {
        Type_position = "NO POSITION";
        LotsInPosition = 0;
        PositionOpenPrice = 0;
    }
}

bool checkInputs(InitialStruct &I, int Atr_period, double Atr_multiplier)
{

    if (I.stoplossMain <= 0 || I.stoplossMain > 0.04)
    {
        Alert("stoplossMain <= 0 || stoplossMain > 0.04");
        return false;
    }
    if (I.stoplossCross <= 0 || I.stoplossCross > 0.05)
    {
        Alert("stoplossCross <= 0 || stoplossCross > 0.05");
        return false;
    }
    if (Atr_period > 300 || Atr_period < 100)
    {
        Alert("atr_period > 300 || atr_period < 100");
        return false;
    }
    if (Atr_multiplier > 3 || Atr_multiplier < 0.5)
    {
        Alert("atr_multiplier > 3 || atr_multiplier < 0.5");
        return false;
    }

    if (I.insureProcentOfAccount < 50 || I.insureProcentOfAccount > 99)
    {
        Alert("InsureProcentOfAccount>50 || InsureProcentOfAccount<99");
        return false;
    }
    return true;
}

// check if we have a bar open tick
bool shouldProcess2(ENUM_TIMEFRAMES ProcessPeriod)
{
    if ((ProcessPeriod == PERIOD_M2) ||
        (ProcessPeriod == PERIOD_M4) ||
        (ProcessPeriod == PERIOD_M6) ||
        (ProcessPeriod == PERIOD_M10) ||
        (ProcessPeriod == PERIOD_M12))
        return false;

    static datetime prevTime = 0;
    datetime currentTime = iTime(_Symbol, ProcessPeriod, 0);

    if (prevTime != currentTime)
    {
        prevTime = currentTime;
        return true;
    }
    return false;
}

bool shouldProcess()
{
    int interfalInSecond = 5;
    MqlDateTime mqlTime;
    TimeToStruct(TimeCurrent(), mqlTime);

    if (!MathMod(mqlTime.sec, interfalInSecond))
    {
        return true;
    }
    return false;
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

bool getIsBetweenBands(double Price, double Lower, double Upper)
{
    if (Price <= Upper && Price >= Lower)
        return true;
    else
        return false;
}

void orderOnInit(CTrade &tradeL, double Lots, double StopLoss, string &SellComment[], string &BuyComment[])
{
    double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);

    double sellStopPrice = NormalizeDouble(Bid * (1 - StopLoss), 0);
    double buyStopPrice = NormalizeDouble(Ask * (1 + StopLoss), 0);

    // BUY MAIN
    // trade.SellStop(Lots, sellStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, SellComment[3]);
    // trade.Buy(Lots, NULL, Ask, 0, 0, BuyComment[5]);

    // BUY CROSS
    // trade.SellStop(Lots, sellStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, SellComment[2]);
    // trade.Buy(Lots, NULL, Ask, 0, 0, BuyComment[0]);

    // SELL CROSS
    // trade.Sell(Lots, NULL, Bid, 0, 0, SellComment[0]);
    // trade.BuyStop(Lots, buyStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, BuyComment[2]);

    // SELL MAIN
    // trade.Sell(Lots, NULL, Bid, 0, 0, SellComment[5]);
    // trade.BuyStop(Lots, buyStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, BuyComment[3]);
}

double getPercentageProfit(string Type_Position)
{
    if (PositionGetInteger(POSITION_TICKET) > 0)
    {
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
        double percentProfit = NormalizeDouble((((currentPrice - openPrice) / openPrice) * 100), 2);

        if (Type_Position == "SHORT")
        {
            percentProfit = -percentProfit;
        }

        return percentProfit;
    }

    return -999;
}
