# MQL4-UnitTest
MQL4 Unit testing mudle.  


## Description
MT4 has varous environment for each accounts.  
In order to check whether it works correctly in all environments, it is necessary to install the created file in multiple MT4 and test it.  
It takes a lot of time.  
Therefore, in order to test a plurality of environments collectively, the environment setting file is used.

First, describe the difference for each account in the environment setting file.  
The UnitTest class read the configuration file in order and repeated the test.　　
The loaded value is reflected to the definition value by MQL4-Env.  
As a result, functions created using predetermined definition values can be tested together in a plurality of environments.  
example: \_Symbol -> \_\_Symbol


## Requirement
- [MQL4-Env](https://github.com/KeisukeIwabuchi/MQL4-Env)


## Install
1. Download UnitTest.mqh
2. Save the file to /MQL4/Includes/mql4_modules/UnitTest/UnitTest.mqh


## Usage
At first, Crate the file for unit testing and include UnitTest.mqh.  
Once you have created an object of class UnitTest it is ready.  

To check a single value, pass the execution result of the function you want to check and the expected value of the result to the TestValue method.  
`test.TestValue(result, expected);`  
If the execution result is an array, use the TestArray method. 


When the execution result is double type or float type, errors may occur.  
In that case, you can specify the number of decimal places in the first argument.  
`test.TestValue(3, result, expected);`   
 
Repeat the above process, delete the created object after confirming all the patterns.  
Output the result. 

When creating an object, you can specify the test name as the first argument and the path of the configuration file as the second argument.  
The second argument is optional, and if omitted, the environment setting file is not used and the test is executed with the information of the current account.  

``` cpp
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
```
