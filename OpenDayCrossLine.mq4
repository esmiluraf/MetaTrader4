
#property indicator_chart_window

#property indicator_color1 Green
#property indicator_color2 Gold
#property indicator_color3 DarkOrange
#property indicator_color4 Red
#property indicator_color5 FireBrick

#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID

#property indicator_width3 2


#define PERIODS_NUMBER   5
#define INDICATOR_NAME   "Open Price Cross Line"
#define OPEN_CROSS_LINE  "Today Open Price "

int timeframes[PERIODS_NUMBER] = {PERIOD_H1,        PERIOD_H4,        PERIOD_D1,        PERIOD_W1,        PERIOD_MN1};
int styles[PERIODS_NUMBER] =     {indicator_style1, indicator_style2, indicator_style3, indicator_style4, indicator_style5};
color colors[PERIODS_NUMBER] =   {indicator_color1, indicator_color2, indicator_color3, indicator_color4, indicator_color5};


extern int  pips = 0;
extern int  gmtTime_h24 = 0;


// **************************************
// open price today at the gmtTime_h24
double openToday;
bool suppressThisIndicator = false;
const double delta_pips = (double) pips / 10000.;
const string obj_name = "my_text";
ulong  microsecondsStart = GetMicrosecondCount();
// **************************************


int init() {  
   MqlDateTime local_time;
	TimeToStruct(TimeLocal(), local_time);
	int local_hour = local_time.hour;

	// not reliaable on Saturday (6) and Sundat (0)
	if (local_time.day_of_week == 0 || local_time.day_of_week == 6)
	{   
	   pop_up_text("On weekends this indicator isn't working");
	   suppressThisIndicator = true;
	   return (0);
	}
	// not reliable on Monday if time is before the gmtTime_h24
	else if (local_time.day_of_week == 1 && gmtTime_h24 > local_time.hour)
	{
      pop_up_text("On Monday this indicator is working only after h:" + IntegerToString(gmtTime_h24) + ":00");   	   
	   suppressThisIndicator = true;
	   return (0);
	}
	
   suppressThisIndicator = false;
   openToday = getOpenPrice();
	return(0);
}

int deinit() {

   if (suppressThisIndicator)
   return (0);

	string object_types = OPEN_CROSS_LINE;
	ObjectDelete(getTrendLineName(object_types, timeframes[0]));
   ObjectDelete(obj_name);	
	return(0);
}

int start() {

   ulong newMicroSec = GetMicrosecondCount();
   if (newMicroSec - microsecondsStart > 2000000 )
   {
      // delete the text
      ObjectDelete(obj_name);	
      WindowRedraw();
      microsecondsStart = GetMicrosecondCount();
   }
   
   // do not proceed futhre if suppressThisIndicator is true
   if (suppressThisIndicator)
   {
      return (0);  
   }

   
	int style = 1;
	openToday = getOpenPrice();
	
	// delete the line (pips or gmtTime_h24 could have changed)
	deinit();
	drawTrendLine(getTrendLineName(OPEN_CROSS_LINE, timeframes[0]), openToday, colors[style], styles[style]);
	
	static double lastPrice = iClose(Symbol(), PERIOD_M1, 0);
	
	MqlTick latest_price = getLastPrice();
	double latest_mid =  (latest_price.bid + latest_price.ask ) /2.0;
	
	static double last_mid = latest_mid;
	
   string str_price = DoubleToString(latest_mid, 4);
     
   double openTodayUp   = openToday + delta_pips;  
   double openTodayDown = openToday - delta_pips;
   
	if (latest_mid > openTodayUp && last_mid < openTodayUp)
	{   
	   push_notify(true ,false, true, str_price, false);
	   last_mid = latest_mid;
   }
   else
   if (latest_mid < openTodayDown && lastPrice > openTodayDown)
   {
 	   push_notify(true ,false, true, str_price, false);
	   last_mid = latest_mid;
	}  
	  
	return(0);
}


void drawCrossLine(int bar_index, int timeframe_index) 
{
	if(bar_index > 0) 
	drawTrendLine(getTrendLineName(OPEN_CROSS_LINE, timeframes[0]), Open[0], colors[0], styles[0]);
}


void drawTrendLine(string object_name, double price, color line_color, int line_style) {
	ObjectDelete(object_name);
	ObjectCreate(object_name, OBJ_HLINE, 0, Time[0], price, Time[Bars - 1], price);
	ObjectSet(object_name, OBJPROP_COLOR, line_color);
	ObjectSet(object_name, OBJPROP_STYLE, line_style);
	ObjectSet(object_name, OBJPROP_WIDTH, indicator_width3);
}

string getTrendLineName(string object_type, int timeframe) {
	return(object_type);
}



double getOpenPrice()
{
   /* 
	The server is located in Malta fucking bastard, 
	i.e. somewhere at +2h wrt to GMT.
	Therefore subtract 2 hours from the time retuen by hours
	e.g. if Hour() = 01am, it means in London is 23
	*/

	MqlDateTime local_time;
	TimeToStruct(TimeLocal(), local_time);
	int local_hour = local_time.hour;
	
	/*
	we need the price today at gmtTime_h24
	It means we need to look back at gmt_hour - gmtTime_h24 in the 1H bar period
	*/
	
	int index = local_hour - gmtTime_h24;
	
	// if index is negative, them look at the yesterday price
	// e.g. if gmt_hour = 14 and gmtTime_h24 = 15, look back 25 hours
	index = index > 0 ? index : 24 - index;
 
   return iOpen(Symbol(), PERIOD_H1, index);
}


datetime notifyTag=0;
//+-------------------------------------------------------------------------+
//  Notify (the isNotifyOncePerCandle = true means that the message pops up 
//  only once every minute in the M1 chart or every hour in the H1 chart  etc...                                             |
//+-------------------------------------------------------------------------+
void push_notify(bool isAlert,bool isPush, bool isPrint, string price_string, bool isNotifyOncePerCandle)
  {
   
   string msg = "Price " + price_string + " has crossed the Open Day Level +/- " + IntegerToString(pips);
   string msgDetail=Symbol()+ " " +(string)Period() + " mins: " + msg;

   if(!isNotifyOncePerCandle)
     {
      if(isAlert) Alert(msgDetail);
      if(isPush)  SendNotification(msgDetail);
      if(isPrint) Print(msgDetail);
     }
   else
     {
      if(notifyTag!=Time[0])
        {
         if(isAlert) Alert(msgDetail);
         if(isPush)  SendNotification(msgDetail);
         if(isPrint) Print(msgDetail);

         notifyTag=Time[0];
        }
     }
  }
  
MqlTick getLastPrice()
{

   // To be used for getting recent/latest price quotes
   MqlTick latest_Price; // Structure to get the latest prices    
     
   SymbolInfoTick(Symbol() , latest_Price); // Assign current prices to structure 

   return latest_Price;

   //dBid_Price = Latest_Price.bid;  // Current Bid price.
   //dAsk_Price = Latest_Price.ask;  // Current Ask price.
   }
   
//+------------------------------------------------------------------+

void pop_up_text(string text)
{
   ObjectDelete  (obj_name);	
   ObjectCreate  (obj_name,OBJ_LABEL,0,0,0);
   ObjectSet     (obj_name,OBJPROP_XDISTANCE,600);
   ObjectSet     (obj_name,OBJPROP_YDISTANCE,50);
   ObjectSetText (obj_name,text,15,"Arial",Gold);
   PlaySound("tick.wav");
   microsecondsStart = GetMicrosecondCount();
   WindowRedraw();
}
 