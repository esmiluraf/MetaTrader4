//+------------------------------------------------------------------+
//|                                                       Notify.mq4 |
//|                                       Copyright 2016, MyChartist |
//|                                        http://www.mychartist.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright © 2016, Oluwatosin Aboluwarin: www.mychartist.com"
#property link      "http://www.mychartist.com"
#property description "This library has smart notification(alert, push and alert) function with an option of having a single notification per candle at a time."
#property version   "1.0"

datetime notifyTag=0;
//+------------------------------------------------------------------+
//| Notify                                                     |
//+------------------------------------------------------------------+
void Notify(bool isAlert,bool isPush,bool isPrint,string msg,bool isNotifyOncePerCandle)
  {
   string msgDetail=Symbol()+" "+(string)Period()+" mins- "+msg;

   if(!isNotifyOncePerCandle)
     {
      if(isAlert) Alert(msgDetail);
      if(isPush) SendNotification(msgDetail);
      if(isPrint) Print(msgDetail);
     }
   else
     {
      if(notifyTag!=Time[0])
        {
         if(isAlert) Alert(msgDetail);
         if(isPush) SendNotification(msgDetail);
         if(isPrint) Print(msgDetail);

         notifyTag=Time[0];
        }
     }
  }
//+------------------------------------------------------------------+