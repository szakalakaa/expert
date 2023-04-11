string getTmaSignal(double lastL, double TMAbands_downL, double TMAbands_upL, string type_positionL)
{
    if ((lastL < TMAbands_downL) && (type_positionL != "LONG"))
        return "buy";

    if ((lastL > TMAbands_upL) && (type_positionL != "SHORT"))
        return "sell";
    else
        return "";
}

void setFlags(bool &firstFlagL, bool &secondFlagL, bool &thirdFlagL, bool firstL, bool secondL, bool thirdL)
{
    firstFlagL = false;
    secondFlagL = false;
    thirdFlagL = false;

    if (!firstL && secondL)
        firstFlagL = true;
    if (!secondL)
    {
        firstFlagL = true;
        secondFlagL = true;
        thirdFlagL = true;
    }
    if (firstL && !secondL)
        firstFlagL = false;
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

    if (!MathMod(serverTime.min, 60) && serverTime.sec == 0)
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