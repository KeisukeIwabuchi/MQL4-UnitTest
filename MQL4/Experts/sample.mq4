#property strict

#include <UnitTest.mqh>


UnitTest *test;


int OnInit(){
   double result = 0, expected = 0;

   test = new UnitTest("Test MoneyManagement module MMStep method",
                       "UnitTest");
   
   do {
      // 1. normal value (max > value > min)
      result = checkLots(1.0);
      expected = 1.0;
      test.TestValue(2, result, expected);
      
      // 2. value > max
      result = checkLots(20);
      expected = __MAXLOT;
      test.TestValue(2, result, expected);
      
      // 2. value < min
      result = checkLots(0.001);
      expected = __MINLOT;
      test.TestValue(2, result, expected);
   }
   while(test.loadNextEnvFile());
   
   delete(test);

   return(INIT_SUCCEEDED);
}


void OnTick(){
   
}


double checkLots(double lots)
{
   int    digits    = 0;
   int    remainder = 0;
   int    lots_int  = 0;
   double max       = __MAXLOT;
   double min       = __MINLOT;
   double step      = __LOTSTEP;

   while(step < 1) {
      step *= 10;
      digits++;
   }
   
   lots_int  = (int)(lots * MathPow(10, digits));
   remainder = lots_int % (int)MathFloor(step);
   if(remainder != 0) {
      lots = __LOTSTEP *  MathFloor((lots_int - remainder) / (int)MathFloor(step));
   }
   
   if(lots > max) lots = max;
   if(lots < min) lots = min;
   
   return(NormalizeDouble(lots, digits));
}