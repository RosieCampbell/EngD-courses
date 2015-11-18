
displacement
disp(float disp = 0.25; float atten = 0.5)
{
    point PP = transform ("shader", P);
    normal sN = normalize(ntransform("shader",N));
    float scale;
    evalparam("disp",scale);
    P = transform("shader","current",PP + sN*scale*atten);
    N = calculatenormal(P);
}
