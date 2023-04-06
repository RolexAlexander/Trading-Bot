//+------------------------------------------------------------------+
//|                                    Money_Flow_index_strategy.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

CTrade trade;

input double MfisellLevel = 80;
input double MfiBuyLevel = 20;
input double Lots = 0.2;
input int tppercent = 0.5;
input int slpercent = 0.5;

int handleMfi;
int barsTotal;
bool isTradeAllowed;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   handleMfi = iMFI(_Symbol,PERIOD_CURRENT,14,VOLUME_TICK);
   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
//---
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
   int bars  = iBars(_Symbol,PERIOD_CURRENT);
   if(bars > barsTotal){
      barsTotal = bars;
      double mfi[];
      CopyBuffer(handleMfi,MAIN_LINE,1,1,mfi);
      
      if(mfi[0] < MfisellLevel && mfi[0] > MfiBuyLevel){
         isTradeAllowed = true;
      }
      if(isTradeAllowed){
         if(mfi[0] >= MfisellLevel ){
            double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            bid = NormalizeDouble(bid,_Digits);
            
            double tp = bid - bid * tppercent/100;
            tp = NormalizeDouble(tp,_Digits);
            
            double sl = bid + bid * slpercent/100;
            sl = NormalizeDouble(sl,_Digits);
            
            if(trade.Sell(Lots,_Symbol,bid,sl,tp)){
               Print("Selling Position");
               isTradeAllowed = false;
            }
         
        }if(mfi[0] <= MfiBuyLevel){
            double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            ask = NormalizeDouble(ask,_Digits);
            
            double tp = ask + ask * tppercent/100;
            tp = NormalizeDouble(tp,_Digits);
            
            double sl = ask - ask * slpercent/100;
            sl = NormalizeDouble(sl,_Digits);
            
            
            if(trade.Buy(Lots,_Symbol,ask,sl,tp)){
               Print("Buying Position");
               isTradeAllowed = false;
            }
        }
      }
      
   }
   
}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
