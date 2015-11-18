//WATCH OUT - THIS IS OLD SCHOOL SL...

displacement doDisplace(float disp = 0.25; float atten = 0.5)
{
    point PP = transform ("shader", P);
    normal sN = normalize(ntransform("shader",N));
    float scale;
    float ret=evalparam("disp",scale);
    if(ret<0)
	scale=100;
    P = transform("shader","current",PP + sN*scale*atten);
    N = calculatenormal(P);
}
