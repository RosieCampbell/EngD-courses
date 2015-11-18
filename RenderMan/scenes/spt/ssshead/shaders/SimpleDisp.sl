displacement 
SimpleDisp(float input = 0;
           float magnitude = 0;)
{
    vector unit = vector "object" (1,0,0);
    float scale = length(unit);
    float evalInput = input;
    float evalMag = magnitude;

    evalparam("input", evalInput);
    evalparam("magnitude", evalMag);

    evalInput = 2 * evalInput - 1;
    P += evalInput * evalMag * scale * normalize(N);
    N = calculatenormal(P);
}

