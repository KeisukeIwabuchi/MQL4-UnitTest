# MQL4-Unit-Test
MQL4で単体テストをするためのモジュール  
関数単位で実行結果と予想値が一致しているかを確認するのに使用する。  


## Description
MT4は口座毎に様々な環境がある。  
全ての環境で正しく動作するかを確認するには、作成したファイルを複数のMT4に設置してテストする必要があり、非常に手間がかかる。  
そこで複数の環境を一括でテストするために、環境設定ファイルを使用する。  

まず口座ごとの違いを環境設定ファイルに記述しておく。  
UnitTestクラスは設定ファイルを順に読み込み、テストを繰り返す。  
読み込まれた設定は、MQL4-Envによって定義値へと反映される。  
これにより所定の定義値を使って作られた関数を、複数の環境で一括にテストすることができる。  
例) \_Symbolの代わりに、\_\_Symbolを使う


## Requirement
- [MQL4-Env](https://github.com/KeisukeIwabuchi/MQL4-Env)


## Install
1. UnitTest.mqhをダウンロード
2. データフォルダを開き、/MQL4/Includes/mql4_modules/UnitTest/UnitTest.mqhとして保存


## Usage
まず単体テスト用のファイルを作成して、UnitTest.mqhを読み込みます。  
UnitTestクラスのオブジェクトを作成したら準備完了です。  

単一の値の確認を行うには、TestValueメソッドにチェックしたい関数の実行結果と、結果の想定値を渡します。  
`test.TestValue(result, expected);`   
実行結果が配列の場合は、TestArrayメッソドを使用します。  

実行結果がdouble型やfloat型の場合、誤差が発生する可能性があります。  
その場合は第一引数に、小数点以下の桁数を指定することができます。  
`test.TestValue(3, result, expected);`   
   
上記の処理を繰り返し、全パターンの確認が完了したら作成したオブジェクトをdeleteして下さい。  
結果がターミナルのエキスパートタブへ出力されます。

オブジェクトを作成する際に、第一引数にテスト名を、第二引数に環境設定ファイルのパスを指定できます。  
第二引数は省略可能で、省略した場合は環境設定ファイルは使用せず、現在の口座の情報でテストが実行されます。

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
