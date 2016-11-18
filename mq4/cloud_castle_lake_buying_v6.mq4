//+------------------------------------------------------------------+
//|                                         cloud_castle_lake_v_.mq4 |
//|                                     Copyright 2016, Arlo Emerson |
//|                                                          fuckyou |
//+------------------------------------------------------------------+


//remember: run this on 5, 15, and 30 m charts before you tinker with the code. 

#property copyright "Copyright 2016, Arlo Emerson"
#property link      "fuckyou"
#property version   "1.00"
#property strict


input int    MovingPeriod=3;
input double TakeProfit    =50;
input double Lots          =0.1;

int _ticketNumber;
double _TP, _SL;
double _point;//Request for Point   
bool _modifyOrder = false;


//globally adjust tp/sl
double _stopLossFactor = 15;
double _takeProfitFactor = 30;

int _labelIndex = 0;

string _sym = Symbol();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   _sym = Symbol();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
   double maHigh=iMA(_sym,0,MovingPeriod,0,MODE_LWMA,PRICE_HIGH,1);
   double maLow=iMA(_sym,0,MovingPeriod,0,MODE_LWMA,PRICE_LOW,1);
   double maClose = iMA(_sym,0,17,0,MODE_LWMA,PRICE_CLOSE,1);
   
   
   
   double	high		= High[1],
   			low		= Low[1],
   			open		= Open[1],
   			close		= Close[1];
   
   
   //loop existing open orders
   //if current close is lower than order open price (breakeven)
   //then reset the SL to breakeven
   AdjustSL(close);
   
   int fooHour = Hour();
   
   //quick and dirty way to find hammers and wicky candles			
   if(
      1==1
      &&
      iCCI(NULL, 0, 21,PRICE_WEIGHTED, 1) < 100
      &&
      fooHour >= 0
      && 
      fooHour <= 12
      )
   {     
      //open new order
      //  _TP=Bid+_takeProfitFactor*10*_point;
      // _SL=Bid-_stopLossFactor*10*_point;               
      // _ticketNumber = OrderSend(Symbol(),OP_SELL,Lots,Bid,3,_SL,_TP,"orderfoo",16384,0,Red); 
         
      //loop back in time, looking for a breakout candle
      int lookbackLimit = 500;
      int lowerLimitLookback = 2; //set to 2 if you want to look at all previous candles
      int filterOutCandlesLessThan = 20;
      int blockingCandleIndex = -1;
            
      for (int i=0;i<lookbackLimit;i++)
      {
         if (  //find a bull       
               low > Open[lowerLimitLookback+i]
               &&
               low < Close[lowerLimitLookback+i]              
         )
         {         
            blockingCandleIndex = lowerLimitLookback+i;
            break;                     
         }         
       }      
            
      double tmpThing1 = iMA(_sym,0,17,0,MODE_LWMA,PRICE_CLOSE,blockingCandleIndex);
      double tmpThing2 = iMA(_sym,0,50,0,MODE_EMA,PRICE_LOW,blockingCandleIndex);
         
      //SECONDARY FILTER - prove that bear candle is not at the end of a downtrend
              
      if (  
            blockingCandleIndex != -1
            
            && //don't look at anything closer than N
            (blockingCandleIndex > filterOutCandlesLessThan)
            
            && //breakout blocker can't be a hammer with a bottom wick longer than body
            (Open[blockingCandleIndex] - Low[blockingCandleIndex]) < (Close[blockingCandleIndex] - Open[blockingCandleIndex])            
      )
      {                  
      
        int candidateFound = 0;     
        
        //now we take our CCI/21 walk
        //no need to walk farther than where our signal is       
        for(int k=1;k<blockingCandleIndex;k++)
        {
            double tmpCCI = iCCI(NULL, 0, 21,  PRICE_WEIGHTED, blockingCandleIndex - k);
            
            if (tmpCCI > 100)
            {
            candidateFound = 1;
            break;
            }
        }
        
        
        //check for equal or larger bears preceding our blocker
        //this tells us what?
        //this tells us if price might actually go a little higher above our signal
        //to reach that pool of supply
         int nearBearCount = 0;
         
         /*         
         for(int j=1;j<30;j++)
         {
            if (
                  Open[blockingCandleIndex+j] > Close[blockingCandleIndex+j] //we gotta bear
                  &&
                  (Open[blockingCandleIndex+j] - Close[blockingCandleIndex+j]) >= ((Open[blockingCandleIndex] - Close[blockingCandleIndex])/2) //nearby bear is at least half as big as our bear
                  &&
                  ((Open[blockingCandleIndex+j] - Open[blockingCandleIndex]) >= 0.05) //open of nearby bear is 5 pips above our blocker
               )
               { 
                  //put a pink star next to nearby bears
                  //ObjectCreate("nearBear"+blockingCandleIndex+j,OBJ_ARROW,0,Time[blockingCandleIndex+j],High[blockingCandleIndex+j]);
                  //ObjectSet("nearBear"+blockingCandleIndex+j, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
                  //ObjectSet("nearBear"+blockingCandleIndex+j,OBJPROP_COLOR,Pink);
                               
                  nearBearCount+=1;
               }
         }
         */
         
         //check if candle BEFORE the blocker/breakout has a wick taller 
         //and is basically a hanging man
         int precedingShadowCount = 0;
         if (
            Close[blockingCandleIndex+1] <= Open[blockingCandleIndex]
            &&
            High[blockingCandleIndex+1] >= High[blockingCandleIndex]            
         )
         {
            precedingShadowCount+=1;
         }
         
         
         //check if the candle AFTER the blocker is a star. 
         //especially a bullish star. 
         //also check if wick is shadowing our blocker, of which will disqualify our breakout        
         int followingStarCount = 0;
         
         for(int s=1;s<blockingCandleIndex;s++)
         {
            if (
                  Low[blockingCandleIndex-s] <= Open[blockingCandleIndex] //we got a shadow
               )
               {        
                  followingStarCount+=1;
               }
         }
         /*
         if (
                  Open[blockingCandleIndex-1] >= Close[blockingCandleIndex-1] //we got a bear directly candle after the breakout
               )
               {        
                  followingStarCount+=1;
               }
        */
        
        if (candidateFound == 1 && nearBearCount == 0 && followingStarCount == 0 && precedingShadowCount == 0)
        {                                
            string _labelName1 = "asdf";
            ObjectCreate(_labelName1+_labelIndex,OBJ_ARROW,0,Time[1],low);
            ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
            ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Green);             
            
            _TP=Bid+0.90;
            _SL=Bid-0.10;  
            
            //Print(_SL," ", _TP);                        
            _ticketNumber = OrderSend(Symbol(),OP_BUY,Lots,Bid,3,0,0,"",16384,0,Green);            
            _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
            
            //draw a line from our signal to the breakout
            ObjectCreate("buysellSRLine" + _labelIndex,OBJ_TREND,0, Time[1], low, Time[blockingCandleIndex], low );
            ObjectSet("buysellSRLine" + _labelIndex,OBJPROP_COLOR,Green);
            ObjectSet("buysellSRLine" + _labelIndex,OBJPROP_WIDTH,1);
            ObjectSet("buysellSRLine" + _labelIndex,OBJPROP_RAY,false);
                 
            _labelIndex += 1; 
         }
      }
            
            
      
      
      //_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);             
   }	   
}

void AdjustSL(double pClose)
{  
return;
//TODO - figure out an optimized breakeven strategy

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
//      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      /*
      if(OrderType()==OP_BUY)
        {
         if(Open[1]>ma && Close[1]<ma)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
        */
      if(OrderType()==OP_SELL)
        {
            if (OrderOpenPrice() - pClose > 0.05)
            {
         int ordNum = OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderProfit(), 0);
         //if(  > pClose )
         //  {
         //   if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
         //      Print("OrderClose error ",GetLastError());
         //  }
         break;
         }
        }
     }    
}

