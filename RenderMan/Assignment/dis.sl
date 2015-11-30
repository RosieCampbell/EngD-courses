displacement dis()
{
float a;
	a = 0.1 * sin(2*PI*3*s) * sin(2*PI*3*t);
	if (a > 0.0)
		P += normalize(N) * a;
}
