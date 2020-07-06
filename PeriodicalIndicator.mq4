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

#include "Array.mqh"

// - - - - - - - - - - Globals - - - - - - - - - - - 
// ====================================================
datetime globLastDrawnLineTime; 
const string globPrefix = "marked@";
const double globHugeNumber   = 1e20;
// ====================================================


// - - - - - - - - -  Externals  - - - - - - - - - - - 
//=====================================================
extern int user_london_time_start = 23;
extern int user_minutes_in_period =240;
//=====================================================

// ===========================================
int init() 
// ===========================================
{   
   // current datetime as the number of seconds elapsed since January 01, 1970. 
   datetime timeCurrent = TimeCurrent(); // <- typically the time of the server
   // server time for the specific symbol (if index = 0 it iS typically same as TimeCurrent()
   datetime serverTime = iTime(Symbol(), PERIOD_M1, 0);
   // London time, now
   datetime localTime = TimeLocal(); 
   
   // return london time at H23:00 preceeding timeLocal
   datetime time_local_london_start = get_pastTime_at (localTime, 0, 0, user_london_time_start);

   // compute offset btw server time and londpn time
   int secondOffset = serverTime - localTime;
   
   // compute server time at londonTime_H24 preceeding timeLocal
   datetime time_server_london_start = time_local_london_start + secondOffset;
   
   // minutes from the 'selected' beginning (server time) until now
   int minutes_from_now = (serverTime - time_server_london_start) /60;
   
    
   // =========  
   // S T A R T 
   // =========
     
   int m = minutes_from_now;
   
   // Start spamming the past
    
   // from now, look back until it's h23:00 (for example) local time and record min/max so far
   while ( m > 0)
   {     
      /*
      datetime backwardDatetime  = iTime(Symbol(), kPeriod, m);
      MqlDateTime mql_backwardDatetime;
      TimeToStruct(backwardDatetime, mql_backwardDatetime);      
      */
      
      // get the price at t = now - m minutes  
      double price =  iOpen(Symbol(), PERIOD_M1, m);
      
      string line_name = globPrefix +  " ";
      
      drawTrendLine(line_name, price, indicator_color1, STYLE_SOLID);  
 
      m -= user_minutes_in_period;
   }
   
   globLastDrawnLineTime = iTime(Symbol(), PERIOD_M1, 0);
   
   WindowRedraw();  
	return(0);
}

// ===========================================
int deinit() 
// ===========================================
{

   for (int i = 0; i < 0; ++i)
   {
      // ObjectDelete(globHighLineName);
   }
   
   
   	
	WindowRedraw();  
	return(0);
}

//============================================
int start() 
// ===========================================
{

	int style = 1;
	
	datetime serverTime = iTime(Symbol(), PERIOD_M1, 0);
	
	int elapsedMinutes = (serverTime - globLastDrawnLineTime ) / 60;
	
	if (elapsedMinutes > user_minutes_in_period)
	{
	   double price = getLastMidPrice();
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



double getLastMidPrice()
{
   MqlTick latest_price;       
   SymbolInfoTick(Symbol() , latest_price); 
	double latest_mid =  (latest_price.bid + latest_price.ask ) /2.0;
	return latest_mid;
	
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