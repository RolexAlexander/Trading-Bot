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
input int WPR_period = 15;//WPR Calculation Period
input double Position_Size = .2;//Position Size
input double Trade_Percentage = 1;//Percentage Size
input bool Trade_Decision = false;//Trade or Not
string OBJ_name = "";
string num = "1";
datetime wait;
int checked = 1;
double Previous_pivot_Point;
double Pivot_Point=0;
string Analysis;
double WPR_value[];
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
  double rsi = iRSI(_Symbol,PERIOD_CURRENT,15,PRICE_CLOSE);
  
  
  if(num=="1" && checked==0){
      wait=time2;
      checked+=1;
      Previous_pivot_Point = 0;
  }
  if(wait<=time1){
      Print("Time to change Pivot line names");
      Previous_pivot_Point = Pivot_Point;
      wait=time2;
      num = IntegerToString(checked);
      checked+=1;
  }
  
  
  Pivot_Point = (high+close+low)/3;
  OBJ_name = "Pivot3"+num;
  create_pivot(OBJ_name,Pivot_Point,pivot_color,time1,time2);
  
  double Resistance_1=(Pivot_Point*2)-low;
  OBJ_name = "Resistance one3"+num;
  create_pivot(OBJ_name,Resistance_1,resistance_one_color,time1,time2);
  
  double Resistance_2=Pivot_Point+(high-low);
  OBJ_name = "Resistance two3"+num;
  create_pivot(OBJ_name,Resistance_2,resistance_two_color,time1,time2);
  
  double Support_1=(Pivot_Point*2)-high;
  OBJ_name = "Support one3"+num;
  create_pivot(OBJ_name,Support_1,support_one_color,time1,time2);
  
  double Support_2=Pivot_Point-(high-low);
  OBJ_name = "Support two3"+num;
  create_pivot(OBJ_name,Support_2,support_two_color,time1,time2);
  
  Analyze_market();
  start_trade(Position_Size, Trade_Percentage,Trade_Decision);
  
  Comment("Resistance One: ", Pivot_Point,
          "\nBeginning Time: ", time1,
          "\nEnding Time: ", time2,
          "\nNextPivotName: ", num,
          "\nChecked: ", checked,
          "\nPivotline Name: ", OBJ_name,
          "\nWaiting Time: ", wait,
          "\nTime one", time1,
          "\nPrevious Pivot Point", Previous_pivot_Point,
          "\nCurrent Pivot Point", Pivot_Point,
          "\nWPR Value", WPR_value[0],
          "\nAnalysis", Analysis);
  }
//+------------------------------------------------------------------+
//| Pivot function                                                   |
//+------------------------------------------------------------------+
void create_pivot(string object_name,double price,int colour,datetime time_one, datetime time_two){
  ObjectCreate(0,object_name,OBJ_TREND,0,time_one,price,time_two,price);
  ObjectSetInteger(0,object_name,OBJPROP_COLOR,colour);
  ObjectSetInteger(0,object_name,OBJPROP_WIDTH,2);
}

void Analyze_market(){
   if(Previous_pivot_Point>Pivot_Point){
      Print("Potential Sell Signal Generated");
      Analysis = "Buy";
   }
   if(Previous_pivot_Point<Pivot_Point){
      Print("Potential Buy signal generated");
      Analysis = "Sell";
   }
}

void start_trade(double Position_size, double Percentage, bool Decision){
   if(Decision == true){
      Print("we can trade");
      double WPR_indication = iWPR(_Symbol,PERIOD_CURRENT,WPR_period);
      CopyBuffer(WPR_indication,0,1,2,WPR_value);
      if(Analysis == "Buy"){
         if(WPR_value[0]<=20){
            Print("We are buying a position");
         }else{
            Print("False Signal Generated");
         }
      }
      if(Analysis=="Sell"){
         if(WPR_value[0]>=80){
            Print("We are buying a position");
         }else{
            Print("False Signal Generated");
         }
      }
   }
}

