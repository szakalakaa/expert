bool TimerFunction(bool inputBool)
{
    static int timerStart = 0;
    
    if (inputBool)
    {
        if (timerStart == 0)
        {
            // Rozpocznij odliczanie czasu
            timerStart = GetTickCount();
        }
        
        int currentTime = GetTickCount();
        int elapsedMinutes = (currentTime - timerStart) / 60000;
        
        if (elapsedMinutes < 100)
        {
            return true;
        }
        else
        {
            // Po 100 minutach zakończ i zresetuj odliczanie
            timerStart = 0;
            return false;
        }
    }
    else
    {
        // Zeruj odliczanie i zwróć false
        timerStart = 0;
        return false;
    }
}