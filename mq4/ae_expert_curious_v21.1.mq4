//arlo emerson, 9/9/2012

//this is a raghee horner method
//13/21 green line
//34/55 red line, ema Close
//except for the 34 is low for buy and high for sell

//DRAW S/R LINES
//TAKE THE AVERAGE OF THE LAST 3 YELLOW REZ LINES, THAT IS YOUR TP
//TAKE THE AVERAGE OF THE LAST 3 AQUA SUPPORT LINES, THAT IS YOUR SL
//TRADE WHEN PRICE GETS NEAR THE SUPPORT LINE
//SELL WHEN PRICE GETS NEAR THE REZ LINE.

/*
trendline_tested = false //default
when support_cycle == true, start drawing trendlines across the highs of the series
when trendline is broken to upside, trendline_broken = true
we are waiting for a test of the extreme (i.e. the last broken trendline)
trendline start begins on first Z, redraw end point on every new candle high
when support_cycle ends, the trendline will remain
if there is a well behaved bounce and test, we simply enter when price closes above the last trendline
need to add a check for trendline==downtrend, else we might be missing the boat 

see image: https://mail.google.com/mail/#inbox/1399c71a3be8ef61

*/

//the problem is if the larger trend is up and you want to buy a pullback, 
//you need to see a mini downtrend on the smaller chart.
//the problem is you don't know when price will stop on the downtrend.
//ideally it will stop no lower than the trendline of the larger chart, but this is rare. sometimes it's above, sometimes it's lower.
//and if it keeps going it means the larger timeframe just broke. so right there you have losers built into the game.
//and when do you decide the macro trend started? that is the problem. how far is your lookback?
//because you will always find great patterns, lines, and indicators to support you argument in hindsight situation.
//can you actually read the supply and demand on the chart you might stand a chance.
//so the mm (them) is always tricking you about what price is doing. they are just toying with you. they have complete control.
//can you trick them? can you place your entries above and below places?
//it's like surfing: you wait for the waves and ride the big ones long.
//you don't fight the water, you don't fight the ocean.
//but in the water we lose when we fall off or miss a lot of big waves.
//great surfing happens when you combine great weather forecasting with geologic knowledge and couple that with great talent and technology.
//those are edges that the ancient hawaiian didn't have, even though he could surf.
//in the markets we can't see the waves coming, usually. we can't read the tape anymore and order flow is the ultimate forecaster.
//look at july 31st for classic demand breakout.
//but how do you predict it? is it the repeated testing of the prior resistance level, chipping away at it and also as the support moves up?
//bull wedge.




//globally adjust tp/sl
double _stopLossFactor = 8;
double _takeProfitFactor = 47;

int _matchFoundIndex; //use this to store patterns...we will sort the good from the bad
string _matchFoundLibrary = "";
bool _entryCueMatchFound = false; //set to true when we match a time in the entryCue list
string _entryCueDirection = "";

string _val_macdAVG143421;
string _val_macdAVG8016021;
string _val_EMA_a;
string _val_EMA_b;
string _val_StdDev_a;
string _val_Volume_a;
string _val_Volume_b;
string _val_MFI_a;

string _cciTrendMode = "";

#define    SECINMIN         60  //Number of seconds in a minute

extern int  TimeFrame		= 5;

extern int vsiMAPeriod    = 21;  //Period for the moving average.
extern int vsiMAType      = 0;  //Moving average type. 0 = SMA, 1 = EMA, 2 = SMMA, 3 = LWMA
extern int showPerPeriod  = 0;  //0 = volume per second, 1 = volume per chart period
                                /* Volume per second allows you to compare values for different
                                   chart periods. Otherwise the values it will show will only be
                                   valid for the chart period you are viewing. The graph will
                                   look exactly the same but the values will be different. */

double vsiBuffer[999];
double vsiMABuffer[999];
string Sym = "";

string _labelName1 = "trend";
string _labelName2 = "hhll_";

string _previousLabel = "";
int _hhIndex = 1;
int _llIndex = 1;

string _lookbackSignalPattern[3] = { "xx", "xx", "xx" }; 

//this is used for tidying up the chart at each new candle
datetime _lastAlertTime;
int _labelIndex = 0;
int _ticketNumber;
bool _modifyOrder = false;

double _minDist;
double _bid; // Request for the value of Bid
double _ask; // Request for the value of Ask
double _point;//Request for Point   


bool _TARGET_ACQUIRED = false;
bool _TARGET_LOCKED = false;
double _ENTRY_TARGET;
double _RESISTANCE_TARGET;
double _SUPPORT_TARGET;
double _LAST_AVERAGE_SUPPORT;
double _LAST_AVERAGE_RESISTANCE;
double _LAST_LOW;
double _LAST_HIGH;
int _LAST_HIGH_SHIFT;
int _LAST_LOW_SHIFT;
double _entryPrice;
double _TP;
double _SL;

int _tradeEntryTime;
int _targetAcquisitionTime;
double _targetAcquisitionHigh;
double _targetAcquisitionLow;
double _targetAcquisitionOpen;
double _targetAcquisitionClose;

int _targetConfirmationTime;
double _targetConfirmationHigh;
double _targetConfirmationLow;
double _targetConfirmationOpen;
double _targetConfirmationClose;

double _resistencePrices[34] = {100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00}; //list for storing prices where resistence occurs
int _resistencePriceCounter = 0;

double _supportPrices[34] = {100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00}; //list for storing prices where resistence occurs
int _supportPriceCounter = 0;

int _shiftMacdStart, _shiftMacdEnd;
int _shiftSupportMacdStart, _shiftSupportMacdEnd;

int _tradeLeg = 0; //we count legs or our trades, currently we only do 2 legs per entry

double _lastZCrossingClose;
double _thisZCrossingClose;
double _lastZCrossingHigh;
double _thisZCrossingHigh;
double _lastZCrossingLow;
double _thisZCrossingLow;

int _lastZCrossingTime;
int _thisZCrossingTime;

bool _SUPPORT_CYCLE = false;

bool _minus1CandleSupportCycleOn = false;
double _downtrendStartPrice;
double _downtrendEndPrice;
int _downtrendStartPriceTime;
string _lastTrendlineName;
int _lastTrendlineShift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   _lastAlertTime = TimeCurrent();
   Sym = Symbol();
	cleanUpChart();
	return(0);
}

int cleanUpChart()
{
	for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
	{
         string on = ObjectName(iObj);
         if (StringFind(on, _labelName1, 0) > -1)
         {
            ObjectDelete(on);
         }
         else if (StringFind(on, _labelName2, 0) > -1)
         {
            ObjectDelete(on);
         }
   }
   return(0);
}

bool _firstRun = false;
int i=0; //i is never incremented. hard-code a 0 everywhere this occurs
int ThisBarTrade=0;


int start()
{
   int timeDiff;
   int limit;

   _firstRun = true;
   _lastAlertTime = Time[0];
   
   if (Bars != ThisBarTrade )
   //for(int i = Bars; i >= 0; i--)
   {
       ThisBarTrade = Bars;
   
      //declarations
      int shift1 = iBarShift(NULL,TimeFrame,Time[i]),
	        time1  = iTime    (NULL,TimeFrame,shift1);
	        
		//int fiveMinuteShift= MathFloor(i/5);
		//int hourlyShift= MathFloor(i/60);
		//int fourHourlyShift= MathFloor(i/240);
		int fifteenMinShift= MathFloor(i/3);
      int hourlyShift= MathFloor(i/12);
      int fourHourlyShift= MathFloor(i/48);

	   double	high		= iHigh(NULL,TimeFrame,shift1),
			low		= iLow(NULL,TimeFrame,shift1),
			open		= iOpen(NULL,TimeFrame,shift1),
			close		= iClose(NULL,TimeFrame,shift1),
	 		bodyHigh	= MathMax(open,close),
			bodyLow	= MathMin(open,close);
			
  		int minus1CandleTime = iTime(NULL,TimeFrame,shift1+1);
   	int minus1CandleIndex = iTime(NULL,TimeFrame,shift1+1);
   	double minus1CandleOpen = iOpen(NULL,TimeFrame,shift1+1);
   	double minus1CandleClose = iClose(NULL,TimeFrame,shift1+1);
   	double minus1CandleLow = iLow(NULL,TimeFrame,shift1+1);
   	double minus1CandleHigh = iHigh(NULL,TimeFrame,shift1+1);

   	double minus2CandleLow = iLow(NULL,TimeFrame,shift1+2);
   	double minus2CandleHigh = iHigh(NULL,TimeFrame,shift1+2);
   	double minus2CandleClose = iClose(NULL,TimeFrame,shift1+2);
   	double minus2CandleOpen = iOpen(NULL,TimeFrame,shift1+2);

   	double minus3CandleLow = iLow(NULL,TimeFrame,shift1+3);
   	double minus3CandleHigh = iHigh(NULL,TimeFrame,shift1+3);
   	double minus3CandleClose = iClose(NULL,TimeFrame,shift1+3);
   	double minus3CandleOpen = iOpen(NULL,TimeFrame,shift1+3);
   
   	double minus4CandleLow = iLow(NULL,TimeFrame,shift1+4);
   	double minus4CandleHigh = iHigh(NULL,TimeFrame,shift1+4);
   	double minus4CandleClose = iClose(NULL,TimeFrame,shift1+4);
   	double minus4CandleOpen = iOpen(NULL,TimeFrame,shift1+4);

   	double minus5CandleLow = iLow(NULL,TimeFrame,shift1+5);
   	double minus5CandleHigh = iHigh(NULL,TimeFrame,shift1+5);
   	double minus5CandleClose = iClose(NULL,TimeFrame,shift1+5);

   	double minus6CandleLow = iLow(NULL,TimeFrame,shift1+6);
   	double minus6CandleHigh = iHigh(NULL,TimeFrame,shift1+6);
   	double minus6CandleClose = iClose(NULL,TimeFrame,shift1+6);

   	double minus7CandleLow = iLow(NULL,TimeFrame,shift1+7);
   	double minus7CandleHigh = iHigh(NULL,TimeFrame,shift1+7);
   	double minus7CandleClose = iClose(NULL,TimeFrame,shift1+7);

   	double minus8CandleLow = iLow(NULL,TimeFrame,shift1+8);
   	double minus8CandleHigh = iHigh(NULL,TimeFrame,shift1+8);
   	double minus8CandleClose = iClose(NULL,TimeFrame,shift1+8);

   	double minus9CandleLow = iLow(NULL,TimeFrame,shift1+9);
   	double minus9CandleHigh = iHigh(NULL,TimeFrame,shift1+9);
   	double minus9CandleClose = iClose(NULL,TimeFrame,shift1+9);

   	double minus10CandleLow = iLow(NULL,TimeFrame,shift1+10);
   	double minus10CandleHigh = iHigh(NULL,TimeFrame,shift1+10);
   	double minus10CandleClose = iClose(NULL,TimeFrame,shift1+10);

   	double minus11CandleLow = iLow(NULL,TimeFrame,shift1+11);
   	double minus11CandleHigh = iHigh(NULL,TimeFrame,shift1+11);
   	double minus11CandleClose = iClose(NULL,TimeFrame,shift1+11);
   	double minus11CandleOpen = iOpen(NULL,TimeFrame,shift1+11);

   	double minus12CandleLow = iLow(NULL,TimeFrame,shift1+12);
   	double minus12CandleHigh = iHigh(NULL,TimeFrame,shift1+12);
   	double minus12CandleClose = iClose(NULL,TimeFrame,shift1+12);
   	double minus12CandleOpen = iOpen(NULL,TimeFrame,shift1+12);

   	double minus13CandleLow = iLow(NULL,TimeFrame,shift1+13);
   	double minus13CandleHigh = iHigh(NULL,TimeFrame,shift1+13);
   	double minus13CandleClose = iClose(NULL,TimeFrame,shift1+13);
   	double minus13CandleOpen = iOpen(NULL,TimeFrame,shift1+13);

   	double minus14CandleLow = iLow(NULL,TimeFrame,shift1+14);
   	double minus14CandleHigh = iHigh(NULL,TimeFrame,shift1+14);
   	double minus14CandleClose = iClose(NULL,TimeFrame,shift1+14);
   	double minus14CandleOpen = iOpen(NULL,TimeFrame,shift1+14);

   	double minus15CandleLow = iLow(NULL,TimeFrame,shift1+15);
   	double minus15CandleHigh = iHigh(NULL,TimeFrame,shift1+15);
   	double minus15CandleClose = iClose(NULL,TimeFrame,shift1+15);
   	double minus15CandleOpen = iOpen(NULL,TimeFrame,shift1+15);

   	double minus16CandleLow = iLow(NULL,TimeFrame,shift1+16);
   	double minus16CandleHigh = iHigh(NULL,TimeFrame,shift1+16);
   	double minus16CandleClose = iClose(NULL,TimeFrame,shift1+16);
   	double minus16CandleOpen = iOpen(NULL,TimeFrame,shift1+16);

   	double minus17CandleLow = iLow(NULL,TimeFrame,shift1+17);
   	double minus17CandleHigh = iHigh(NULL,TimeFrame,shift1+17);
   	double minus17CandleClose = iClose(NULL,TimeFrame,shift1+17);
   	double minus17CandleOpen = iOpen(NULL,TimeFrame,shift1+17);

   	double minus18CandleLow = iLow(NULL,TimeFrame,shift1+18);
   	double minus18CandleHigh = iHigh(NULL,TimeFrame,shift1+18);
   	double minus18CandleClose = iClose(NULL,TimeFrame,shift1+18);
   	double minus18CandleOpen = iOpen(NULL,TimeFrame,shift1+18);

   	double minus19CandleLow = iLow(NULL,TimeFrame,shift1+19);
   	double minus19CandleHigh = iHigh(NULL,TimeFrame,shift1+19);
   	double minus19CandleClose = iClose(NULL,TimeFrame,shift1+19);
   	double minus19CandleOpen = iOpen(NULL,TimeFrame,shift1+19);

   	double minus20CandleLow = iLow(NULL,TimeFrame,shift1+20);
   	double minus20CandleHigh = iHigh(NULL,TimeFrame,shift1+20);
   	double minus20CandleClose = iClose(NULL,TimeFrame,shift1+20);
   	double minus20CandleOpen = iOpen(NULL,TimeFrame,shift1+20);

   	double minus21CandleLow = iLow(NULL,TimeFrame,shift1+21);
   	double minus21CandleHigh = iHigh(NULL,TimeFrame,shift1+21);
   	double minus21CandleClose = iClose(NULL,TimeFrame,shift1+21);
   	double minus21CandleOpen = iOpen(NULL,TimeFrame,shift1+21);

   	double minus22CandleLow = iLow(NULL,TimeFrame,shift1+22);
   	double minus22CandleHigh = iHigh(NULL,TimeFrame,shift1+22);
   	double minus22CandleClose = iClose(NULL,TimeFrame,shift1+22);
   	double minus22CandleOpen = iOpen(NULL,TimeFrame,shift1+22);

   	double minus23CandleLow = iLow(NULL,TimeFrame,shift1+23);
   	double minus23CandleHigh = iHigh(NULL,TimeFrame,shift1+23);
   	double minus23CandleClose = iClose(NULL,TimeFrame,shift1+23);
   	double minus23CandleOpen = iOpen(NULL,TimeFrame,shift1+23);

   	double minus24CandleLow = iLow(NULL,TimeFrame,shift1+24);
   	double minus24CandleHigh = iHigh(NULL,TimeFrame,shift1+24);
   	double minus24CandleClose = iClose(NULL,TimeFrame,shift1+24);
   	double minus24CandleOpen = iOpen(NULL,TimeFrame,shift1+24);

   	double minus25CandleLow = iLow(NULL,TimeFrame,shift1+25);
   	double minus25CandleHigh = iHigh(NULL,TimeFrame,shift1+25);
   	double minus25CandleClose = iClose(NULL,TimeFrame,shift1+25);
   	double minus25CandleOpen = iOpen(NULL,TimeFrame,shift1+25);
                
//***************** BEGIN VSI ENGINE ******************//			
      int arbitraryLimit = 21; //sub this for Bars
      for(int k = arbitraryLimit; k >= 0; k--)  
      {
            //Difference between the current time and the bar start
            timeDiff = CurTime() - Time[k];

            //If we are in the current bar and the tick doesn't fall exactly on the '00:00' min & sec
            if(k == 0 && timeDiff > 0) {
               vsiBuffer[k] = Volume[k] / timeDiff;
            } else {
               //Otherwise calculate the total bar volume divided by the total bar seconds
               vsiBuffer[k] = Volume[k] / (Time[k - 1] - Time[k]);
            }

            if(showPerPeriod == 1) {
               vsiBuffer[k] = vsiBuffer[k] * Period() * SECINMIN;
            }
            
            vsiMABuffer[k] = iMAOnArray(vsiBuffer, arbitraryLimit, vsiMAPeriod, 0, vsiMAType, k);
       }     
//***************** END VSI ENGINE ******************//

      RefreshBidsAndAsks();

//***************** CREATE INDICATOR VALUES ******************//
				
				double volMinus1Candle = vsiBuffer[i+1];
				double volMinus2Candle = vsiBuffer[i+2];
				double volMinus3Candle = vsiBuffer[i+3];
				double volMinus4Candle = vsiBuffer[i+4];
				double volMinus5Candle = vsiBuffer[i+5];
				double volMinus6Candle = vsiBuffer[i+6];
				double volAverage = (volMinus1Candle + volMinus2Candle + volMinus3Candle + volMinus4Candle + volMinus5Candle + volMinus6Candle)/6;
				
				//160 EMA
				double hourlyEma160Minus1Candle = iMA(Sym,PERIOD_H1,160,0,MODE_EMA,PRICE_TYPICAL,hourlyShift+1);
				double fiveMinEma160Minus1Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+1);				
				double fourHourEma160Minus1Candle = iMA(Sym,PERIOD_H4,160,0,MODE_EMA,PRICE_TYPICAL,fourHourlyShift+1);	
				
				double fiveMinuteEma160Minus1Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				double fiveMinuteEma160Minus2Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+2);
				double fiveMinuteEma160Minus3Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+3);
				double fiveMinuteEma160Minus4Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+4);
				double fiveMinuteEma160Minus5Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+5);
				double fiveMinuteEma160Minus6Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+6);
				double fiveMinuteEma160Minus7Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+7);
				double fiveMinuteEma160Minus8Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+8);
				double fiveMinuteEma160Minus9Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+9);
				double fiveMinuteEma160Minus10Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+10);
				double fiveMinuteEma160Minus11Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+11);
				double fiveMinuteEma160Minus12Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+12);
				double fiveMinuteEma160Minus13Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+13);
				double fiveMinuteEma160Minus14Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+14);
				
				//34 EMA 
				double hourlyEma34Minus1Candle = iMA(Sym,PERIOD_H1,34,0,MODE_EMA,PRICE_TYPICAL,hourlyShift+1);
				double fiveMinEma34Minus1Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+1);				
				double fiveMinEma34Minus2Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+2);	
				double fiveMinEma34Minus3Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+3);	
				double fiveMinEma34Minus4Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+4);	
				double fiveMinEma34Minus5Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+5);	
				double fiveMinEma34Minus6Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+6);	
				double fiveMinEma34Minus7Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+7);	
				double fiveMinEma34Minus8Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+8);	
				
				double fourHourEma34Minus1Candle = iMA(Sym,PERIOD_H4,34,0,MODE_EMA,PRICE_TYPICAL,fourHourlyShift+1);
				
				//13, 21 EMA
				double fiveMinEma13Minus1Candle = iMA(Sym,PERIOD_M5,13,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				double fiveMinEma21Minus1Candle = iMA(Sym,PERIOD_M5,21,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				
				
         	//larger timeframe candles
         	double fiveMinMinus1CandleClose = iClose(NULL,PERIOD_M5, shift1 + 1 );
         	double hourlyMinus1CandleClose = iClose(NULL,PERIOD_H1, hourlyShift + 1 );
         	double fourHourlyMinus1CandleClose = iClose(NULL,PERIOD_H4, fourHourlyShift + 1 );
         	
         	//MACD
         	double fiveMinMacdMinus1Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+1);
         	double fiveMinMacdMinus2Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+2);
         	double fiveMinMacdMinus3Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+3);
         	double fiveMinMacdMinus4Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+4);
         	
         	double fiveMinMacd_143421_Minus1Candle = iMACD(Sym, PERIOD_M5, 14, 34, 21, PRICE_CLOSE, MODE_EMA, shift1+1);
         	double fiveMinMacd_143421_Minus2Candle = iMACD(Sym, PERIOD_M5, 14, 34, 21, PRICE_CLOSE, MODE_EMA, shift1+2);
         	double fiveMinMacd_143421_Minus3Candle = iMACD(Sym, PERIOD_M5, 14, 34, 21, PRICE_CLOSE, MODE_EMA, shift1+3);
        
        		double fifteenMacd_143421_Minus1Candle = iMACD(Sym, PERIOD_M15, 14, 34, 21, PRICE_CLOSE, MODE_EMA, fifteenMinShift+1);
        		double hourlyMacd_143421_Minus1Candle = iMACD(Sym, PERIOD_H1, 14, 34, 21, PRICE_CLOSE, MODE_EMA, hourlyShift+1);
/* ------------------------- RESISTANCE LINES - NEG TO POS TO NEG ---------------------------*/
            
            //PURPOSE OF S/R CODE:
            //to find resistence lines and prevent entries right under these lines

         	//psuedo code         	
         	//when macd rises over 0, store shiftMacdStart
         	//when macd dips below 0, store shiftMacdEnd
         	//and use iHighest to determine the highest price between shiftMacdStart and shiftMacdEnd
         	//store the highest price in the resistencePriceArray
         	
         	//macd just flipped to +
      		if (
      	           fiveMinMacdMinus1Candle >= 0.0
      	           && fiveMinMacdMinus2Candle <= 0.0
      	     )
      	     {
      	        _shiftMacdStart = TimeCurrent();      	       
      	     }
      	     
         	
         	//macd just flipped to -
         	if (
         	     fiveMinMacdMinus1Candle <= 0.0
         	     && fiveMinMacdMinus2Candle >= 0.0
         	     )
         	     {
         	        _shiftMacdEnd =  TimeCurrent();         	        
         	        
         	        int tmpShiftStart = iBarShift(Sym, PERIOD_M5, _shiftMacdStart, true);
         	        int tmpShiftEnd = iBarShift(Sym, PERIOD_M5, _shiftMacdEnd, true);
         	        
         	        int tmpShiftOfHH = iHighest(Sym, PERIOD_M5, MODE_HIGH, (tmpShiftStart-tmpShiftEnd), tmpShiftEnd);
         	        double tmpPriceOfHH = High[tmpShiftOfHH];
         	        
         	        int tmpTimeOfHHStart = iTime(Sym, PERIOD_M5, tmpShiftStart);
         	        int tmpTimeOfHHEnd = iTime(Sym, PERIOD_M5, tmpShiftEnd);

                    ObjectCreate("resistencesellLine" + _labelIndex,OBJ_TREND,0, tmpTimeOfHHEnd, tmpPriceOfHH, tmpTimeOfHHStart, tmpPriceOfHH );
                    ObjectSet("resistencesellLine" + _labelIndex,OBJPROP_COLOR,Yellow);
                    ObjectSet("resistencesellLine" + _labelIndex,OBJPROP_WIDTH,1);
                    ObjectSet("resistencesellLine" + _labelIndex,OBJPROP_RAY,false);  
                    
                    _LAST_HIGH = tmpPriceOfHH;
                    _LAST_HIGH_SHIFT = tmpShiftOfHH; 
                    
                    //manually fill and shift 34 last high prices
                    //latest price is at 0, 
							_resistencePrices[34] = _resistencePrices[33]; 
							_resistencePrices[33] = _resistencePrices[32]; 
							_resistencePrices[32] = _resistencePrices[31]; 
							_resistencePrices[31] = _resistencePrices[30]; 
							_resistencePrices[30] = _resistencePrices[29]; 
							_resistencePrices[29] = _resistencePrices[28]; 
							_resistencePrices[28] = _resistencePrices[27]; 
							_resistencePrices[27] = _resistencePrices[26]; 
							_resistencePrices[26] = _resistencePrices[25]; 
							_resistencePrices[25] = _resistencePrices[24]; 
							_resistencePrices[24] = _resistencePrices[23]; 
							_resistencePrices[23] = _resistencePrices[22]; 
							_resistencePrices[22] = _resistencePrices[21]; 
							_resistencePrices[21] = _resistencePrices[20];  
							_resistencePrices[20] = _resistencePrices[19];  
							_resistencePrices[19] = _resistencePrices[18];  
							_resistencePrices[18] = _resistencePrices[17];  
							_resistencePrices[17] = _resistencePrices[16];  
							_resistencePrices[16] = _resistencePrices[15];  
							_resistencePrices[15] = _resistencePrices[14];  
							_resistencePrices[14] = _resistencePrices[13];  
							_resistencePrices[13] = _resistencePrices[12];  
							_resistencePrices[12] = _resistencePrices[11];  
							_resistencePrices[11] = _resistencePrices[10];  
							_resistencePrices[10] = _resistencePrices[9];  
							_resistencePrices[9] = _resistencePrices[8];  
							_resistencePrices[8] = _resistencePrices[7];  
							_resistencePrices[7] = _resistencePrices[6];  
							_resistencePrices[6] = _resistencePrices[5];  
							_resistencePrices[5] = _resistencePrices[4];  
							_resistencePrices[4] = _resistencePrices[3];  
							_resistencePrices[3] = _resistencePrices[2];  
							_resistencePrices[2] = _resistencePrices[1];            
							_resistencePrices[1] = _resistencePrices[0];
							_resistencePrices[0] = tmpPriceOfHH;
							
							_resistencePriceCounter++; 
							
							_RESISTANCE_TARGET = tmpPriceOfHH;
							_LAST_AVERAGE_RESISTANCE = (_resistencePrices[0] + _resistencePrices[1])/2;
							//Print("************************ tmpPriceOfHH ", tmpPriceOfHH); 
         	     }
            
            //if prices moves through a level more than n pips, 
            //wipe that level clean, remove from list of levels
            //otherwise leave the level because it represents real S/R
            for (int hh=0; hh<ArraySize(_resistencePrices); hh++)
            {            
               if(minus1CandleClose >= _resistencePrices[hh])// + 10*(10*Point))
               {
                  _resistencePrices[hh] = 100; //this is lazy
               }            
            }
/* ------------------------- SUPPORT LINES - POS TO NEG TO POS ---------------------------*/
            
            //PURPOSE OF S/R CODE:
            //to find support lines and prevent entries right under these lines

         	//psuedo code         	
         	//when macd rises over 0, store shiftMacdStart
         	//when macd dips below 0, store shiftMacdEnd
         	//and use iHighest to determine the highest price between shiftMacdStart and shiftMacdEnd
         	//store the highest price in the resistencePriceArray
         	
         	//macd just flipped to +
      		if (
						fiveMinMacdMinus1Candle <= 0.0
						&& fiveMinMacdMinus2Candle >= 0.0
      	     )
      	     {
      	        _shiftSupportMacdStart = TimeCurrent();
      	        _SUPPORT_CYCLE = true;      	       
      	     }
      	              	
         	//macd just flipped to -
         	if (
						fiveMinMacdMinus1Candle >= 0.0
						&& fiveMinMacdMinus2Candle <= 0.0         	    
         	     )
         	     {         	     
         	        _SUPPORT_CYCLE = false;
         	        _shiftSupportMacdEnd =  TimeCurrent();         	        
         	        
         	        int tmpSupportShiftStart = iBarShift(Sym, PERIOD_M5, _shiftSupportMacdStart, true);
         	        int tmpSupportShiftEnd = iBarShift(Sym, PERIOD_M5, _shiftSupportMacdEnd, true);
         	        
         	        int tmpSupportShiftOfLL = iLowest(Sym, PERIOD_M5, MODE_LOW, (tmpSupportShiftStart-tmpSupportShiftEnd), tmpSupportShiftEnd);
         	        double tmpSupportPriceOfLL = Low[tmpSupportShiftOfLL];
         	        
         	        int tmpSupportTimeOfLLStart = iTime(Sym, PERIOD_M5, tmpSupportShiftStart);
         	        int tmpSupportTimeOfLLEnd = iTime(Sym, PERIOD_M5, tmpSupportShiftEnd);

                    ObjectCreate("supportsellLine" + _labelIndex,OBJ_TREND,0, tmpSupportTimeOfLLEnd, tmpSupportPriceOfLL, tmpSupportTimeOfLLStart, tmpSupportPriceOfLL );
                    ObjectSet("supportsellLine" + _labelIndex,OBJPROP_COLOR,Aqua);
                    ObjectSet("supportsellLine" + _labelIndex,OBJPROP_WIDTH,1);
                    ObjectSet("supportsellLine" + _labelIndex,OBJPROP_RAY,false);                      
                                        
                    _LAST_LOW = tmpSupportPriceOfLL;
                    _LAST_LOW_SHIFT = tmpSupportShiftOfLL;                    
                                                                 
                    //manually fill and shift 34 last high prices
                    //latest price is at 0, 
							_supportPrices[34] = _supportPrices[33]; 
							_supportPrices[33] = _supportPrices[32]; 
							_supportPrices[32] = _supportPrices[31]; 
							_supportPrices[31] = _supportPrices[30]; 
							_supportPrices[30] = _supportPrices[29]; 
							_supportPrices[29] = _supportPrices[28]; 
							_supportPrices[28] = _supportPrices[27]; 
							_supportPrices[27] = _supportPrices[26]; 
							_supportPrices[26] = _supportPrices[25]; 
							_supportPrices[25] = _supportPrices[24]; 
							_supportPrices[24] = _supportPrices[23]; 
							_supportPrices[23] = _supportPrices[22]; 
							_supportPrices[22] = _supportPrices[21]; 
							_supportPrices[21] = _supportPrices[20];  
							_supportPrices[20] = _supportPrices[19];  
							_supportPrices[19] = _supportPrices[18];  
							_supportPrices[18] = _supportPrices[17];  
							_supportPrices[17] = _supportPrices[16];  
							_supportPrices[16] = _supportPrices[15];  
							_supportPrices[15] = _supportPrices[14];  
							_supportPrices[14] = _supportPrices[13];  
							_supportPrices[13] = _supportPrices[12];  
							_supportPrices[12] = _supportPrices[11];  
							_supportPrices[11] = _supportPrices[10];  
							_supportPrices[10] = _supportPrices[9];  
							_supportPrices[9] = _supportPrices[8];  
							_supportPrices[8] = _supportPrices[7];  
							_supportPrices[7] = _supportPrices[6];  
							_supportPrices[6] = _supportPrices[5];  
							_supportPrices[5] = _supportPrices[4];  
							_supportPrices[4] = _supportPrices[3];  
							_supportPrices[3] = _supportPrices[2];  
							_supportPrices[2] = _supportPrices[1];            
							_supportPrices[1] = _supportPrices[0];
							_supportPrices[0] = tmpSupportPriceOfLL;
							
							_supportPriceCounter++; 
							
							
							_LAST_AVERAGE_SUPPORT = (_supportPrices[0] + _supportPrices[1])/2;						
         	     }
            
            //if prices moves through a level more than n pips, 
            //wipe that level clean, remove from list of levels
            //otherwise leave the level because it represents real S/R
            for (int ss=0; ss<ArraySize(_supportPrices); ss++)
            {            
               if(minus1CandleClose <= _supportPrices[ss])// + 10*(10*Point))
               {
                  _supportPrices[ss] = 100.00; //this is lazy
               }            
            }

            
/* ------------------------- TRADE LOGIC ---------------------------*/

				//identify the trend
				
				if (_SUPPORT_CYCLE == false)
				{
				ObjectCreate("trendSupportCyc" + _labelIndex,OBJ_TREND,0, _downtrendStartPriceTime, _downtrendStartPrice, Time[i+1], _downtrendEndPrice  );
				ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_COLOR,Purple);
				ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_WIDTH,1);
				ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_RAY,false);
				}
				
				//acquire a target														         	
      		if(			
      		
      		       //_SUPPORT_CYCLE == true
						 minus1CandleClose > fiveMinuteEma160Minus1Candle 
						 && minus1CandleClose > minus2CandleHigh 
						 && 5==6
			     )
			     {			     					
						//begin tracking first price for trendline
						/*
						if (_minus1CandleSupportCycleOn == false)
						{
							_minus1CandleSupportCycleOn = true;
							_downtrendStartPrice = minus1CandleHigh;			
							_downtrendStartPriceTime = Time[i+1];		
						}
						*/
					 //determine the next highest Support or Resistance and enter there
					// _ENTRY_TARGET = getNextHighestSRLevel(minus1CandleClose);
					 _TARGET_ACQUIRED = true;
					 	ObjectCreate("targetAcquiredbuy"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
						ObjectSetText("targetAcquiredbuy"+_labelIndex,"Z",12,"Arial",Yellow);
				//	printResistenceLevels( minus1CandleClose, TimeCurrent() );
       		//	printSupportLevels( minus1CandleClose, TimeCurrent() );
       			
					
				
						
						_SUPPORT_TARGET = _supportPrices[0];
						_targetAcquisitionTime = Time[i+1];
						_targetAcquisitionOpen = minus1CandleOpen;
						_targetAcquisitionHigh = minus1CandleHigh;
						_targetAcquisitionLow = minus1CandleLow;
						_targetAcquisitionClose = minus1CandleClose;
						
			     }

		     	//confirm target
		     	if (  
						//_TARGET_ACQUIRED == true
						//&& _SUPPORT_CYCLE == false
						//&& Time[i+1] > _targetAcquisitionTime	
						minus1CandleClose > fiveMinuteEma160Minus1Candle 
						&& minus1CandleLow > fiveMinEma34Minus1Candle
						
						//price must be greater than last resistance
						&& minus1CandleClose > _RESISTANCE_TARGET
						
						//improves by a couple %
						&& isCandleTopExtraWicky(minus1CandleOpen, minus1CandleClose, minus1CandleHigh, minus1CandleLow)==false
						&& isCandleTopExtraWicky(minus2CandleOpen, minus2CandleClose, minus2CandleHigh, minus2CandleLow)==false
						
						//&& minus1CandleClose > minus1CandleOpen this reduces by small %
						
						//&& minus1CandleClose > _supportPrices[0]
						//&& minus1CandleClose > ((_resistencePrices[0] - _supportPrices[0])/4)+_supportPrices[0]
						
						//&& minus1CandleOpen < _RESISTANCE_TARGET	
						//&& minus1CandleClose > _RESISTANCE_TARGET	
						
						
						//13/21 EMA
						&& (
							(minus1CandleClose < fiveMinEma13Minus1Candle && minus1CandleClose > fiveMinEma34Minus1Candle)
							|| (minus1CandleLow < fiveMinEma13Minus1Candle && minus1CandleLow > fiveMinEma34Minus1Candle)
							)
										
					)
					{
						_TARGET_LOCKED = true;
						_TARGET_ACQUIRED = true;//short circuiting	     			    
						_targetConfirmationTime = Time[i+1];
						_targetConfirmationOpen = minus1CandleOpen;
						_targetConfirmationHigh = minus1CandleHigh;
						_targetConfirmationLow = minus1CandleLow;
						_targetConfirmationClose = minus1CandleClose;
						
						ObjectCreate("targetConfirmedbuy"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
						ObjectSetText("targetConfirmedbuy"+_labelIndex,"X",12,"Arial",Red);
						
						//what is last price of support cycle...draw the trendline
						if (	
								_minus1CandleSupportCycleOn == true
								&& 5==8
							)
						{
							_minus1CandleSupportCycleOn = false;					
							_downtrendEndPrice = minus2CandleHigh;							
							
							ObjectCreate("trendSupportCyc" + _labelIndex,OBJ_TREND,0, _downtrendStartPriceTime, _downtrendStartPrice, Time[i+1], _downtrendEndPrice  );
							ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_COLOR,Purple);
							ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_WIDTH,1);
							ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_RAY,false);
							_lastTrendlineName = "trendSupportCyc" + _labelIndex;
							_lastTrendlineShift = iBarShift(Sym, PERIOD_M5, TimeCurrent(), true);
						}					
			     	}				         			       						

				//target is real		
				if (					
						_TARGET_ACQUIRED == true
						&& _TARGET_LOCKED == true						
						
					//	&& minus1CandleLow > ObjectGetValueByShift(_lastTrendlineName, shift1+1)
					//	&& minus2CandleLow > ObjectGetValueByShift(_lastTrendlineName, shift1+2)					
						
						//TRADING WITH THE TREND
						&& minus1CandleClose > fiveMinuteEma160Minus1Candle 

					   			
						//&& hourlyMinus1CandleClose > hourlyEma160Minus1Candle
						//&& fourHourlyMinus1CandleClose > fourHourEma160Minus1Candle
												
						//WEIRD TRICK
						//open air -- believe it or not this improves profitability A LOT
						//&& minus1CandleClose > minus2CandleHigh
						//doesn't work for a pullback though, it's for breakouts
						
						
						
						/*
						&& minus1CandleClose > minus3CandleHigh
						&& minus1CandleClose > minus4CandleHigh
						&& minus1CandleClose > minus5CandleHigh
						&& minus1CandleClose > minus6CandleHigh
						&& minus1CandleClose > minus7CandleHigh
						&& minus1CandleClose > minus8CandleHigh
						&& minus1CandleClose > minus9CandleHigh
						&& minus1CandleClose > minus10CandleHigh
						&& minus1CandleClose > minus11CandleHigh
						&& minus1CandleClose > minus12CandleHigh
						&& minus1CandleClose > minus13CandleHigh
						&& minus1CandleClose > minus14CandleHigh
						&& minus1CandleClose > minus15CandleHigh
						&& minus1CandleClose > minus16CandleHigh
						&& minus1CandleClose > minus17CandleHigh
						&& minus1CandleClose > minus18CandleHigh
						&& minus1CandleClose > minus19CandleHigh
						&& minus1CandleClose > minus20CandleHigh													
						*/
						//&& imminentResistence(minus1CandleClose) == false						
						//&& minus1CandleLow < _targetConfirmationClose						
						
						//&& hourlyMacd_143421_Minus1Candle > 0
						//&& fiveMinMacd_143421_Minus2Candle > 0.00002
						//&& fiveMinMacd_143421_Minus3Candle > 0.00002
					
						//DOES AN INCREASING SPREAD MEAN ANYTHING?
						//&& candleSpreadGreaterThanNPips(minus1CandleHigh, minus1CandleLow, (minus2CandleHigh - minus2CandleLow)) == 1
						
					//PLAY AROUND WITH THE TARGET CRITERIA
												
						//price closes above the last rez line
						//&& minus1CandleClose > _RESISTANCE_TARGET
						
						//&& imminentResistence(minus1CandleClose) == false	
						//&& Time[i+1] > _targetConfirmationTime
						//minus1CandleLow <= (_targetConfirmationClose - _targetAcquisitionClose)/2
						//&& minus1CandleClose >= (_targetConfirmationClose - _targetAcquisitionClose)/2
				)
				{

					//ObjectCreate("buy"+_labelIndex,OBJ_ARROW,0,Time[i],_ask);
					//ObjectSet("buy"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
					//ObjectSet("buy"+_labelIndex,OBJPROP_COLOR,Green);
       
//       			printResistenceLevels( minus1CandleClose, TimeCurrent() );
//       			printSupportLevels( minus1CandleClose, TimeCurrent() );
       
         		_TARGET_ACQUIRED = false;
         		_TARGET_LOCKED = false;
         		_tradeLeg = 1;
      
         		if(i == 0)//only trade current candle
         		{        
            		if (OrdersTotal() == 0)
            		{                  
               		//open new order            
               		_ticketNumber = OrderSend(Sym,OP_BUY,0.1,_ask,3,0,0,"order #" + _labelIndex,0,0,Green); 
                     _tradeEntryTime = TimeCurrent();
                                  
               		if(_ticketNumber<0)
               		{
                  		Print("Trying to buy. OrderSend failed with error #",GetLastError());
               		}
               		else
               		{               	
                  		//mod ticket
                  		//_TP =  getAdjustedTP(minus1CandleClose);
                  		//_TP=_bid+_takeProfitFactor*(10*_point);
                  		//_TP = getNextHighestResistenceLevel(minus1CandleClose); //do this after the candle closes
                  		_TP=_bid+_takeProfitFactor*(10*_point);
                  		_SL=_bid-_stopLossFactor*(10*_point);
                  		_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
                  		_entryPrice = minus1CandleClose;
                  		//Print("entry price is: " + _entryPrice);
                  		Print("OrderModify on a buy last called. Last error was: ",GetLastError());
               		}           
            		}                                             
         		}                    
      		}
                 
      

      //***************** END TARGET ACQUISITION AND ENTRY ******************//       
     
     
      //***************** ADJUST TP AFTER THE ENTRY CANDLE CLOSES ******************//
      
      if(
      		Time[i+1] > _tradeEntryTime
      //		&& 1==3
      	)
      	{
      		_TP = getNextHighestSRLevel(minus1CandleClose);
      		//_TP = getAdjustedTP(minus1CandleClose);
      		//_TP = getNextHighestResistenceLevel(minus1CandleClose);
      		//_SL=_entryPrice+5*(10*_point);
      		_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
      		Print("OrderModify after the candle closed. Last error was: ",GetLastError());
      	}
      		
      
      
		//retire the target if it slips below our zone			
		//OR too much time has passed	
		if (  
				 _TARGET_ACQUIRED == true
				 //300 secs per 5 mins
				 && 7== 4
				 && Time[i+1] - _targetConfirmationTime > 3000
				// && _thisZCrossingTime - _lastZCrossingTime > 6000
				  //&& Time[i+1] > _targetConfirmationTime //time must have passed
				  //&& minus1CandleClose <= (_targetAcquisitionLow - 10*(Point*10)) //bottom of zone 
				  
				)
				{				
					_TARGET_ACQUIRED = false;
					_TARGET_LOCKED = false;
				}					
                     
		/*------- last thing you do is update the index --------*/
		_labelIndex++;
	}   
	return(0);
}


double getNextHighestSRLevel(double pPrice)
{
	int foo = ArraySort( _resistencePrices, WHOLE_ARRAY, 0, MODE_ASCEND);
	int tmpArraySize = ArraySize(_resistencePrices);
	double tmpNextRezLine = 0.0;
	for(int k=0;k<tmpArraySize;k++)
   {
   	if (	
   			_resistencePrices[k] > 0
   			&& _resistencePrices[k] > pPrice
   		)
   	{
   		tmpNextRezLine = _resistencePrices[k];
   		break;
   	}
   }
   
   
  	foo = ArraySort( _supportPrices, WHOLE_ARRAY, 0, MODE_ASCEND);
	tmpArraySize = ArraySize(_supportPrices);
	double tmpNextSupLine = 0.0;
	for(k=0;k<tmpArraySize;k++)
   {
   	if (	
   			_supportPrices[k] > 0
   			&& _supportPrices[k] > pPrice
   		)
   	{
   		tmpNextSupLine = _supportPrices[k];
   		break;
   	}
   } 
   
   if (tmpNextSupLine >= tmpNextRezLine)
   {
      return (tmpNextRezLine);
   }
   else if (tmpNextSupLine <= tmpNextRezLine)
   {
      return (tmpNextSupLine);
   }
   else
   {
      return (tmpNextSupLine);
   }   
}


double getNextHighestResistenceLevel(double pPrice)
{
	int foo = ArraySort( _resistencePrices, WHOLE_ARRAY, 0, MODE_ASCEND);
	int tmpArraySize = ArraySize(_resistencePrices);
	double tmpNextSRLine = 0.0;
	for(int k=0;k<tmpArraySize;k++)
   {
   	if (	
   			_resistencePrices[k] > 0
   			&& _resistencePrices[k] > pPrice
   		)
   	{
   		tmpNextSRLine = _resistencePrices[k];
   		break;
   	}
   }   
   if (tmpNextSRLine > 0.0)
   {   	
   	return (tmpNextSRLine);
   }
   
   return (100);	//lazy b.s.
}

//crazy but...
//subtract entry from S/R level divide by 2 and you get a reasonable TP
//TODO: if you get stopped out try one more time
double getAdjustedTP(double pPrice)
{
	int foo = ArraySort( _resistencePrices, WHOLE_ARRAY, 0, MODE_ASCEND);
	int tmpArraySize = ArraySize(_resistencePrices);
	double tmpNextSRLine = 0.0;
	for(int k=0;k<tmpArraySize;k++)
   {
   	if (	
   			_resistencePrices[k] > 0
   			&& _resistencePrices[k] > pPrice
   		)
   	{
   		tmpNextSRLine = _resistencePrices[k];
   		break;
   	}
   }
   
   if (tmpNextSRLine > 0.0)
   {
   	return ( ((tmpNextSRLine - pPrice) / 2) + pPrice);
   }
   
   //return the default TP
   return (_bid+_takeProfitFactor*(10*_point));	
   
}

//13 works good
//if price is within  N pips of known resistence, do not enter trade
int _resistenceZone = 13;
int _resCounter = 0;
void printResistenceLevels(double pPrice, datetime pDate)
{
	int tmpArraySize = ArraySize(_resistencePrices);
   
   for(int k=0;k<tmpArraySize;k++)
   { 
			int tmpShift = iBarShift(Sym, PERIOD_M5, pDate, true);
			int tmpTime = iTime(Sym, PERIOD_M5, tmpShift);
			ObjectCreate("resistencebuysellline"+_resCounter,OBJ_ARROW,0,tmpTime, _resistencePrices[k]);
         ObjectSet("resistencebuysellline"+_resCounter, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
         ObjectSet("resistencebuysellline"+_resCounter,OBJPROP_COLOR,Yellow); 
			_resCounter++;
   }
}


int _supportZone = 13;
int _supCounter = 0;
void printSupportLevels(double pPrice, datetime pDate)
{
	int tmpArraySize = ArraySize(_supportPrices);
   
   for(int k=0;k<tmpArraySize;k++)
   { 
			int tmpShift = iBarShift(Sym, PERIOD_M5, pDate, true);
			int tmpTime = iTime(Sym, PERIOD_M5, tmpShift);
			ObjectCreate("supportbuysellline"+_supCounter,OBJ_ARROW,0,tmpTime, _supportPrices[k]);
         ObjectSet("supportbuysellline"+_supCounter, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
         ObjectSet("supportbuysellline"+_supCounter,OBJPROP_COLOR,Aqua); 
			_supCounter++;
   }
}


int getNumberOfResistenceLevels()
{
	int tmpArraySize = ArraySize(_resistencePrices);
	int tmpRezCount = 0;
   
   for(int k=0;k<tmpArraySize;k++)
   { 
			if( _resistencePrices[k] > 1 &&  _resistencePrices[k] < 100)
			{
			   tmpRezCount++;
			}
   }
   return (tmpRezCount);
}


//if price is within N pips of resistence, do not enter trade 
bool imminentResistence(double priceToTest)
{
   int tmpArraySize = ArraySize(_resistencePrices);
   
   for(int k=0;k<tmpArraySize;k++)
   {
      if (     		
      		_resistencePrices[k] - priceToTest <= _resistenceZone*(10*Point)     
      		&& _resistencePrices[k] - priceToTest > 0.0 
      		//and we're not sitting in a nest of rez prices
      		&& priceToTest - _resistencePrices[k] > 5*(10*Point)
      	)
      {  
         
         return (true);
      }
   }

   return (false);
}

int RefreshBidsAndAsks()
{
   RefreshRates();
   _bid   =MarketInfo(Sym,MODE_BID); // Request for the value of Bid
   _ask   =MarketInfo(Sym,MODE_ASK); // Request for the value of Ask
   _point =MarketInfo(Sym,MODE_POINT);//Request for Point   
   _minDist=MarketInfo(Sym,MODE_STOPLEVEL);// Min. distance
   return (0);
}


int recentStandardDeviationCrossing(int pLookback, int pMaPeriod, double pLevel, int pIndex)
{
   int counter = 0;

   if (  iStdDev(NULL, 5, pMaPeriod, 0, MODE_SMA, PRICE_CLOSE, pIndex) >= pLevel  ) //is latest price above
   {
      for (int z=2;z<=pLookback;z++)
      { 
         if (iStdDev(NULL, 5, pMaPeriod, 0, MODE_SMA, PRICE_CLOSE, z+pIndex) <= pLevel) //was recent price below
         {
            counter = 1;
            break;
         }
      }
   }
   else
   {
      return (0);
   }


   if (counter > 0)
   {
      return (1);
   }
   else
   {
      return (0);
   }
}

int candleSpreadGreaterThanNPips(double pHigh, double pLow, double pSpread)
{
   double spread1 = MathAbs(pHigh - pLow); //removes negative number
   
   if (pSpread > spread1)
   {
      return (1);
   }
   else
   {
      return (0);
   }
}

int lastLowInOpenAir(double priceToTest, int pLookback, int pIndex)
{

   int counter = 0;
   //start at 2 because we are always passing in the +1 candle
   for (int z=2;z<=pLookback;z++)
   {                
      if (priceToTest >= iLow(NULL,5,z+pIndex))
      {    
         ObjectCreate("buysellMissedOpp"+_labelIndex,OBJ_TEXT,0,Time[z+pIndex],priceToTest);
         ObjectSetText("buysellMissedOpp"+_labelIndex,"x",14,"Arial",Aqua); 
       
         counter = 1;
         break;
      }
   }
   
   if (counter > 0)
   {
      return (0);
   }
   else
   {
      return (1);
   }
}

int lastHighInOpenAir(double priceToTest, int pLookback, int pIndex)
{
   int counter = 0;
   //start at 2 because we are always passing in the +1 candle
   for (int z=2;z<=pLookback;z++)
   {  
      if (priceToTest <= iHigh(NULL,5,z+pIndex))
      {
      
         ObjectCreate("buysellMissedOpp"+_labelIndex,OBJ_TEXT,0,Time[z+pIndex],priceToTest);
         ObjectSetText("buysellMissedOpp"+_labelIndex,"x",14,"Arial",Orange); 
         
         counter = 1;
         break;
      }
   }
   
   if (counter > 0)
   {
      return (0);
   }
   else
   {
      return (1);
   }
}



bool isCandleTopExtraWicky(double pOpen, double pClose, double pHigh, double pLow)
{
   if (
         (pClose > pOpen && pClose - pOpen <= (pHigh - pLow)/3)
         ||
         (pClose < pOpen && pOpen - pClose <= (pHigh - pLow)/3)
		 )
		 {
         return (true);
       }
       else
       {
         return(false);
       }
}


