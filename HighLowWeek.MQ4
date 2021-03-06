//
// YURAZ
// ���������� ������ ������
// Init  = 0  �������������� �������������
// tDay   -    �����  ����  ������  ������� ����������� ������� ���� ������
//
void GrafRSWeek(int Init, datetime tDay)
{
   static double LowWeek;
   static double HigWeek;


   HigWeek =  PeriodBarsHIGH(�����������(tDay),  �������(tDay));
   LowWeek =  PeriodBarsLOW(�����������(tDay),  �������(tDay));
   string sHigWeek = "HigW|"+Symbol()+"|"+TimeToStr(tDay,TIME_DATE)+"|";
   string sLowWeek = "LowW|"+Symbol()+"|"+TimeToStr(tDay,TIME_DATE)+"|";            
   if ( Init == 0 || Init == 2)
   {
      if ( ObjectFind(sHigWeek) == -1 )
      {
         ObjectCreate(sHigWeek, OBJ_TREND, 0, 
                  �����������(tDay)  ,
                  HigWeek, 
                  �������(tDay) ,
                  HigWeek, 0, 0);
         ObjectSet(sHigWeek, OBJPROP_RAY, false);
         ObjectSet(sHigWeek, OBJPROP_COLOR, LimeGreen);
      }
      if ( ObjectFind(sLowWeek) == -1 )
      {
         ObjectCreate(sLowWeek, OBJ_TREND, 0, 
                        �����������(tDay)  ,
                        LowWeek, 
                        �������(tDay) ,
                        LowWeek, 0, 0);
         ObjectSet(sLowWeek, OBJPROP_RAY, false);
         ObjectSet(sLowWeek, OBJPROP_COLOR, Yellow);
      }
   }
   ObjectSet( sHigWeek, OBJPROP_TIME1, �����������(tDay) );
   ObjectSet( sHigWeek, OBJPROP_TIME2, �������(tDay) );
   ObjectSet( sHigWeek, OBJPROP_PRICE1, HigWeek );
   ObjectSet( sHigWeek, OBJPROP_PRICE2, HigWeek );

   ObjectSet( sLowWeek, OBJPROP_TIME1, �����������(tDay) );
   ObjectSet( sLowWeek, OBJPROP_TIME2, �������(tDay) );
   ObjectSet( sLowWeek, OBJPROP_PRICE1, LowWeek );
   ObjectSet( sLowWeek, OBJPROP_PRICE2, LowWeek );
}
 
// YURAZ 
//
//
datetime �����������(datetime mDay)
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
datetime �������(datetime mDay)
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
