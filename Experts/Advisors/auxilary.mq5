   // TODO
    //  if (securelPartAfterTMAMiddleFlag && !shiftStopLossFlag)
    //  {
    //      if (Symbol() == PositionGetSymbol(0))
    //      {
    //          double halfLowerPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_down[0]) / 2, 0);
    //          double halfUpperPrice = NormalizeDouble((TMAbands_middle[0] + TMAbands_up[0]) / 2, 0);

    //         if ((last > halfUpperPrice) && (type_position == "LONG"))
    //         {
    //             shiftStoplosses(NormalizeDouble(TMAbands_middle[0], 0), NormalizeDouble(TMAbands_down[0], 0), type_position, stoploss, trade);
    //             shiftStopLossFlag = true;
    //         }
    //         if ((last < halfLowerPrice) && (type_position == "SHORT"))
    //         {
    //             shiftStoplosses(NormalizeDouble(TMAbands_middle[0], 0), NormalizeDouble(TMAbands_up[0], 0), type_position, stoploss, trade);
    //             shiftStopLossFlag = true;
    //         }
    //     }
    // }




    // double K_period[]; // deklaracja tablicy przechowującej wartości  %K "szybkiej" ,okresu spowolnienia
    // double D_period[]; // deklaracja tablicy przechowującej wartości  %D "wolnej", okresowej średnia kroczącej
    // ArraySetAsSeries(K_period, true);
    // ArraySetAsSeries(D_period, true);
    // CopyBuffer(stoch_handle, 0, 0, 3, K_period);
    // CopyBuffer(stoch_handle, 1, 0, 3, D_period);

    //  // STOCH INDICATOR
    // if (bars != barsTotal)
    // {
    //     if ((K_period[0] < STOCH_down) && (D_period[0] < STOCH_down))
    //     {
    //         if ((K_period[0] > D_period[0]) && (K_period[1] < D_period[1]))
    //         {
    //             stochSignal = "BUY"; // jeżeli obie wartości K,D są poniżej bandy a nastepnie następuję przecięcie
    //             createObject(time, last, 168, clrYellow, "1");
    //         }
    //     }
    //     if ((K_period[0] > STOCH_up) && (D_period[0] > STOCH_up))
    //     {
    //         if ((K_period[0] < D_period[0]) && (K_period[1] > D_period[1]))
    //         {
    //             stochSignal = "SELL"; // jeżeli obie wartości K,D są powyżej bandy a nastepnie następuję przecięcie
    //             createObject(time, last, 234, clrGreen, "2");
    //         }
    //     }
    //     barsTotal = bars;
    // }