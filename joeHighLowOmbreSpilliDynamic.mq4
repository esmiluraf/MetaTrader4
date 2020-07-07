#property indicator_buffers 10
#property indicator_chart_window

#property indicator_color1 Green
#property indicator_color2 Gold
#property indicator_color3 DarkOrange
#property indicator_color4 Red
#property indicator_color5 FireBrick

#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_SOLID

#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 3

// - - - - - - - - - - Globals - - - - - - - - - - - 
// ====================================================
const string globSpilloHighLineName = "SpilloHigh";
const string globSpilloLowLineName  = "SpilloLow";
const string globCorpoHighLineName  = "CorpoHigh";
const string globCorpoLowLineName   = "CorpoLow";
const double globHugeNumber         = 1e20;
// ====================================================


// - - - - - - - - -  Externals  - - - - - - - - - - - 
//=====================================================
extern int candles = 5;
//=====================================================

struct LowHighPriceCandle
{
   // constructor
   // =====================================================================
   LowHighPriceCandle(int PERIOD): 
   // =====================================================================
   mySpilloHigh(-1.0), mySpilloLow(globHugeNumber), myCorpoHigh(-1.0), myCorpoLow(globHugeNumber)
   {
      update(PERIOD);
   }
   
   // update
   // =====================================================================
   void update(int PERIOD)
   // =====================================================================
   {
      for (int i = 0; i < candles; ++i)
      {
         double iH = iHigh(Symbol(),  PERIOD, i);
         double iL = iLow (Symbol(),  PERIOD, i);        
         mySpilloHigh = max(mySpilloHigh, iH );
         mySpilloLow  = min(mySpilloLow,  iL );
           
         double corpoHigh  = iOpen(Symbol(),  PERIOD, i);
         double corpoLow   = iClose(Symbol(), PERIOD, i);
         if ( corpoHigh < corpoLow)
         {
            swap(corpoHigh, corpoLow);
         } 
         myCorpoHigh = max(myCorpoHigh, corpoHigh); 
         myCorpoLow  = min(myCorpoLow, corpoLow); 
       }
   }
   
   // swap
   // =====================================================================
   void swap (double& x, double& y) const {double u=x; x=y; y=u;}
   // =====================================================================
   
   // =====================================================================
   double max(const double&x , const double& y)  const {return x>y?x:y;}
   // =====================================================================
   
   // =====================================================================
   double min(const double&x , const double& y)  const {return x<y?x:y;}
   // =====================================================================
            
   double myCorpoHigh;
   double myCorpoLow;  
   double mySpilloHigh;
   double mySpilloLow; 
};

// ===========================================
int init() 
// ===========================================
{ 
   // get the period from the selected chart
   const int kPeriod = PERIOD_CURRENT;
    
   // =========  
   // S T A R T 
   // ========= 
     
   LowHighPriceCandle myPrice(kPeriod);
   
   drawTrendLine(globSpilloHighLineName, myPrice.mySpilloHigh, indicator_color1, STYLE_SOLID);   
   drawTrendLine(globSpilloLowLineName,  myPrice.mySpilloLow,  indicator_color2, STYLE_SOLID);
   drawTrendLine(globCorpoHighLineName, myPrice.myCorpoHigh, indicator_color3, STYLE_SOLID);   
   drawTrendLine(globCorpoLowLineName,  myPrice.myCorpoLow,  indicator_color4, STYLE_SOLID);  
    
	WindowRedraw();  
	return(0);
}

// ===========================================
int deinit() 
// ===========================================
{
   ObjectDelete(globSpilloHighLineName);
   ObjectDelete(globSpilloLowLineName);
   ObjectDelete(globCorpoHighLineName);
   ObjectDelete(globCorpoLowLineName);
     	
	WindowRedraw();  
	return(0);
}

//============================================
int start() 
// ===========================================
{
	deinit();
	init();
	return 0;
}


//============================================
void drawTrendLine(string object_name, double price, color line_color, int line_style) 
//============================================
{
	ObjectDelete(object_name);
	int subwindow = 0;
	ObjectCreate(object_name, OBJ_HLINE, subwindow, Time[0], price);
	ObjectSet(object_name, OBJPROP_COLOR, line_color);
	ObjectSet(object_name, OBJPROP_STYLE, line_style);
	ObjectSet(object_name, OBJPROP_WIDTH, indicator_width1);
}





