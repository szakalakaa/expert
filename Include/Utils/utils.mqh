
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

void getMagicFromOpenPosition(long &OpenPosMagic)
{
    if (PositionsTotal())
    {
        PositionGetTicket(0);

        if (!PositionGetInteger(POSITION_MAGIC, OpenPosMagic))
        {
            Print("Failed to get magic from open position ");
        }
    }
}

bool countOpenPositions(int &countBuy, int &conutSell)
{
    countBuy = 0;
    conutSell = 0;
    int inpMagicFake=5;
    int total = PositionsTotal();
    for (int i = total - 1; i >= 0; i--)
    {
        ulong positionTicket = PositionGetTicket(i);
        if (positionTicket <= 0)
        {
            Print("Failed to get ticket");
            return false;
        }
        if (!PositionSelectByTicket(positionTicket))
        {
            Print("Failed to select position");
            return false;
        }
        long magic;
        if (!PositionGetInteger(POSITION_MAGIC, magic))
        {
            Print("Failed to get magic ");
            return false;
        }
        if (magic == inpMagicFake)
        {
            long type;
            if (!PositionGetInteger(POSITION_TYPE, type))
            {
                Print("Failed to get type ");
                return false;
            }
            if (type == POSITION_TYPE_BUY)
            {
                countBuy++;
            }
            if (type == POSITION_TYPE_SELL)
            {
                conutSell++;
            }
        }
    }

    return true;
}

void printValues(string TMA_signalA, double lastA, double orderPriceA, double bandA, double candleClose, double offsetPriceA)
{
    if (TMA_signalA == "buy")
    {
        Print(" *TMA_signal: " + (string)TMA_signalA);
        Print("   last: " + (string)lastA);
        Print("   ask: " + (string)orderPriceA);
        Print("   TMAbands_down[0]: " + (string)bandA);
        Print("   candle[1].close: " + (string)candleClose);
        Print("   offsetForBuy: " + (string)offsetPriceA);
    }
    if (TMA_signalA == "sell")
    {
        Print(" *TMA_signal: " + (string)TMA_signalA);
        Print("   last: " + (string)lastA);
        Print("   bid: " + (string)orderPriceA);
        Print("   TMAbands_up[0]: " + (string)bandA);
        Print("   candle[1].close: " + (string)candleClose);
        Print("   offsetForSell: " + (string)offsetPriceA);
    }
}

bool checkInputs(double Stoploss, double StoplossCross, int Atr_period, double Atr_multiplier, double StochUpper, double kPeriod, double dPeriod)
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
    if (StochUpper > 90 || StochUpper < 10)
    {
        Alert("stochUpper > 90 || stochUpper < 10");
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
    return true;
}

void printTime()
{
    MqlDateTime t;
    TimeToStruct(iTime(_Symbol, PERIOD_M1, 0), t);
    t.hour = t.hour + 2;
    datetime time = StructToTime(t);
    Print("time: ", time);
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

string getTmaSignal(double lastL, double TMAbands_downL, double TMAbands_upL, string type_positionL)
{
    if ((lastL < TMAbands_downL) && (type_positionL != "LONG"))
        return "buy";

    if ((lastL > TMAbands_upL) && (type_positionL != "SHORT"))
        return "sell";
    else
        return "";
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

double getLots(double lastL, double levarL)
{
    double lotsTotal = NormalizeDouble((levarL * 0.95 * AccountInfoDouble(ACCOUNT_BALANCE) / lastL), 4);
    double lotsConverted = lotsTotal - NormalizeDouble(MathMod(lotsTotal, 0.0004), 4);
    return NormalizeDouble(lotsConverted, 4);
}

void crossBlockadeRelease(datetime stopLossTriggeredTimeL, bool &crossBlockadeFlagL, int crossBlockTimeL)
{

    if (stopLossTriggeredTimeL < TimeCurrent() - crossBlockTimeL * 60)
    {
        // Print("RESET TIME");
        stopLossTriggeredTimeL = NULL;
        crossBlockadeFlagL = false;
    }
}
