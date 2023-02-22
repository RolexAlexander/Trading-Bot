//+------------------------------------------------------------------+
//|                                         OppositeTrades_EA.mq5 |
//|                        Copyright 2023, ChatGPT OpenAI            |
//|                                      https://chatgpt.com         |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
CTrade Trade;
// Trade parameters
input double Volume = 0.2; // Trade volume
input double StopLoss = 1000; // Stop loss in points
input double TrailingStop = 1000; // Trailing stop in points

// Global variables
datetime LastTradeTime = 0; // Last trade time

//+------------------------------------------------------------------+
//| Expert advisor initialization function                           |
//+------------------------------------------------------------------+
int OnInit()
{
    // Print initialization message to the log
    Print("Opposite Trades Expert Advisor initialized successfully");
    
    // Set the last trade time to 0 (no trades made yet)
    LastTradeTime = 0;
    
    // Return success
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert advisor start function                                     |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if it's a new day (based on the server time)
    datetime currentTime = TimeLocal()
    datetime currentDay = TIME_SECONDS(currentTime);
    datetime lastDay = TIME_SECONDS(LastTradeTime);
    if (currentDay != lastDay)
    {
        // It's a new day, make the trades
        
        // Check if we have enough margin for the trades
        double marginRequired = Volume * MarketInfo(_Symbol, MODE_MARGINREQUIRED);
        double freeMargin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
        if (freeMargin < marginRequired * 2)
        {
            // Not enough margin, print a message and return
            Print("Opposite Trades Expert Advisor: Not enough margin to make trades");
            return;
        }
        
        // Open a buy trade
        double buyPrice = SymbolInfoDouble(_Symbol, MODE_ASK);
        double buyStopLoss = buyPrice - StopLoss * SymbolInfoDouble(_Symbol, MODE_POINT);
        double buyTakeProfit = 0;
        double buyTrailingStop = TrailingStop * SymbolInfoDouble(_Symbol, MODE_POINT);
        ulong buyTicket = Trade.Buy(Volume, buyPrice, buyStopLoss, buyTakeProfit, "Buy", 0, buyTrailingStop);
        if (buyTicket == 0)
        {
            // Error opening buy trade, print a message and return
            Print("Opposite Trades Expert Advisor: Error opening buy trade - Error code: ", GetLastError());
            return;
        }
        
        // Open a sell trade
        double sellPrice = SymbolInfoDouble(_Symbol, MODE_BID);
        double sellStopLoss = sellPrice + StopLoss * SymbolInfoDouble(_Symbol, MODE_POINT);
        double sellTakeProfit = 0;
        double sellTrailingStop = TrailingStop * SymbolInfoDouble(_Symbol, MODE_POINT);
        ulong sellTicket = Trade.Sell(Volume, sellPrice, sellStopLoss, sellTakeProfit, "Sell", 0, sellTrailingStop);
        if (sellTicket == 0)
        {
            // Error opening sell trade, print a message and return
            Print("Opposite Trades Expert Advisor: Error opening sell trade - Error code: ", GetLastError());
            return;
        }
        
        // Set the last trade time to the current time
        LastTradeTime = currentTime;
    }
}