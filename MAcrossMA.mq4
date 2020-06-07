//+------------------------------------------------------------------+
//|                                                                  |
//|                   Copyright 2018,So.T.evo. SrL                   |
//|                  http://www.powerfoton.info                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, So.T.evo. SrL "
#property link      "http://www.powerfoton.info"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Yellow    // Buffer 0
#property indicator_color2 Green     // Buffer 1
#property indicator_color3 Red       // Buffer 2
#property indicator_color4 Yellow    // Buffer 3
#property indicator_color5 Green     // Buffer 4
#property indicator_color6 Red       // Buffer 5
#property indicator_width1 3 // Buffer 0
#property indicator_width2 3 // Buffer 1 
#property indicator_width3 3 // Buffer 2
#property indicator_width4 3 // Buffer 3
#property indicator_width5 3 // Buffer 4
#property indicator_width6 3 // Buffer 5
#property indicator_width7 3 // Buffer 6
#property indicator_width8 0 // Buffer 7
#property strict
extern int period_1=42;
extern int period_2=70;
extern string ma1_sim_exp_smo = "exp";
extern string ma2_sim_exp_smo = "exp";
extern bool vis=true;
extern int price=0;
extern int Shift=0;
extern double distacco=0.0001;
//---
input double diff=0;// Pip di distanza nell'incrocio
input color ExtColor1 = Green; // Linea Incrocio Quota Buy
input color ExtColor2 = Green; // Linea Ora Incrocio Buy
input color ExtColor3 = Orange; // Linea Incrocio Quota Sell
input color ExtColor4 = Orange; //Linea Ora Incrocio Sell
//---
input color ExtColor5 = Yellow; // F200 Colore Furuncolo 
input color ExtColor6 = YellowGreen; // F200 Colore Buy
input color ExtColor7 = Red; // F200 Colore Sell
input color ExtColor8 = Magenta; // F200 Colore Media

input color ExtColor9 = Yellow; // F1000 Colore Furuncolo 
input color ExtColor10 = Green; // F1000 Colore Buy
input color ExtColor11 = Red; // F1000  Colore Sell
input color ExtColor12 = Magenta; // F1000  Colore Media

input color ExtColor13 = Yellow; // F3000 Colore Furuncolo 
input color ExtColor14 = Green; // F3000 Colore Buy
input color ExtColor15 = Red; // F3000  Colore Sell
input color ExtColor16 = Magenta; // F3000  Colore Media


//---
input bool visobj=True; // Visualizza descrizione oggetti
input bool autoscroll=True; // Scorre il grafico alla fine 
input bool fixscala=False; // Fissa Scala Grafico 
input bool visgrid=False; // Visualizza Griglia 
input bool sololin=False; // Visualizza solo le Fouriere e le Medie 
input ENUM_CHART_MODE modo =CHART_CANDLES;
// Variabili Barre

int storico;
//---- buffers
double BufferGreen[]; //Buffer 0
double BufferYellow[];//Buffer 1
double BufferRed[];////Buffer  2
double BufferY[]; //Buffer 3     Media da utilizzare per il confront
double BufferG[]; ////Buffer 4     0=giallo 1=verde 2=rosso
double BufferR[];//Buffer  5     Buy o Sell
double BufferQiB[];   //Buffer  6     Quota Incrocio buy
double BufferQiS[];   //Buffer  7     Quota Incrocio sell
string stato,id_linea_1,id_linea_2;
double orax,ira,AngTo,quotaprezzo,quotaincrocio;
bool   UpTrendAlert=false, DownTrendAlert=false;
bool   UpTrendAlert1=false, DownTrendAlert1=false;
string botto1;
string botto,order,botto2;
extern int AlertMode=0;
extern int AlertMode1=0;
int ma1_mode; 
int ma2_mode; 

// - Etichette
input color InpColor=clrWhite;  // Colore etichetta
input string            InpFont="Arial";         // Font 
input int               InpFontSize=8;          // Dimensione Font  

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
      
  ObjectDelete(0,"Quota Inc Buy"+  " "+IntegerToString(period_1,0));
  ObjectDelete(0,"Ora Inc Buy"+ " "+IntegerToString(period_1,0));
  ObjectDelete(0,"Quota Inc Sell"+  " "+IntegerToString(period_1,0));
  ObjectDelete(0,"Ora Inc Sell"+ " "+IntegerToString(period_1,0));


  
  ChartSetInteger(0,CHART_SHOW_OBJECT_DESCR,visobj); // Visualizza la descrizione degli Oggetti
  ChartSetInteger(0,CHART_AUTOSCROLL,autoscroll);        // Scorre il grafico alla fine 
  ChartSetInteger(0, CHART_MODE,modo); // Grafico a Candele
  ChartSetInteger(0,CHART_SCALEFIX,fixscala);          // Fissa Scala Grafico   
  ChartSetInteger(0,CHART_SHOW_GRID,visgrid);         // Mostra Griglia
  if (sololin)
  {
  ChartSetInteger(0, CHART_MODE,CHART_LINE);
  ChartSetInteger(0,CHART_COLOR_CHART_LINE,CLR_NONE);
  
  }
  
  
  
  //stato="init";
  id_linea_1=IntegerToString(period_1,0);
     
   int i;
   for(i=0;i<4;i++)
     {
      SetIndexStyle(i,DRAW_LINE);
      SetIndexDrawBegin(i,period_1);
      SetIndexShift(i,Shift);
      SetIndexLabel(i,"Periodo "+id_linea_1+ "\n Valore "); 
     }
  
  id_linea_2=IntegerToString(period_2,0);   
      for(i=3;i<6;i++)
     {
      SetIndexStyle(i,DRAW_LINE);
      SetIndexDrawBegin(i,period_2);
      SetIndexShift(i,Shift);
      SetIndexLabel(i,"Periodo "+id_linea_2+ "\n Valore "); 
     }
 
   
   SetIndexBuffer(0,BufferYellow);
   SetIndexBuffer(1,BufferGreen);
   SetIndexBuffer(2,BufferRed);
   SetIndexBuffer(3,BufferY);
   SetIndexBuffer(4,BufferG);
   SetIndexBuffer(5,BufferR);
   
   SetIndexBuffer(6,BufferQiS);
   SetIndexBuffer(7,BufferQiB);
  
   
//   SettaColori();
   // Etichetta Fourrier
   if (vis)
   {
   ObjectCreate(0,"MA"+id_linea_1,OBJ_TEXT,0,TimeCurrent(),1);
   ObjectSetString(0,"MA"+id_linea_1,OBJPROP_FONT,InpFont); 
   ObjectSetInteger(0,"MA"+id_linea_1,OBJPROP_FONTSIZE,InpFontSize); 
   ObjectSetString(0,"MA"+id_linea_1,OBJPROP_TEXT,"F"+id_linea_1); 
   ObjectSetInteger(0,"MA"+id_linea_1,OBJPROP_ANCHOR,0); 
   ObjectSetInteger(0,"MA"+id_linea_1,OBJPROP_COLOR,InpColor);
   // Etichetta Media
   ObjectCreate(0,"MA"+id_linea_2,OBJ_TEXT,0,TimeCurrent(),1);
   ObjectSetString(0,"MA"+id_linea_2,OBJPROP_FONT,InpFont); 
   ObjectSetInteger(0,"MA"+id_linea_2,OBJPROP_FONTSIZE,InpFontSize); 
   ObjectSetString(0,"MA"+id_linea_2,OBJPROP_TEXT,"F"+id_linea_2); 
   ObjectSetInteger(0,"MA"+id_linea_2,OBJPROP_ANCHOR,0); 
   ObjectSetInteger(0,"MA"+id_linea_2,OBJPROP_COLOR,InpColor);  
   }
   
   
   ma1_mode = GetMode(ma1_sim_exp_smo); 
   ma2_mode = GetMode(ma2_sim_exp_smo); 


   return(0);
  }//int init() 
  
  
 //+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  { 
  bool sino; 
  sino=ObjectDelete(0,"Quota Inc Buy"+  " "+id_linea_1);
  sino=ObjectDelete(0,"Ora Inc Buy"+ " "+id_linea_1);
  sino=ObjectDelete(0,"Quota Inc Sell"+  " "+id_linea_1);
  sino=ObjectDelete(0,"Ora Inc Sell"+ " "+id_linea_1);
  sino=ObjectDelete(0,"F"+id_linea_1);
  sino=ObjectDelete(0,"F"+id_linea_2);
  }
//+------------------------------------------------------------------+
int start()
    {
    
 
    
   string oray;
   int n=3;  
   int rv=0,rr=0; 
   double moving_average1, moving_average2;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;
   for(int i=limit;i>=0;i--)
     {
      moving_average1=iMA(Symbol(), 0, period_1, 0, ma1_mode, PRICE_MEDIAN,i);
  
      moving_average2=iMA(Symbol(), 0, period_2, 0, ma2_mode, PRICE_MEDIAN,i);
    
      BufferGreen[i] = moving_average1;
      BufferYellow[i]= moving_average1;
      BufferRed[i]   = moving_average1;
      
      BufferG[i]     = moving_average2;
      BufferY[i]     = moving_average2;
      BufferR[i]     = moving_average2;

      if(BufferYellow[i]>BufferYellow[i+1])
        {
         BufferRed[i]=EMPTY_VALUE;
         //BufferRis[i]=1; 
         rr=1;
         rv=0;
        } 
       else if(BufferYellow[i]<BufferYellow[i+1])
        {
         BufferGreen[i]=EMPTY_VALUE;
         //BufferRis[i]=2;
         rr=0;
         rv=1;
         } 
       else  //if(BufferYellow[i]==BufferYellow[i+1])
         {
         BufferRed[i]  =EMPTY_VALUE;
         BufferGreen[i]=EMPTY_VALUE;
         //BufferRis[i]=0; 
  
         }
         
         
         
       if(BufferY[i]>BufferY[i+1])
        {
         BufferR[i]=EMPTY_VALUE;
         //BufferRis[i]=1; 
         //rr=1;
         //rv=0;
        } 
       else if(BufferY[i]<BufferY[i+1])
        {
         BufferG[i]=EMPTY_VALUE;
         //BufferRis[i]=2;
         //rr=0;
         //rv=1;
         } 
       else  //if(BufferYellow[i]==BufferYellow[i+1])
         {
         BufferR[i]=EMPTY_VALUE;
         BufferG[i]=EMPTY_VALUE;
         //BufferRis[i]=0; 
  
         }
         
  
 
 if (vis) ObjectMove(0,"MA"+id_linea_1,0,TimeCurrent(),BufferYellow[i]); 
 if (vis) ObjectMove(0,"MA"+id_linea_2,0,TimeCurrent(),BufferY[i]); 

  }
      
       
     ///// leon
storico=0;
int conta=1,volta=0;
int scambio=0;
//for ( int scambio=1; scambio < 2000; scambio++)
//+-------------------------------------------------------------------------------+
// Formula per storare nell'array le informazioni in sequenza        
// (N x volta)+volta+posizione
// N=numero informazioni-1 (parte da 0) es. Sell o Buy, QuotaIncrocio,QuotaPrezzo 
// Posizione = posizione nella sequenza es 0 SoB, 1 QI,2QP
//+-------------------------------------------------------------------------------+



do
{ 
  
   scambio ++;
  // Print("Array ",ArrayRange(BufferMedia,0), " Scambio ", scambio);
   if   (ArrayRange(BufferY,0)== scambio) 
   { 
   
   //Print("Array ",ArrayRange(BufferMedia,0), " Scambio ", scambio);
   break;
   }
   
   if ( BufferY [conta] > BufferYellow [conta])
      {
         if ( BufferY [scambio] < BufferYellow [scambio] ) 
         
            {
                  storico=scambio; 
                  if (storico!=0)
                  {
                   
                   
                   stato="Sell";
                   conta=storico+1;
                   test(storico);
                   //BufferQiS[i]=orax;
                   //BufferStato[(n*volta)+(volta)]=1;
                   //BufferStato[(n*volta)+(volta+1)]=quotaincrocio;
                   //BufferStato[(n*volta)+(volta+2)]=quotaprezzo;
                   //BufferStato[(n*volta)+(volta+3)]=orax;
                  
                   volta ++;
                  } 
            }
      }

   if ( BufferY [conta] < BufferYellow [conta])
      {
         if ( BufferY [scambio] > BufferYellow [scambio])
          {
                  storico=scambio; 
                  if (storico!=0)
                  {
                   stato="Buy";
                   conta=storico+1;
                   test(storico);
                   //BufferQiB[i]=orax;
                   //BufferStato[(n*volta)+(volta)]=0;
                   //BufferStato[(n*volta)+(volta+1)]=quotaincrocio;
                   //BufferStato[(n*volta)+(volta+2)]=quotaprezzo;
                   //BufferStato[(n*volta)+(volta+3)]=orax;
                  
                   volta ++;             
                  } 
          }
      }
}
while (volta <2) ;

 return(0);
  }


//+------------------------------------------------------------------+
//| Disegna Linea Orizzontale                                                                 |
//+------------------------------------------------------------------+
void DrawHl (string des, double prezzo,datetime tempo)

{

bool sino=ObjectDelete(0,des);

ObjectCreate(des,OBJ_HLINE,0,0,prezzo);
if (stato=="B")
   {
      ObjectSet(des,OBJPROP_COLOR,ExtColor1);
   }
else
   {
     ObjectSet(des,OBJPROP_COLOR,ExtColor3); 
   }
      
ObjectSet( des,OBJPROP_STYLE, STYLE_DASH );
ObjectSetString( 0,des,OBJPROP_TEXT,des+" "+ TimeToString(tempo,TIME_DATE|TIME_MINUTES));
                  


if (stato=="Buy" && storico < 4 && Volume[0]<2 && quotaincrocio < iClose(Symbol(),0,1) && (iClose(Symbol(),0,1)-quotaincrocio)<distacco)
    {
     order="Buy!!!";
    botto1 = MQLInfoString(MQL_PROGRAM_NAME)+"-"+IntegerToString(period_1)+ " TREND-BUY   !!!!! " + Symbol () + "   " + DoubleToString(Bid,5) ;
    if(AlertMode1>0)SendNotification( botto1 );
    if(AlertMode1>0)Alert (botto1);
      UpTrendAlert1=true; DownTrendAlert1=false;
     }

if ( stato=="Sell"  && storico < 4 && Volume[0]<2 && quotaincrocio > iClose(Symbol(),0,1) && (quotaincrocio - iClose(Symbol(),0,1)<distacco))
     
     {
      order="Sell  !!!";
       botto1 =MQLInfoString(MQL_PROGRAM_NAME)+"-"+IntegerToString(period_1)+ " TREND-SELL  !!!!! " + Symbol () + "   " +DoubleToString( Ask,5) ;
      
           if(AlertMode1>0) SendNotification( botto1 );

      if(AlertMode1>0)Alert (botto1);
      UpTrendAlert1=false; DownTrendAlert1=true;

    
     }
/*
 
  if (storico==2 && Volume[0]<2)
    {
    botto2 = " NATO INCROCIO   !!!!! " + Symbol () + "  delta=  " + (-quotaincrocio + iClose(Symbol(),0,0))*10000 ;
          if(AlertMode1>0)Alert (botto2);
      UpTrendAlert1=true; DownTrendAlert1=false;
     }
*/



}



//+------------------------------------------------------------------+
//| Disegna Linea Verticale                                                                |
//+------------------------------------------------------------------+
void DrawVl (string des, double tempo)

{
ObjectDelete(des);
ObjectCreate(des,OBJ_VLINE,0,tempo,0);
ObjectSet( des,OBJPROP_STYLE, STYLE_DASH );
if (stato=="B")
   {
      ObjectSet(des,OBJPROP_COLOR,ExtColor2);
   }
else
   {
     ObjectSet(des,OBJPROP_COLOR,ExtColor4); 
   } 
ObjectSetString( 0,des,OBJPROP_TEXT,des);

}


int GetMode(string mode)
{
   //mode is expected to be one of these "sim" "exp" "smo";
   
   // "sim"
   if (mode[0] == 's' && mode[1] == 'i')
      return  MODE_SMA;
   else
   // "exp"
   if (mode[0] == 'e')
      return MODE_EMA;
   else
   // "smo"
   if (mode[0] == 's' && mode[1] == 'm')
      return  MODE_SMMA;  
 
   Alert ("ma1_mode_simple_exp_smoo_lin wrong input");
   return  MODE_EMA;  
}  
   
   
//+------------------------------------------------------------------+
//| Setta i colori delle linee in base al perido                     |
//+------------------------------------------------------------------+
//void SettaColori()
//{
//if (period <200 ) 
//{
//   SetIndexStyle(0,DRAW_LINE,0,1,ExtColor5);
//   SetIndexStyle(1,DRAW_LINE,0,1,ExtColor6);
//   SetIndexStyle(2,DRAW_LINE,0,1,ExtColor7);
//   SetIndexStyle(3,DRAW_LINE,0,1,ExtColor8);
//}
//if (period >= 200 && period  <999 ) 
// {
// 
//   SetIndexStyle(0,DRAW_LINE,0,3,ExtColor5);
//   SetIndexStyle(1,DRAW_LINE,0,3,ExtColor6);
//   SetIndexStyle(2,DRAW_LINE,0,3,ExtColor7);
//   SetIndexStyle(3,DRAW_LINE,0,3,ExtColor8);
//    
//  
// }
//
//if (period > 999 && period  <3000 ) 
// {
// 
//   SetIndexStyle(0,DRAW_LINE,0,4,ExtColor9);
//   SetIndexStyle(1,DRAW_LINE,0,4,ExtColor10);
//   SetIndexStyle(2,DRAW_LINE,0,4,ExtColor11);
//   SetIndexStyle(3,DRAW_LINE,0,4,ExtColor12);
//  
// }
//
//if (period > 2999 ) 
// {
// 
//    SetIndexStyle(0,DRAW_LINE,0,5,ExtColor13);
//    SetIndexStyle(1,DRAW_LINE,0,5,ExtColor14);
//    SetIndexStyle(2,DRAW_LINE,0,5,ExtColor15);
//    SetIndexStyle(3,DRAW_LINE,0,5,ExtColor16);
//  }
//}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test(int Storico)
{

quotaprezzo=Close[Storico];// iClose(NULL,0,storico);
quotaincrocio=(BufferYellow[Storico-1]+BufferY[Storico-1])/2;
orax = Time[Storico];//         TimeCurrent ()-(storico*ChartPeriod ()*60);
if (vis)
{
DrawHl("Quota Inc "+stato+ " "+ id_linea_1+"-"+id_linea_2,quotaincrocio,orax);
DrawVl("Ora Inc "+ stato + " "+id_linea_1+"-"+id_linea_2,orax);
}



}