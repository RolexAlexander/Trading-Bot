#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.02"
#include <Trade/Trade.mqh>
CTrade Trade;
int Handle_Fast_MA;
int Handle_Slow_MA;
int Handle_Lower_FMA;
int Handle_Lower_MiddleMA;
int lower_bollinger_bands;
int higher_bollinger_bands;
int Handle_Lower_SMA;
int Handle_Atr;
string signal;
double current_price;
int emagic = 3;
ulong TradeTicket;
double Rlots = 0.05;
double request_result;
input int trailingstop = 500; //Trailing Stop Loss

input int MagicNumber = 3; // Magic Number 
input string Tradecomment = "Adding Trailing Stop losses"; //Trade Comment
input double VolumeTrade = 0.02; //Trading Volume
int trend_Direction = 0;
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {

   
  }
// create a new pending order
void CreatePendingOrder(string symbol, ENUM_ORDER_TYPE type, double volume)
{
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double stoploss = price - 0.005;
   double tp = price + 0.01;
   
   MqlTradeRequest request;
   ZeroMemory(request);
   request.action = TRADE_ACTION_PENDING;
   request.type = type;
   request.symbol = _Symbol;
   request.volume = 0.1;
   request.price = price;
   request.sl = stoploss;
   request.tp = tp;
   request.comment = "Pending Buy Limit Order";
   
   MqlTradeResult result;
   ZeroMemory(result);
   
   request_result = OrderSend(request, result);
   if(result.order){
      Print("This is the radeticket");
      TradeTicket = result.order;
   }
   Print("Result code: ", result.retcode);
   Print("Order ticket: ", result.order);
}

  void start_trades(){
      /*double stoploss = SymbolInfoDouble(_Symbol,SYMBOL_POINT) * trailingstop;
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
      }*/
  }


void OnTick()
  { 
   lower_bollinger_bands = iBands(_Symbol,PERIOD_H4,20,0,2,PRICE_CLOSE);
   higher_bollinger_bands = iBands(_Symbol,PERIOD_H4,20,0,2,PRICE_CLOSE);
   
   double LBB[];
   double HBB[];
   double LLB[];
   double LUB[];
   double HLB[];
   double HUB[];

   
   CopyBuffer(lower_bollinger_bands,0,1,2,LBB);
   CopyBuffer(higher_bollinger_bands,0,1,2,HBB);
   CopyBuffer(lower_bollinger_bands,1,1,2,LUB);
   CopyBuffer(lower_bollinger_bands,2,1,2,LLB);
   CopyBuffer(higher_bollinger_bands,1,1,2,HUB);
   CopyBuffer(higher_bollinger_bands,2,1,2,HLB);
   
   current_price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   
   if(HUB[0] <= current_price){
      signal = "Sell";
      if(current_price <= LUB[0] && signal=="Sell"){
         if(TradeTicket){
            Trade.PositionClose(TradeTicket);
         }
         Print("About to enter a buy position");
         Trade.Sell(0.2,_Symbol);
         Trade.PositionClose(TradeTicket);
      }
   }
   if(HLB[0] >= current_price){
      signal = "Buy";
      if(current_price >= LLB[0] && signal=="Buy"){
         if(TradeTicket){
            Trade.PositionClose(TradeTicket);
         }
         Print("About to enter a buy position");
         Trade.Buy(0.2,_Symbol);
         TradeTicket = Trade.ResultOrder();
      }
   }
   
   /*
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
   
   start_trades();
   int Allpositions = PositionsTotal();
   Comment("\nFast MA Value: ", FMA[0],
            "Slow MA Value: ", SMA[0]);
   if(TradeTicket > 0 && PositionsTotal() == 0){
      TradeTicket = 0;
   }
   if (FMA[0] > SMA[0]){
      Print("Market is in UpTrend");
      trend_Direction = 1;
      //for(int i = PositionsTotal();i<=0;i--){
      //   long postype = PositionGetInteger(POSITION_TYPE);
      //   if(postype == POSITION_TYPE_SELL){
      //      Trade.PositionClose(PositionGetTicket(i));
      //   }
      //}
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
                     Trade.Buy(VolumeTrade,_Symbol);
                     TradeTicket = Trade.ResultOrder();
                     Print("A Buy trade was just place with the Trade Ticket: ", TradeTicket);
                  }
           }
   }
   if(SMA[0] > FMA[0]){
      Print("Market is in Down Trend");
      trend_Direction = -1;
      //for(int i = PositionsTotal();i<=0;i--){
      //   long postype = PositionGetInteger(POSITION_TYPE);
      //   if(postype == POSITION_TYPE_BUY){
      //      Trade.PositionClose(PositionGetTicket(i));
      //   }
      //}
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
                        Trade.Sell(VolumeTrade,_Symbol);
                        TradeTicket = Trade.ResultOrder();  
                        Print("A Sell Trade Was just Placed: ",TradeTicket);    
               }
         }
         
   }*/

   Comment("\nLower Bollinger Bands: ", lower_bollinger_bands,
            "\nHigher Bollinger Bands: ", higher_bollinger_bands,
            "\nLower Standard Deviation Bollinger Bands: ", LBB[0],
            "\nHigher Standard Deviation Bollinger Bands: ", HBB[0],
            "\nFirst Standard Deviation Lower Value", LLB[0],
            "\nFirst Standard Deviation Higher Value", LUB[0],
            "\nSecond Standard Deviation Lower Value", HLB[0],
            "\nSecond Standard Deviation Higher Value", HUB[0],
            "\nCurrent Price: ", current_price,
            "\nSignal: ", signal,
            "\nNumber of Open Positions: ", "",
            "\nTrade Ticket: ", TradeTicket);
  }
