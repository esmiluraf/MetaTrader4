//#property indicator_buffers 3
#property strict // this allow to print datetime in string format
#property indicator_chart_window

#include "..\Include\WinUser32.mqh"
#include "..\Include\Arrays\ArrayString.mqh"
// - - - - - - - - - - Globals - - - - - - - - - - - 
// ====================================================
datetime     globLastDrawnLineTime; 
const string globPrefix = "marked@";
CArrayString globLineNames;
const double globHugeNumber   = 1e20;
const string globDynamicTrendLine = "dynamic_line_" + Symbol();
bool         globDynamicTrendLineActivated = true;
// ====================================================

// - - - - - - - - -  Externals  - - - - - - - - - - - 
//=====================================================
extern int user_london_time_start =  23;
extern int user_minutes_in_period = 240;

extern color indicator_color1 = Aqua;        // horizonal line
extern color indicator_color2 = Yellow;      // trend line static
extern color indicator_color3 = Red;         // trend line dynamic

extern int indicator_style1 = STYLE_DASH;    // horizonal line style 
extern int indicator_style2 = STYLE_SOLID;   // trend line static style
extern int indicator_style3 = STYLE_SOLID;   // trend line dynamic style

extern int indicator_width1 = 1;             // horizonal line width
extern int indicator_width2 = 1;             // trend line static width
extern int indicator_width3 = 1;             // trend line dynamic width

//=====================================================

// ===========================================
int init() 
// ===========================================
{   
   // current datetime as the number of seconds elapsed since January 01, 1970. 
   datetime timeCurrent = TimeCurrent(); // <- typically the time of the server
   
   // server time for the specific symbol (if index = 0 it iS typically same as TimeCurrent()
   datetime serverTimeNow = iTime(Symbol(), PERIOD_M1, 0);
   // London time, now
   datetime localTimeNow = TimeLocal(); 
   
   // return london time at H23:00 preceeding timeLocal
   datetime time_local_london_start = get_pastTime_at (localTimeNow, 0, 0, user_london_time_start);
  
   datetime time_server_london_start = local_to_server(time_local_london_start);
   
   // minutes from the 'selected' beginning (server time) until now
   int minutes_from_now = (int) (  (serverTimeNow - time_server_london_start) /60.0 );
   
    
   // =========  
   // S T A R T 
   // =========
     
   int m = minutes_from_now ;
    
   // from h23:00 (for example) move forward and record open price every <user_minutes_in_period>
   while ( m > 0)
   {           
      // get the price at t = now - m ( m are minutes)
      double price =  iClose(Symbol(), PERIOD_M1, m);
      
      // update server time (in seconds)
      datetime serverTime = serverTimeNow - m * 60; 
      
      drawAndRecordLine(serverTime, price);

      m -= user_minutes_in_period;
   }
   
   // this is the time the last line was drawn
   globLastDrawnLineTime = serverTimeNow - 60 * (m + user_minutes_in_period);
   
   int chart_ID=0;
   string name = "ActivateArrowButton";
   ObjectCreate(chart_ID, name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,110);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,38);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,"Arrow On/Off");
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,5);
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE, true);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR, indicator_color3);
   
   
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
   ObjectDelete(globDynamicTrendLine);
   
   ObjectDelete("ActivateArrowButton");
   
   globLineNames.Shutdown();
         	
	WindowRedraw();  
	return(0);
}

//============================================
int start() 
// ===========================================
{
	datetime serverTime = TimeCurrent();
	
	int elapsedMinutes = (int)((serverTime - globLastDrawnLineTime ) / 60.0 );
	
	if (elapsedMinutes > user_minutes_in_period)
	{
	   double price = iClose(Symbol(), PERIOD_CURRENT, 0);
   
	   drawAndRecordLine(serverTime, price);
	
	   // reset time
	   globLastDrawnLineTime = serverTime;
	}
	
	drawDynamicLine();
	
	WindowRedraw();  
	return(0);
}

void drawAndRecordLine(datetime server_time, double price)
{
   // give the line a unique name
   string horiz_name = "horiz_" + globPrefix + server_time;
   // draw the line
	drawHorizLine(horiz_name, price, indicator_color1, indicator_style1, indicator_width1);
	// add to the array of line objects
	globLineNames.Add(horiz_name);
		

   // give the line a unique name
   string trend_name = "trend_" + globPrefix + server_time;
	// draw the line
	drawTrendLine(trend_name, server_time, price, indicator_color2, indicator_style2, indicator_width2);		
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

void drawTrendLine(string object_name, const datetime& time, const double& price, color line_color, int line_style, int line_width) 
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

void drawDynamicLine() 
{
   if (!globDynamicTrendLineActivated)
   {
      return;
   }
   
   // this line must be dumped each time
	
	datetime t1 = iTime (Symbol(), PERIOD_CURRENT, 1); //must be server time
	double   p1 = iClose(Symbol(), PERIOD_CURRENT, 1);
	datetime t2 = TimeCurrent();                       //must be server time
	double   p2 = getLastMidPrice();
	
	int subwindow = 0;
	
   // delete the object that might be existing already
	ObjectDelete(globDynamicTrendLine);
	ObjectCreate(globDynamicTrendLine, OBJ_TREND, subwindow, t1,p1,t2,p2);
	ObjectSet   (globDynamicTrendLine, OBJPROP_COLOR, indicator_color3);
	ObjectSet   (globDynamicTrendLine, OBJPROP_STYLE, indicator_style3);
	ObjectSet   (globDynamicTrendLine, OBJPROP_WIDTH, indicator_width3);
	ObjectSet   (globDynamicTrendLine, 	OBJPROP_RAY_RIGHT, false);
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

datetime server_to_local(const datetime& server_time)
{  
   // compute server time at londonTime_H24 preceeding timeLocal
   return server_time - ( TimeCurrent() - TimeLocal());
}

datetime local_to_server(const datetime& local_time)
{   
   // compute server time at londonTime_H24 preceeding timeLocal
   return local_time + ( TimeCurrent() - TimeLocal());
}


void OnChartEvent(const int id,
                  const long & lparam,
                  const double &dparam,
                  const string &object_name) // <- object involved in the event
{
   
   int chart_ID = 0;   
   if(id == CHARTEVENT_OBJECT_CLICK)
   {     
      //--- If you click on the object with the name buttonID
      if(object_name == "ActivateArrowButton")
      {
         //--- State of the button - pressed or not
         bool selected = ObjectGetInteger(0, object_name, OBJPROP_STATE);
         
         if (selected)
         {
            if(globDynamicTrendLineActivated)
            {
               globDynamicTrendLineActivated = false;
               ObjectDelete(globDynamicTrendLine);              
            }
            else
               globDynamicTrendLineActivated = true;
         }
      }
   }       
}

