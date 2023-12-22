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

bool checkInputs(double Stoploss, double StoplossCross, double StoplossStoch, int Atr_period, double Atr_multiplier,
                 double StochUpper, double kPeriod,
                 double dPeriod, int InsureProcentOfAccount)
{

    if (Stoploss <= 0 || Stoploss > 0.04)
    {
        Alert("stoploss <= 0 || stoploss > 0.04");
        return false;
    }
    if (StoplossCross <= 0 || StoplossCross > 0.04)
    {
        Alert("stoplossCross <= 0 || stoplossCross > 0.04");
        return false;
    }
    if (StoplossStoch <= 0 || StoplossStoch > 0.04)
    {
        Alert("StoplossStoch <= 0 || StoplossStoch > 0.04");
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
    if (StochUpper > 95 || StochUpper < 5)
    {
        Alert("stochUpper > 95 || stochUpper < 5");
        return false;
    }
    if (kPeriod > 25 || kPeriod < 2)
    {
        Alert("kPeriod > 25 || kPeriod < 2");
        return false;
    }
    if (dPeriod > 25 || dPeriod < 2)
    {
        Alert("dPeriod > 25 || dPeriod < 2");
        return false;
    }
    if (InsureProcentOfAccount < 50 || InsureProcentOfAccount > 99)
    {
        Alert("InsureProcentOfAccount>50 || InsureProcentOfAccount<99");
        return false;
    }
    return true;
}

bool NormalizePrice(double price, double &normalizedPrice)
{
    double tickSize = 0;
    if (!SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE, tickSize))
    {
        Print("61 Failed to get ticksize");
        return false;
    }
    normalizedPrice = NormalizeDouble(MathRound(price / tickSize) * tickSize, _Digits);
    return true;
}

// check if we have a bar open tick
bool shouldProcess(ENUM_TIMEFRAMES ProcessPeriod)
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

    // BUY
    // SellComment[3] BuyComment[5]   => main
    // SellComment[2] BuyComment[0]   => cross
    trade.SellStop(Lots, sellStopPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, SellComment[2]);
    trade.Buy(Lots, NULL, Ask, 0, 0, BuyComment[0]);
}
