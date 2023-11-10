int coppyBuffersAndTick(int &Tma_handle, double &TMAbands_downL[], double &TMAbands_upL[],
                        int &Stoch_handle, double &K_periodL[], double &D_periodL[],
                        MqlTick &Tick)
{

    if (!SymbolInfoTick(_Symbol, Tick))
    {
        Print("Failed to get tick");
        return false;
    }

    int values = CopyBuffer(Tma_handle, 3, 0, 2, TMAbands_downL) +
                 CopyBuffer(Tma_handle, 2, 0, 2, TMAbands_upL) +
                 CopyBuffer(Stoch_handle, 0, 0, 3, K_periodL) +
                 CopyBuffer(Stoch_handle, 1, 0, 3, D_periodL);

    if (values != 10)
    {
        Alert("Failed to get indicator values! ", values);
        return false;
    }

    return true;
}