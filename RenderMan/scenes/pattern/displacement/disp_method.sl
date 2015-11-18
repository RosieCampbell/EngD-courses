class
disp_method(float disp = 0.25; float atten = 0.5)
{
    public void displacement(output point P; output normal N)
    {
        point PP = transform ("shader", P);
        normal sN = normalize(ntransform("shader",N));
        float scale;
        evalparam("disp",scale);
        P = transform("shader","current",PP + sN*scale*atten);
        N = calculatenormal(P);
    }

    public void lighting(output color Ci, Oi)
    {
        Ci = 1.0;
        Oi = 1.0;
    }
}
