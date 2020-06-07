//
// YURAZ
// отображаем уровни недели
// Init  = 0  первоночальная инициализация
// tDay   -    любой  день  недели  вызовет отображение уровней этой недели
//
void GrafRSWeek(int Init, datetime tDay)
{
   static double LowWeek;
   static double HigWeek;


   HigWeek =  PeriodBarsHIGH(Понедельник(tDay),  Пятница(tDay));
   LowWeek =  PeriodBarsLOW(Понедельник(tDay),  Пятница(tDay));
   string sHigWeek = "HigW|"+Symbol()+"|"+TimeToStr(tDay,TIME_DATE)+"|";
   string sLowWeek = "LowW|"+Symbol()+"|"+TimeToStr(tDay,TIME_DATE)+"|";            
   if ( Init == 0 || Init == 2)
   {
      if ( ObjectFind(sHigWeek) == -1 )
      {
         ObjectCreate(sHigWeek, OBJ_TREND, 0, 
                  Понедельник(tDay)  ,
                  HigWeek, 
                  Пятница(tDay) ,
                  HigWeek, 0, 0);
         ObjectSet(sHigWeek, OBJPROP_RAY, false);
         ObjectSet(sHigWeek, OBJPROP_COLOR, LimeGreen);
      }
      if ( ObjectFind(sLowWeek) == -1 )
      {
         ObjectCreate(sLowWeek, OBJ_TREND, 0, 
                        Понедельник(tDay)  ,
                        LowWeek, 
                        Пятница(tDay) ,
                        LowWeek, 0, 0);
         ObjectSet(sLowWeek, OBJPROP_RAY, false);
         ObjectSet(sLowWeek, OBJPROP_COLOR, Yellow);
      }
   }
   ObjectSet( sHigWeek, OBJPROP_TIME1, Понедельник(tDay) );
   ObjectSet( sHigWeek, OBJPROP_TIME2, Пятница(tDay) );
   ObjectSet( sHigWeek, OBJPROP_PRICE1, HigWeek );
   ObjectSet( sHigWeek, OBJPROP_PRICE2, HigWeek );

   ObjectSet( sLowWeek, OBJPROP_TIME1, Понедельник(tDay) );
   ObjectSet( sLowWeek, OBJPROP_TIME2, Пятница(tDay) );
   ObjectSet( sLowWeek, OBJPROP_PRICE1, LowWeek );
   ObjectSet( sLowWeek, OBJPROP_PRICE2, LowWeek );
}
 
// YURAZ 
//
//
datetime Понедельник(datetime mDay)
{
   if ( TimeDayOfWeek( mDay ) == 2 )
      mDay = mDay  - 86400;
   if ( TimeDayOfWeek( mDay ) == 3 )
      mDay = mDay  - 172800; 
   if ( TimeDayOfWeek( mDay ) == 4 )
      mDay = mDay  - 259200; 
   if ( TimeDayOfWeek( mDay ) == 5 )
      mDay = mDay  - 345600; 
   return( StrToTime(TimeToStr(mDay,TIME_DATE)+" 00:00:00"));
}

//
//
//
datetime Пятница(datetime mDay)
{
   if ( TimeDayOfWeek( mDay ) == 4 )
      mDay = mDay  + 86400 ; 
   if ( TimeDayOfWeek( mDay ) == 3 )
      mDay = mDay  + 172800; 
   if ( TimeDayOfWeek( mDay ) == 2 )
      mDay = mDay  + 259200 ; 
   if ( TimeDayOfWeek( mDay ) == 1 )   
      mDay = mDay  + 345600 ; 
   return( StrToTime(TimeToStr(mDay,TIME_DATE)+" 23:59:59"));
}
