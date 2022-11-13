#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade Trade;
ulong tradeticket;
int OnInit()
  {
   Print("Hi there, you are Currently Using the best MA crossover in the World. Lets make the BAG!");

   return(INIT_SUCCEEDED);
  }


void OnDeinit(const int reason)
  {


  }


void OnTick()
  {
   //---
   //---
   //double AccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   //Comment(AccountBalance);
   //double PipValue = AccountBalance * 0.01 / 500 * 10;
   //Comment(PipValue);
   static datetime timestamp;
   datetime time = iTime(_Symbol, PERIOD_CURRENT,0);
   if (timestamp != time){
      timestamp = time;
      int slowMA = iDEMA(_Symbol, PERIOD_CURRENT,20,0,PRICE_CLOSE);
      int FastMA = iDEMA(_Symbol,PERIOD_CURRENT, 100, 0, PRICE_CLOSE);
      double MAslow[];
      double MAfast[];
      CopyBuffer(slowMA,0,1,2,MAslow);
      CopyBuffer(FastMA,0,1,2,MAfast);
      ArraySetAsSeries(MAslow,true);
      ArraySetAsSeries(MAfast,false);
      Comment("\nSlowMA: ", MAslow[0],
               "\nSlowMA: ", MAslow[1],
               "\nFastMA: ", MAfast[0],
               "\nFastMA: ", MAfast[1]);
      if (MAslow[0] > MAfast[0] && MAslow[1] > MAfast[1]){
         Print("Buy Signal Generated");
          if (tradeticket > 0 && PositionSelectByTicket(tradeticket)){
          long positiontype = PositionGetInteger(POSITION_TYPE);
          if (positiontype == POSITION_TYPE_SELL){
            Trade.PositionClose(tradeticket);
            tradeticket = 0;
          }
         }
         if (tradeticket <= 0){
            double currentprice = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double SL = currentprice + 100 * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            double TP = currentprice + 100 * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            Trade.Buy(0.2,_Symbol);
            tradeticket = Trade.ResultOrder();
         }
         
      }
      if (MAslow[0] < MAfast[0] && MAslow[1] < MAfast[1]){
         Print("Sell Signal Generated");
         if (tradeticket > 0 && PositionSelectByTicket(tradeticket)){
            long positiontype = PositionGetInteger(POSITION_TYPE);
            if (positiontype == POSITION_TYPE_BUY){
               Trade.PositionClose(tradeticket);
               tradeticket = 0;
            }
         }
         if (tradeticket <= 0){
            double Price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double Sl = Price + 100 * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            double Tp = Price + 100 * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
            Trade.Sell(0.2,_Symbol);
            tradeticket = Trade.ResultOrder();
         }
      }
   }
   
   
  }
