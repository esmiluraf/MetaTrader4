
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

#define INDICATOR_NAME   "Tuesday Marker"
#define OPEN_CROSS_LINE  "Tuesday "

color colors[5] =   {indicator_color1, indicator_color2, indicator_color3, indicator_color4, indicator_color5};




// **************************************
#define NUMBER_OF_WEEKS 52
// open price today at the gmtTime_h24
double tuesday_open_price[52];
string tuesday_open_date[52];
// **************************************


int init() {  

   MqlDateTime local_time;
	TimeToStruct(TimeLocal(), local_time);
	int local_hour = local_time.hour;
   int first_tuesday_index = (local_time.day_of_week  - 2 + 7) % 7;
    
   int index = 0;
   for (int day = 0; day < NUMBER_OF_WEEKS*7 && index < NUMBER_OF_WEEKS; ++day)
   {
      datetime jdate  = iTime(Symbol(), PERIOD_D1, day);
      MqlDateTime date;
      TimeToStruct(jdate, date);
      // if it's a Tuesday
      if (date.day_of_week == 2)
      {
         tuesday_open_price[index] =  iOpen(Symbol(), PERIOD_D1, day);
         tuesday_open_date[index]   = TimeToStr(jdate,TIME_DATE);
         index++;
      }
   }
   
	return(0);
}

int deinit() {

  for (int index = 0; index < 52; ++index)
  {
      string lineName = getStringForLine (index); 
      ObjectDelete(getTrendLineName(lineName, PERIOD_D1));
	}
	WindowRedraw();  
	return(0);
}

int start() {

	int style = 1;
	
	// delete the line (pips or gmtTime_h24 could have changed)
	deinit();
	
  for (int index = 0; index < 52; ++index)
  {
      int some_style_index = index % 5;    
      string lineName = getStringForLine (index); 
	   drawTrendLine(getTrendLineName(lineName, PERIOD_D1), tuesday_open_price[index], 
	                  colors[some_style_index], STYLE_DOT);
	}
	WindowRedraw();  
	return(0);
}


void drawTrendLine(string object_name, double price, color line_color, int line_style) {
	ObjectDelete(object_name);
	ObjectCreate(object_name, OBJ_HLINE, 0, Time[0], price, Time[Bars - 1], price);
	ObjectSet(object_name, OBJPROP_COLOR, line_color);
	ObjectSet(object_name, OBJPROP_STYLE, line_style);
	ObjectSet(object_name, OBJPROP_WIDTH, indicator_width1);
}

string getTrendLineName(string object_type, int timeframe) 
{
	return(object_type);
}

string getStringForLine(int index)
{
   return OPEN_CROSS_LINE + " " + tuesday_open_date[index]; 
}


double getOpenPrice()
{
   return iOpen(Symbol(), PERIOD_D1, 0);
}


double getLastPrice()
{

   // To be used for getting recent/latest price quotes
   MqlTick latest_price; // Structure to get the latest prices    
     
   SymbolInfoTick(Symbol() , latest_price); // Assign current prices to structure 

	double latest_mid =  (latest_price.bid + latest_price.ask ) /2.0;
	return latest_mid;
	
   }
   
//+------------------------------------------------------------------+
