#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.02"
#include <Trade/Trade.mqh>
CTrade Trade;
int Handle_Fast_MA;
int Handle_Slow_MA;
int Handle_Lower_FMA;
int Handle_Lower_MiddleMA;
int Handle_Lower_SMA;
int Handle_Atr;
ulong TradeTicket;
double Rlots = 0.05;
int trend_Direction = 0;
input int MagicNumber = 2323; // Magic Number 
input string Tradecomment = "Adding Trailing Stop losses"; //Trade Comment
input double VolumeTrade = 0.02; //Trading Volume
input int trailingstop = 50; // Trailing Stop Loss
input double stop_loss = 1000; // Stop Loss
int buycount;
int sellcount;
bool Buy = true;
bool Sell = true;
int OnInit()
  {
   Trade.SetExpertMagicNumber(MagicNumber);
   int count = PositionsTotal();
   for (int i =count-1;i<=0; i--){
      ulong tradeticket = PositionGetTicket(i);
         if (tradeticket>0){
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber){
               if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY){
                  buycount++;
                  TradeTicket = tradeticket;
               }
               if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL){
                  sellcount++;
                  TradeTicket = tradeticket;
               }
            }
         }
      }
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {

   
  }
  
void start_trades(){
      double stoploss = SymbolInfoDouble(_Symbol,SYMBOL_POINT) * trailingstop;
      static int digits = (int)SymbolInfoInteger (_Symbol, SYMBOL_DIGITS);
      
      double buystoploss = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID) - stoploss,digits);
      double sellstoploss = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK) + stoploss,digits);   
      
      int count = PositionsTotal();
      for (int i =count-1;i<=0; i--){
      ulong tradeticket = PositionGetTicket(i);
         if (tradeticket>0){
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber){
               if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY){
                  if(buystoploss > PositionGetDouble(POSITION_PRICE_OPEN) && buystoploss >  PositionGetDouble(POSITION_SL)){
                        Trade.PositionModify(tradeticket,buystoploss,PositionGetDouble(POSITION_TP));
                  }
               }
               if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL){
                  if(sellstoploss < PositionGetDouble(POSITION_PRICE_OPEN) && sellstoploss <  PositionGetDouble(POSITION_SL)){
                        Trade.PositionModify(tradeticket,sellstoploss,PositionGetDouble(POSITION_TP));
                  }
               }
            }
         }
      }
  }
  
void OnTick()
  { 
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
   
   TradeTicket = PositionGetTicket(0);
   
   start_trades();
   
   
   if(trend_Direction == 1 && sellcount>0){
      int count = PositionsTotal();
      for (int i =count-1;i<=0; i--){
         ulong tradeticket = PositionGetTicket(i);
            if (sellcount>0){
               if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber){
                  if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL){
                     Trade.PositionClose(tradeticket);
                     sellcount--;
                  }
               }
            }
         }
      }
   if(trend_Direction == -1 && buycount>0){
      int count = PositionsTotal();
      for (int i =count-1;i<=0; i--){
         ulong tradeticket = PositionGetTicket(i);
            if (buycount>0){
               if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber){
                  if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY){
                     Trade.PositionClose(tradeticket);
                     buycount--;
                  }
               }
            }
         }
      }
   if (FMA[0] > SMA[0]){
      Print("Market is in UpTrend");
      trend_Direction = 1;
      Sell = true;
      if(LFMA[0] < LMMA[0] && LMMA[0] < LSMA[0]){
         Print("Close All Buy Positions. Market Changed Direction");
         Buy = true;
         int count = PositionsTotal();
         for (int i =count-1;i<=0; i--){
            ulong tradeticket = PositionGetTicket(i);
               if (buycount>0){
                  if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber){
                     if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY){
                        Print("About to Sell All Buy Positions");
                        Trade.PositionClose(tradeticket);
                        buycount--;
                        Print("Trade was just Closed: ",tradeticket);
                     }
                  }
               }
            }
         }         
                        
                        
                           
                    
      if(LFMA[0] > LMMA[0] && LMMA[0] > LSMA[0]){
               Print("Buy Signal Generated");
                  if (sellcount > 0){
                     int count = PositionsTotal();
                     for (int i =count-1;i<=0; i--){
                        ulong tradeticket = PositionGetTicket(i);
                           if (sellcount>0){
                              if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber){
                                 if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL){
                                    Trade.PositionClose(tradeticket);
                                    sellcount--;
                                    Print("The sell position was just closed: ",tradeticket);
                                 }
                              }
                           }
                        }
                     }
                  if(buycount <= 0 && Buy == true){
                     Trade.Buy(VolumeTrade,_Symbol);
                     TradeTicket = Trade.ResultOrder();
                     buycount++;
                     Buy = false;
                     Print("A Buy trade was just place with the Trade Ticket: ", TradeTicket);
                  }
           }
   }
   if(SMA[0] > FMA[0]){
      Print("Market is in Down Trend");
      trend_Direction = -1;
      Buy = true;
      if(LFMA[0] > LMMA[0] && LMMA[0] > LSMA[0]){
         Print("Close Sell Positions");
         Sell = true;
         int count = PositionsTotal();
         for (int i =count-1;i<=0; i--){
            ulong tradeticket = PositionGetTicket(i);
               if (sellcount>0){
                  if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber){
                     if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL){
                        Print("About to Sell Position");
                        Trade.PositionClose(tradeticket);
                        sellcount--;
                        Print("Trades was just closed: ",tradeticket);
                     }
                  }
               }
            }     
     }
     if(LFMA[0] < LMMA[0] && LMMA[0] < LSMA[0]){
            Print("Sell Signal Generated");
                  
                     if (buycount > 0){
                        Print("About to sell All Buy Positions");
                        int count = PositionsTotal();
                        for (int i =count-1;i<=0; i--){
                           ulong tradeticket = PositionGetTicket(i);
                              if (buycount>0){
                                 if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber){
                                    if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY){
                                       Trade.PositionClose(tradeticket);
                                       buycount--;
                                       Print("There are no Trades open: ",tradeticket);
                                    }
                                 }
                              }
                           }
                     }
                     if(sellcount <= 0 && Sell == true){
                        Trade.Sell(VolumeTrade,_Symbol);
                        TradeTicket = Trade.ResultOrder();  
                        sellcount++;
                        Sell = false;
                        Print("A Sell Trade Was just Placed: ",TradeTicket);    
               }
         }
   }
   buycount=0;
   sellcount=0;
   int count = PositionsTotal();
   for (int i =count-1;i<=0; i--){
      ulong tradeticket = PositionGetTicket(i);
         if (tradeticket>0){
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber){
               if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY){
                  buycount++;
               }
               if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL){
                  sellcount++;
               }
            }
         }
      }
   Comment("\nFast MA Value: ", FMA[0],
            "\nSlow MA Value: ", SMA[0],
            "\nLower Time Frame Fast Moving Average: ", LFMA[0],
            "\nLower Time Frame Middle Moving Average: ", LMMA[0],
            "\nLower Time Frame Slow Moving Average: ", LSMA[0],
            "\nTrend Direction: ", trend_Direction,
            "\nNumber of Open Positions: ", PositionsTotal(),
            "\nTrade Ticket: ", TradeTicket,
            "\nNumber of Sell Positions: ", sellcount,
            "\nNumber of Buy Positions: ", buycount,
            "\nCan we buy Positions: ", Buy,
            "\nCan we Sell Positions: ", Sell);
  }
