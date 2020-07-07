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
const string globHighLineName = "globHighLineName";
const string globLowLineName  = "globLowLineName";
const double globHugeNumber   = 1e20;
// ====================================================


// - - - - - - - - -  Externals  - - - - - - - - - - - 
//=====================================================
extern int  londonTime_H24 = 23;
//=====================================================

struct LowHighPriceInfo
{
   LowHighPriceInfo() : 
            highest(-1.0),             // just a negative number
            lowest(globHugeNumber),    // just a very big number
            draw_highest(false),       
            draw_lowest(false)      
            {}
            
   double highest;
   double lowest;  
   bool draw_highest;
   bool draw_lowest;;
};

//====================================
LowHighPriceInfo globPrice; // global
//====================================


// ===========================================
int init() 
// ===========================================
{ 
   // we'll search backwards at this freqeuncy
   const int kPeriod = PERIOD_M1;
    
   // current datetime as the number of seconds elapsed since January 01, 1970. 
   datetime timeCurrent = TimeCurrent(); // <- typically the time of the server
   // server time for the specific symbol (if index = 0 it i typically same as TimeCurrent()
   datetime serverTime = iTime(Symbol(), kPeriod, 0);
   // London time, now
   datetime timeLocal = TimeLocal(); 
   // GMT Time, London - 1h 
   datetime timeGMT = TimeGMT();       // GMT Time, London - 1h
   
   // return london time at londonTime_H24 preceeding timeLocal
   datetime timeLocal_at_londonTime_H24 = get_pastTime_at (timeLocal, 0, 0, londonTime_H24);

   // compute offset btw server time and londpn time
   int secondOffset = serverTime - timeLocal;
   
   // compute server time at londonTime_H24 preceeding timeLocal
   datetime serverTime_at_londonTime_H24 = timeLocal_at_londonTime_H24 + secondOffset;
   
   
   
   // =========  
   // S T A R T 
   // =========
   
   //Initialize 
     
   datetime theTime = serverTime; 
     
   int periodIndex = 0;
   
   // Start spamming the past
    
   // from now, look back until it's h23:00 (for example) local time and record min/max so far
   while ( theTime > serverTime_at_londonTime_H24)
   {     
     // get the server time at t = now - kPeriod * periodIndex      
      datetime backwardDatetime  = iTime(Symbol(), kPeriod, periodIndex);
      MqlDateTime mql_backwardDatetime;
      TimeToStruct(backwardDatetime, mql_backwardDatetime);
        
      
      // get the highes price of the candle backwards at t = now - kPeriod * periodIndex  
      double last_high_price =  iHigh(Symbol(), kPeriod, periodIndex);
      if (last_high_price > globPrice.highest)
      {
         globPrice.highest = last_high_price;
      }
      
       // get the lowes price of the candle backwards at t = now - kPeriod * periodIndex  
      double last_low_price =  iLow(Symbol(), kPeriod, periodIndex);
      if (last_low_price < globPrice.lowest)
      {
         globPrice.lowest = last_low_price;
      }
      periodIndex++;
      theTime = addMinutes(theTime, -1);
   }
   
   drawTrendLine(globHighLineName, globPrice.highest, indicator_color1, STYLE_SOLID);   
   drawTrendLine(globLowLineName,  globPrice.lowest,  indicator_color4, STYLE_SOLID);   
	WindowRedraw();  
   
	return(0);
}

// ===========================================
int deinit() 
// ===========================================
{

   ObjectDelete(globHighLineName);
   ObjectDelete(globLowLineName);
   	
	WindowRedraw();  
	return(0);
}

//============================================
int start() 
// ===========================================
{
	updateLowHighPrice();
	
	if (globPrice.draw_highest)
	{
	   const static string object_name_high = "high_price_hline"; 
	   moveHLine(globHighLineName, globPrice.highest); 
	   //drawTrendLine(object_name_high, price_info.highest, indicator_color1, STYLE_SOLID);   
	}
	
	if (globPrice.draw_lowest)
	{
	   const  static string object_name_low = "low_price_hline";  
	   moveHLine(globLowLineName, globPrice.lowest); 
	   //drawTrendLine(object_name_low, price_info.lowest, indicator_color4, STYLE_SOLID);  
	}
	
	WindowRedraw();  
	return(0);
}


void drawTrendLine(string object_name, double price, color line_color, int line_style) 
{
	ObjectDelete(object_name);
	int subwindow = 0;
	ObjectCreate(object_name, OBJ_HLINE, subwindow, Time[0], price);
	ObjectSet(object_name, OBJPROP_COLOR, line_color);
	ObjectSet(object_name, OBJPROP_STYLE, line_style);
	ObjectSet(object_name, OBJPROP_WIDTH, indicator_width1);
}


bool  moveHLine(string object_name, double price)
{
// an horizonal line ha only one anchor index
   int anchor_index = 0;
   return ObjectMove(object_name, anchor_index, Time[0], price);   
}



double getLastPrice()
{
   MqlTick latest_price;       
   SymbolInfoTick(Symbol() , latest_price); 
	double latest_mid =  (latest_price.bid + latest_price.ask ) /2.0;
	return latest_mid;
	
 }

/***********************************************************
update Lowest and Highest prices
************************************************************/
void updateLowHighPrice()
{
   double latestPrice = getLastPrice();
   globPrice.draw_highest = false;
   globPrice.draw_lowest  = false;   

   if (latestPrice > globPrice.highest)
   {
      globPrice.highest = latestPrice;
      globPrice.draw_highest = true;
   }
   
   
   if (latestPrice < globPrice.lowest)
   {
      globPrice.lowest = latestPrice;
      globPrice.draw_lowest = true;
   }  
 }
 
 


datetime addPeriod(const datetime& t, const int p, int PERIOD)
{
   switch (PERIOD)
   {
      case PERIOD_M1:
      return addMinutes(t, p);
      break;
   
      case PERIOD_H1:
      return addHours(t, p);
      break;
   
      case PERIOD_D1:
      return addHours(t, p * 24);
      break;
   
      case PERIOD_M5:
      return addMinutes(t, p * 5);
      break;
      
      default:
      Print ("Error in addPeriod");
      return 1;
   }
   
}

datetime addHours(const datetime& time, const int h)
{
   return time + h * 3600;
}

datetime addMinutes(const datetime& time, const int m)
{
   return time + m * 60;
}

datetime addSeconds(const datetime& time, const int s)
{
   return time + s;
}

/*****************************************************************
// Return datetime at of the hh:mm:ss preceeding time 
// For example:
// time = D'2020.07.04 18:53:22 and hh=20,mm=30, s=0,
// then, return time = D'2020.07.03 20:30:00
*****************************************************************/
datetime get_pastTime_at(datetime time, int ss, int mm, int hh)
{
   MqlDateTime mql_time;
   TimeToStruct(time, mql_time);
   
   mql_time.hour   = hh;
   mql_time.min = mm;
   mql_time.sec = ss;
   
   datetime temp = StructToTime(mql_time); 
   return temp > time ? temp - 24 * 3600 : temp;
 
}