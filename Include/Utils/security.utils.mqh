bool accountGuardian(double InitialAccount, double &CurrentAccount, int InsureProcentOfAccount, double &CurrentBalance, bool &StopExpert)
{
    CurrentAccount = AccountInfoDouble(ACCOUNT_BALANCE);

    CurrentBalance = NormalizeDouble(100 * CurrentAccount / InitialAccount, 2);

    if ((InitialAccount * InsureProcentOfAccount / 100) > CurrentAccount)
    {
        Print("Saldo konta spadło " + (string)(100 - InsureProcentOfAccount) + " % od początku pracy expert advisora!!!");
        return false;
    }

    if (StopExpert)
    {
        return false;
    }
    return true;
}