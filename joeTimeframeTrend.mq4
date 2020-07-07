#property indicator_buffers 2
#property strict // this allow to print datetime in string format
#property indicator_chart_window

#property indicator_color1 Red
#property indicator_color2 Green

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID

#property indicator_width1 2
#property indicator_width2 2


#include "..\Include\WinUser32.mqh"
#include "..\Include\Arrays\ArrayString.mqh"
// - - - - - - - - - - Globals - - - - - - - - - - - 
// ====================================================
datetime     globLastDrawnLineTime; 
const string globPrefix = "marked@";
CArrayString globLineNames;
const double globHugeNumber   = 1e20;
// ====================================================

// - - - - - - - - -  Externals  - - - - - - - - - - - 
//=====================================================
extern int user_london_time_start =  23;
extern int user_minutes_in_period = 240;
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
   int secondOffset = (int) serverTime - (int) localTime;
   
   // compute server time at londonTime_H24 preceeding timeLocal
   datetime time_server_london_start = time_local_london_start + secondOffset;
   
   // minutes from the 'selected' beginning (server time) until now
   int minutes_from_now = (int) ( (serverTime - time_server_london_start) /60.0 );
   
    
   // =========  
   // S T A R T 
   // =========
     
   int m = minutes_from_now;
    
   // from h23:00 (for example) move forward and record open price every <user_minutes_in_period>
   while ( m > 0)
   {           
      // get the price at t = now - m ( m are minutes)
      double price =  iOpen(Symbol(), PERIOD_M1, m);
      
      datetime timeLocal = localTime - m * 60; 
      
      drawAndRecordLine(timeLocal, price);

      m -= user_minutes_in_period;
   }
   
   // this is the time the last line was drawn
   globLastDrawnLineTime = m*60 + iTime(Symbol(), PERIOD_M1, 0);
   
   WindowRedraw();  
	return(0);
}

// ===========================================
int deinit() 
// ===========================================
{
   int n = globLineNames.Total();
   for (int i = 0; i < n; ++i)
   {
      ObjectDelete(globLineNames[i]);
   }
   globLineNames.Shutdown();
         	
	WindowRedraw();  
	return(0);
}

//============================================
int start() 
// ===========================================
{
	datetime serverTime = iTime(Symbol(), PERIOD_M1, 0);
	
	int elapsedMinutes = (int)((serverTime - globLastDrawnLineTime ) / 60.0 );
	
	if (elapsedMinutes > user_minutes_in_period)
	{
	   double price = getLastMidPrice();
	   
	   // get th elocal (London) time
      datetime timeLocal = TimeLocal();
   
	   drawAndRecordLine(timeLocal, price);
	
	   // reset time
	   globLastDrawnLineTime = serverTime;
	}
	
	WindowRedraw();  
	return(0);
}

void drawAndRecordLine(datetime time, double price)
{
   // give the line a unique name
   string horiz_name = "horiz_" + globPrefix + time;
   // draw the line
	drawHorizLine(horiz_name, price, indicator_color1, indicator_style1, indicator_width1);
	// add to the array of line objects
	globLineNames.Add(horiz_name);
		

   // give the line a unique name
   string trend_name = "trend_" + globPrefix + time;
	// draw the line
	drawTrendLine(trend_name, time, price, indicator_color2, indicator_style2, indicator_width2);		
	// add to the array of line objects
	globLineNames.Add(trend_name);
}

void drawHorizLine(string object_name, double price, color line_color, int line_style, int line_width) 
{
	int subwindow = 0;
   // delete the object that might be existing already
	ObjectDelete(object_name);

	ObjectCreate(object_name, OBJ_HLINE, subwindow, Time[0], price);
	
	ObjectSet   (object_name, OBJPROP_COLOR, line_color);
	ObjectSet   (object_name, OBJPROP_STYLE, line_style);
	ObjectSet   (object_name, OBJPROP_WIDTH, line_width);
}

void drawTrendLine(string object_name, datetime time, double price, color line_color, int line_style, int line_width) 
{
	int subwindow = 0;
	
   static datetime static_time  = time;
   static double   static_price = price;
   
   // delete the object that might be existing already
	ObjectDelete(object_name);

	ObjectCreate(object_name, OBJ_TREND, subwindow, static_time, static_price, time, price);
	
	ObjectSet   (object_name, OBJPROP_COLOR, line_color);
	ObjectSet   (object_name, OBJPROP_STYLE, line_style);
	ObjectSet   (object_name, OBJPROP_WIDTH, line_width);
	ObjectSet   (object_name, 	OBJPROP_RAY_RIGHT, false);
	
	// recorde last time, price
	static_time  = time;
   static_price = price;
	
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