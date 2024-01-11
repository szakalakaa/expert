#include <Utils\global.variables.mqh>
#include <Utils\ordersUtils.mqh>

int coppyBuffersAndTick(int &Tma_handle, double &TMAbands_downL[], double &TMAbands_upL[],
                        MqlTick &Tick)
{

    if (!SymbolInfoTick(_Symbol, Tick))
    {
        Print("Failed to get tick");
        return false;
    }

    int values = CopyBuffer(Tma_handle, 3, 0, 2, TMAbands_downL) +
                 CopyBuffer(Tma_handle, 2, 0, 2, TMAbands_upL);

    if (values != 4)
    {
        Alert("Failed to get indicator values! ", values);
        return false;
    }

    return true;
}

void updateGlobal(GlobalStruct &Global, InitialStruct &I, double &TMA_down[], double &TMA_up[])
{
    Global.ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    Global.bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    Global.last = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Digits);
    Global.upperBand = NormalizeDouble(TMA_up[0], 0);
    Global.lowerBand = NormalizeDouble(TMA_down[0], 0);
    Global.sellStopPriceCross = NormalizeDouble(Global.bid * (1 - I.stoplossCross), 0);
    Global.buyStopPriceCross = NormalizeDouble(Global.ask * (1 + I.stoplossCross), 0);
    Global.sellStopPriceMain = NormalizeDouble(Global.bid * (1 - I.stoplossMain), 0);
    Global.buyStopPriceMain = NormalizeDouble(Global.ask * (1 + I.stoplossMain), 0);

    Global.isCrossOrder = isOrderWithComments(trade, crossOrders, type_position);
    Global.isMainOrder = isOrderWithComments(trade, mainOrders, type_position);
    Global.isMainAuxOrder = isOrderWithComments(trade, mainAuxOrders, type_position);
}

void updateInitial(InitialStruct &Initial, double Stoploss, double LotsCross,
                   double LotsMain, double LotsMainAux, bool ApplyCross, bool ApplyMain)
{
    Initial.applyCross = ApplyCross;
    Initial.applyMain = ApplyMain;

    Initial.stoplossCross = 1.5 * Stoploss;
    Initial.stoplossMain = Stoploss;

    Initial.lotsCross = LotsCross;

    Initial.lotsMain = LotsMain;
    Initial.lotsMainAux = LotsMainAux;

    Initial.crossMinutesToWait = 90;
    Initial.mainMinutesToWait = 60;

    Initial.offset = 2; // offset buy/sell  1 = 0.000 1%
    Initial.insureProcentOfAccount = 75;
}