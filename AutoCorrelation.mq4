#property version "1.0"
#property copyright "Copyright ? 2015, Quantrade Corp."
#property link      "http: //www.talaikis.com"

#property indicator_separate_window

#property indicator_buffers 6
#property indicator_color1 clrNONE
#property indicator_color2 clrNONE
#property indicator_color3 clrNONE
#property indicator_color4 clrNONE
#property indicator_color5 clrNONE
#property indicator_color6 clrGray

#property indicator_level1     0.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT

extern int    per     = 21;
extern int    lag     = 1;
extern string symbol1 = "S&P500";

double X[];
double Y[];
double corr[];
double xy[];
double xSq[];
double ySq[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{
//---- indicators
    SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 2);

    SetIndexBuffer(0, X);
    SetIndexBuffer(1, Y);
    SetIndexBuffer(2, xy);
    SetIndexBuffer(3, xSq);
    SetIndexBuffer(4, ySq);
    SetIndexBuffer(5, corr);

    IndicatorSetDouble(INDICATOR_MINIMUM, -1);
    IndicatorSetDouble(INDICATOR_MAXIMUM, 1);

//----
    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----

//----
    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
    int bars = Bars - 1;
    int i;

    if (Refresh() == TRUE)
    {
        //-------------- DATA
        for (i = bars; i >= 0; i--)
        {
            if (iClose(symbol1, 0, i + 1) != 0)
            {
                X[i] = (iClose(symbol1, 0, i) - iClose(symbol1, 0, i + 1)) / iClose(symbol1, 0, i + 1);
            }

            if (iClose(symbol1, 0, i + 1 + lag) != 0)
            {
                Y[i] = (iClose(symbol1, 0, i + lag) - iClose(symbol1, 0, i + 1 + lag)) / iClose(symbol1, 0, i + 1 + lag);
            }
        }

        //-------------- <a href="http://www.talaikis.com/autocorrelation/">AUTOCORRELATION</a>
        for (i = bars; i >= 0; i--)
        {
            xy[i]  = X[i] * Y[i];
            xSq[i] = X[i] * X[i];
            ySq[i] = Y[i] * Y[i];
        }

        for (i = bars; i >= 0; i--)
        {
            double _var = MathSqrt((per * SUM(xSq, per, i) - SUM(X, per, i) * SUM(X, per, i))) * MathSqrt((per * SUM(ySq, per, i) - SUM(Y, per, i) * SUM(Y, per, i)));

            if (_var != 0)
            {
                corr[i] = (per * SUM(xy, per, i) - SUM(X, per, i) * SUM(Y, per, i)) / _var;
            }
            else
            {
                corr[i] = 0;
            }
        }
    }
//----
    return(0);
}
//+------------------------------------------------------------------+

//sum
double SUM(double array[], int per, int bar)
{
    double Sum = 0;

    for (int i = per; i >= 0; i--)
    {
        Sum += array[i + bar];
    }

    return(Sum);
}

//update base only once a bar
bool Refresh()
{
    static datetime PrevBar;

    if (PrevBar != iTime(NULL, Period(), 0))
    {
        PrevBar = iTime(NULL, Period(), 0);
        return(true);
    }
    else
    {
        return(false);
    }
}