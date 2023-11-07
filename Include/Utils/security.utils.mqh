bool accountGuardian(double InitialAccount, double &CurrentAccount, int InsureProcentOfAccount, double &CurrentBalance)
{
    CurrentAccount = AccountInfoDouble(ACCOUNT_BALANCE);

    CurrentBalance = NormalizeDouble(100 * CurrentAccount / InitialAccount, 2);

    if ((InitialAccount * InsureProcentOfAccount / 100) > CurrentAccount)
    {

        return false;
    }
    return true;
}