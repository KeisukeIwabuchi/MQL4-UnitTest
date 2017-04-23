/** defines */
#define IS_DEBUG 

/** Include header files. */
#include <defines.mqh>
#include <Env.mqh>


/**
 * 単体テスト用クラス
 * 実行結果と予想値の比較をおこなう。
 */
class UnitTest
{
   /** properties */
   private:
      /** @var string test_name 単体テスト名 */
      string test_name;
      
      /** @var int passed テスト成功回数 */
      int passed;
      
      /** @var int failed テスト失敗回数 */
      int failed;
      
      /** @var string file_path テスト用環境フォルダのパス */
      string file_path;
       
      /** @var string files[] テスト用環境フォルダ内のファイル名一覧 */
      string files[];
       
      /** @var int index 現在読み込んだファイルの数 */
      int index;
      
      /** @var int max 1ファイルあたりのテストの回数 */
      int max;
      
      /** @var string last_load_file 最後に読み込んだ環境ファイルの名前 */
      string last_load_file;
   
   /** methods */
   public:
      UnitTest(const string name = "", const string path = "");
      ~UnitTest(void);
      
      template<typename T>
      void TestValue(T result, T expected);
      void TestValue(int digits, double result, double expected);
      void TestValue(int digits, float result, float expected);
      
      template<typename T>
      void TestArray(T &result[], T &expected[]);
      void TestArray(int digits, double &result[], double &expected[]);
      void TestArray(int digits, float &result[], float &expected[]);
      
      bool loadNextEnvFile(void);
      
   private:
      void printSuccessMessage(void);
      template<typename T>
      void printErrorMessage(T result, T expected);
      void printArraySizeErrorMessage(int result_size, int expected_size);
};


/**
 * 単体テストを開始する
 * pathが指定されている場合は環境ファイルを読み込む
 *
 * @param const string name テスト名
 * @param const string path 環境ファイルへのが保存されているフォルダ
 */
UnitTest::UnitTest(const string name = "", const string path = "")
{
   this.test_name = name;
   this.passed         = 0;
   this.failed         = 0;
   this.file_path      = path;
   this.index          = 0;
   this.max            = 0;
   this.last_load_file = "";
   
   /** pathが指定された場合の処理 */
   if(StringLen(this.file_path) > 0) {
      long   handle    = 0;
      string file_name = "";
      int    count     = 0;
   
      handle = FileFindFirst(this.file_path + "\\*", file_name);
      
      if(handle != INVALID_HANDLE) {
         /** 1件目の環境ファイルを読み込む */
         Env::loadEnvFile(this.file_path + "\\" + file_name);
         this.last_load_file = file_name;
      
         /** 環境ファイルの一覧をthis.files[]に入れる */
         do {
            ResetLastError();
            FileIsExist(file_name);
            
            /** ファイルではなくフォルダであればスキップ */
            if(GetLastError() == ERR_FILE_IS_DIRECTORY) continue;
            
            ArrayResize(this.files, count + 1);
            this.files[count] = file_name;
            count++;
         }
         while(FileFindNext(handle, file_name));
      }
   }
   
   Print("*------------------ Unit Test Start ------------------*");
}


/**
 * 単体テストを終了し、結果を出力する
 */
UnitTest::~UnitTest(void)
{
   if(this.failed == 0) {
      Print("UnitTest : ", this.test_name, " PASSED! ",
            this.passed, " tests are successful.");
   }
   else {
      Print("UnitTest : ", this.test_name, " FAILED. ",
            this.passed, "/", (this.passed + this.failed), 
            " tests are successful.");
   }
   
   Print("*------------------- Unit Test End -------------------*");
   PlaySound("news.wav");
}


/**
 * resultとexpectedの値を比較する
 * 構造体をチェックしたいときは個別にTestValueに渡して使用
 *
 * @param typename result テスト対象となる処理の実行結果
 * @param typename expected 結果の予想値
 *
 * @return bool true:一致, false:不一致
 */
template<typename T>
void UnitTest::TestValue(T result, T expected)
{
   if(result != expected) {
      UnitTest::printErrorMessage(result, expected);
      return;
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * resultとexpectedの値を比較する
 * 構造体をチェックしたいときは個別にTestValueに渡して使用
 *
 * @param int digits 小数点以下の桁数
 * @param double result テスト対象となる処理の実行結果
 * @param double expected 結果の予想値
 *
 * @return bool true:一致, false:不一致
 */
void UnitTest::TestValue(int digits, double result, double expected)
{
   if(NormalizeDouble(result, digits) != NormalizeDouble(expected, digits)) {
      UnitTest::printErrorMessage(result, expected);
      return;
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * resultとexpectedの値を比較する
 * 構造体をチェックしたいときは個別にTestValueに渡して使用
 *
 * @param int digits 小数点以下の桁数
 * @param float result テスト対象となる処理の実行結果
 * @param float expected 結果の予想値
 *
 * @return bool true:一致, false:不一致
 */
void UnitTest::TestValue(int digits, float result, float expected)
{
   if(NormalizeDouble(result, digits) != NormalizeDouble(expected, digits)) {
      UnitTest::printErrorMessage(result, expected);
      return;
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * resultとexpectedの値を比較する
 *
 * @param typename &result[] テスト対象となる処理の実行結果
 * @param typename &expected[] 結果の予想値
 *
 * @return bool true:一致, false:不一致
 */
template<typename T>
void UnitTest::TestArray(T &result[], T &expected[])
{
   if(ArraySize(result) != ArraySize(expected)) {
      UnitTest::printArraySizeErrorMessage(ArraySize(result), 
                                           ArraySize(expected));
      return;
   }
   
   for(int i = 0; i < ArraySize(result); i++) {
      if(result[i] != expected[i]) {
         UnitTest::printErrorMessage(result[i], expected[i]);
         return;
      }
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * resultとexpectedの値を比較する
 *
 * @param int digits 小数点以下の桁数
 * @param double &result[] テスト対象となる処理の実行結果
 * @param double &expected[] 結果の予想値
 *
 * @return bool true:一致, false:不一致
 */
void UnitTest::TestArray(int digits, double &result[], double &expected[])
{
   double value1, value2;

   if(ArraySize(result) != ArraySize(expected)) {
      UnitTest::printArraySizeErrorMessage(ArraySize(result), 
                                           ArraySize(expected));
      return;
   }
   
   for(int i = 0; i < ArraySize(result); i++) {
      value1 = NormalizeDouble(result[i], digits);
      value2 = NormalizeDouble(expected[i], digits);
      
      if(value1 != value2) {
         UnitTest::printErrorMessage(value1, value2);
         return;
      }
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * resultとexpectedの値を比較する
 *
 * @param int digits 小数点以下の桁数
 * @param float &result[] テスト対象となる処理の実行結果
 * @param float &expected[] 結果の予想値
 *
 * @return bool true:一致, false:不一致
 */
void UnitTest::TestArray(int digits, float &result[], float &expected[])
{
   float value1, value2;

   if(ArraySize(result) != ArraySize(expected)) {
      UnitTest::printArraySizeErrorMessage(ArraySize(result), 
                                           ArraySize(expected));
      return;
   }
   
   for(int i = 0; i < ArraySize(result); i++) {
      value1 = (float)NormalizeDouble(result[i], digits);
      value2 = (float)NormalizeDouble(expected[i], digits);
      
      if(value1 != value2) {
         UnitTest::printErrorMessage(value1, value2);
         return;
      }
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * 次の環境ファイルを読み込む
 *
 * @return bool true:成功, false:失敗（全件読み込み完了済み）
 */
bool UnitTest::loadNextEnvFile(void)
{
   this.index++;
   if(this.index >= ArraySize(this.files)) return(false);

   Env::loadEnvFile(this.file_path + "\\" + this.files[this.index]);
   this.last_load_file = this.files[this.index];
   
   if(this.max == 0) this.max = this.passed + this.failed;
   
   return(true);
}


/** 成功数を1増やし、メッセージを出力する。 */
void UnitTest::printSuccessMessage(void)
{
   this.passed++;
   
   if(StringLen(this.last_load_file) > 0) {
      int num = (this.passed + this.failed);
      while(num > this.max && this.max > 0) {
         num -= this.max;
      }
      Print("Test #", (this.index + 1), "-", num, " Passed!");
   }
   else {
      Print("Test #", (this.passed + this.failed), " Passed!");
   }
}


/** 
 * 失敗数を1増やし、メッセージを出力する。
 *
 * @param typename result 結果値
 * @param typename expected 予想値
 */
template<typename T>
void UnitTest::printErrorMessage(T result,T expected)
{
   this.failed++;
   
   if(StringLen(this.last_load_file) > 0) {
      int num = (this.passed + this.failed);
      while(num > this.max && this.max > 0) {
         num -= this.max;
      }
      Print("Test #", (this.index + 1), "-", num, " Failed. ",
            result, " instead of ", expected, ". ", 
            "Env File = ", this.last_load_file);
   }
   else {
      Print("Test #", (this.passed + this.failed), " Failed. ",
            result, " instead of ", expected, ". ", 
            "Env File = ", this.last_load_file);
   }
}


/** 
 * 失敗数を1増やし、メッセージを出力する。
 *
 * @param int result _size 結果配列の要素数
 * @param int expected_size 予想値配列の要素数
 */
void UnitTest::printArraySizeErrorMessage(int result_size, int expected_size)
{
   this.failed++;
   
   if(StringLen(this.last_load_file) > 0) {
      int num = (this.passed + this.failed);
      while(num > this.max && this.max > 0) {
         num -= this.max;
      }
      Print("Test #", (this.index + 1), "-", num, " Error. ",
            "Array size ", result_size, " instead of ", expected_size, ". ",
            "Env File = ", this.last_load_file);
   }
   else {
      Print("Test #", (this.passed + this.failed), " Error. ",
            "Array size ", result_size, " instead of ", expected_size, ". ",
            "Env File = ", this.last_load_file);
   }
}
