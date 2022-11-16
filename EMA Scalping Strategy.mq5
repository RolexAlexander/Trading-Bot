#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.01"
#include <Trade/Trade.mqh>
CTrade Trade;
int Handle_Fast_MA;
int Handle_Slow_MA;
int Handle_Lower_FMA;
int Handle_Lower_MiddleMA;
int Handle_Lower_SMA;
int Handle_Atr;
int emagic = 3;
ulong TradeTicket;
double Rlots = 0.05;
int trend_Direction = 0;
int OnInit()
  {
   /*Handle_Fast_MA = iMA(_Symbol,PERIOD_H1,8,0,MODE_EMA,PRICE_CLOSE);
   Handle_Slow_MA = iMA(_Symbol,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE);
   
   Handle_Lower_FMA = iMA(_Symbol,PERIOD_M5,8,0,MODE_EMA,PRICE_CLOSE);
   Handle_Lower_MiddleMA = iMA(_Symbol,PERIOD_M5,13,0,MODE_EMA,PRICE_CLOSE);
   Handle_Lower_SMA = iMA(_Symbol,PERIOD_M5,21,0,MODE_EMA,PRICE_CLOSE);
   TradeTicket = 0;*/
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {

   
  }
void OnTick()
  {
   int numberofpositions = PositionsTotal();
   if (numberofpositions >= 2){
      Print("There are more than two positions open");
      for(int i = numberofpositions-1;i <= 0; i--){
         ulong openposition = PositionGetTicket(i);
         Trade.PositionClose(openposition);
         Print("Double Position Closed");
      }
   }  
   Handle_Fast_MA = iMA(_Symbol,PERIOD_H1,8,0,MODE_EMA,PRICE_CLOSE);
   Handle_Slow_MA = iMA(_Symbol,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE);
   
   Handle_Lower_FMA = iMA(_Symbol,PERIOD_M5,8,0,MODE_EMA,PRICE_CLOSE);
   Handle_Lower_MiddleMA = iMA(_Symbol,PERIOD_M5,13,0,MODE_EMA,PRICE_CLOSE);
   Handle_Lower_SMA = iMA(_Symbol,PERIOD_M5,21,0,MODE_EMA,PRICE_CLOSE);
   
   double FMA[];
   double SMA[];
   double LFMA[];
   double LMMA[];
   double LSMA[];
   
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   CopyBuffer(Handle_Fast_MA,0,1,2,FMA);
   CopyBuffer(Handle_Slow_MA,0,1,2,SMA);
   CopyBuffer(Handle_Lower_FMA,0,1,2,LFMA);
   CopyBuffer(Handle_Lower_MiddleMA,0,1,2,LMMA);
   CopyBuffer(Handle_Lower_SMA,0,1,2,LSMA);
   
   Comment("Fast MA Value: ", FMA[0]);
   Comment("Slow MA Value: ", SMA[0]);
   
   if (FMA[0] > SMA[0]){
      Print("Market is in UpTrend");
      trend_Direction = 1;
      if(LFMA[0] < LMMA[0] && LMMA[0] < LSMA[0]){
         Print("Close Position");
                     if (TradeTicket > 0){
                        Print("About to Sell All Buy Positions");
                        long sellpositiontype = PositionGetInteger(POSITION_TYPE);
                        if (sellpositiontype == POSITION_TYPE_BUY){
                           Trade.PositionClose(TradeTicket);
                           TradeTicket = 0;
                           Print("Trade was just Closed: ",TradeTicket);
                        }
                     }
                 }
      if(LFMA[0] > LMMA[0] && LMMA[0] > LSMA[0]){
               Print("Buy Signal Generated");
                  if (TradeTicket > 0){
                     Print("About to Sell All Sell Positions");
                     long positiontype = PositionGetInteger(POSITION_TYPE);
                        if (positiontype == POSITION_TYPE_SELL){
                           Trade.PositionClose(TradeTicket);
                           TradeTicket = 0;
                           Print("There are no Positions Open: ",TradeTicket);
                        }
                     }
                  if(TradeTicket == 0){
                     Trade.Buy(0.02,_Symbol);
                     TradeTicket = Trade.ResultOrder();
                     Print("A Buy trade was just place with the Trade Ticket: ", TradeTicket);
                  }
           }
   }
   if(SMA[0] > FMA[0]){
      Print("Market is in Down Trend");
      trend_Direction = -1;
      if(LFMA[0] > LMMA[0] && LMMA[0] > LSMA[0]){
               Print("Close Position");
                  if (TradeTicket > 0){
                     Print("About to Sell Position All Sell Positions");
                     long positiontype = PositionGetInteger(POSITION_TYPE);
                        if (positiontype == POSITION_TYPE_SELL){
                           Trade.PositionClose(TradeTicket);
                           TradeTicket = 0;
                           Print("Trades was just closed: ",TradeTicket);
                        }
                     }
                }
     if(LFMA[0] < LMMA[0] && LMMA[0] < LSMA[0]){
            Print("Sell Signal Generated");
                  
                     if (TradeTicket > 0){
                     Print("About to sell All Buy Positions");
                        long sellpositiontype = PositionGetInteger(POSITION_TYPE);
                        if (sellpositiontype == POSITION_TYPE_BUY){
                           Trade.PositionClose(TradeTicket);
                           TradeTicket = 0;
                           Print("There are no Trades open: ",TradeTicket);
                        }
                     }
                     if(TradeTicket == 0){
                        Trade.Sell(0.02,_Symbol);
                        TradeTicket = Trade.ResultOrder();  
                        Print("A Sell Trade Was just Placed: ",TradeTicket);    
               }
         }
   }

   Comment("\nNew Line");
   Comment("\nNew Line");
   Comment("\nNew Line");
   Comment("\nNew Line");
   Comment("\nNew Line");
   Comment("\nNew Line");
   Comment("\nFast MA Value: ", FMA[0]);
   Comment("\nSlow MA Value: ", SMA[0]);
   Comment("\nLower Time Frame Fast Moving Average: ", LFMA[0],
            "\nLower Time Frame Middle Moving Average: ", LMMA[0],
            "\nLower Time Frame Slow Moving Average: ", LSMA[0]);
   Comment("\nTrend Direction: ", trend_Direction);
  }
