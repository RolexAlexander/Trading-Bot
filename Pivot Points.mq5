//+------------------------------------------------------------------+
//|                                                 Pivot Points.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade Trade;
//+------------------------------------------------------------------+
//| Expert Inputs                                  |
//+------------------------------------------------------------------+
input color pivot_color = clrAqua;//Pivot Point Colour
input color resistance_one_color = clrRed;//Resistance one Colour
input color resistance_two_color = clrRed;//Resistance two Colour
input color support_one_color = clrGreen;//Support one Colour
input color support_two_color = clrGreen;//Support two Colour
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
  double high = iHigh(_Symbol, PERIOD_D1,1);
  double close = iClose(_Symbol, PERIOD_D1,1);
  double low = iLow(_Symbol, PERIOD_D1, 1);
  datetime time1 = iTime(_Symbol, PERIOD_D1,0);
  datetime time2 = time1 + PeriodSeconds(PERIOD_D1);
  string OBJ_name = " ";
  
  double Pivot_Point = (high+close+low)/3;
  OBJ_name = "Pivot";
  create_pivot(OBJ_name,Pivot_Point,pivot_color,time1,time2);
  
  double Resistance_1=(Pivot_Point*2)-low;
  OBJ_name = "Resistance one";
  create_pivot(OBJ_name,Resistance_1,resistance_one_color,time1,time2);
  
  double Resistance_2=Pivot_Point+(high-low);
  OBJ_name = "Resistance two";
  create_pivot(OBJ_name,Resistance_2,resistance_two_color,time1,time2);
  
  double Support_1=(Pivot_Point*2)-high;
  OBJ_name = "Support one";
  create_pivot(OBJ_name,Support_1,support_one_color,time1,time2);
  
  double Support_2=Pivot_Point-(high-low);
  OBJ_name = "Support two";
  create_pivot(OBJ_name,Support_2,support_two_color,time1,time2);
  Comment("Resistance One: ", Pivot_Point,
          "\nBeginning Time: ", time1,
          "\nEnding Time: ", time2);
  }
//+------------------------------------------------------------------+
//| Pivot function                                                   |
//+------------------------------------------------------------------+
void create_pivot(string object_name,double price,int colour,datetime time_one, datetime time_two){
  ObjectCreate(0,object_name,OBJ_TREND,0,time_one,price,time_two,price);
  ObjectSetInteger(0,object_name,OBJPROP_COLOR,colour);
  ObjectSetInteger(0,object_name,OBJPROP_WIDTH,2);
}