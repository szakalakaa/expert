bool accountGuardian(double InitialAccount, double &CurrentAccount, int InsureProcentOfAccount, double &CurrentBalance)
{
    CurrentAccount = AccountInfoDouble(ACCOUNT_BALANCE);

    CurrentBalance = 100*CurrentAccount / InitialAccount;

    if ((InitialAccount * InsureProcentOfAccount / 100) > CurrentAccount)
    {

        return false;
    }
    return true;
}