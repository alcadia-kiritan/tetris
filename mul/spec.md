### mul8の消費リソース

|                | 1回辺りの<br>クロック | binサイズ<br>[byte] |
|-----|-----------:|---------:|
|mul.asm        |	315.0 |	65|
|mul2.asm	    |   438.0 |	22|
|mul3.asm	    |   397.5 |	24|
|mul_table.asm  |	379.4 |	348|
|mul_net.asm    |	152.3 |	1082|
|mul_simple.asm |	2,746.5 |	18|

クロックは全パターン(0x00～0xFF x 0x00～0xFF)での平均値. 

### 生データ

|                | クロック | binサイズ<br>[byte] |
|-----|-----------:|---------:|
|空	            |   27934701 |	327 |
|mul.asm        |	48578541 |	392|
|mul2.asm	    |   56639469 |	349|
|mul3.asm	    |   53986797 |	351|
|mul_table.asm  |	52797465 |	675|
|mul_net.asm    |	37918161 |	1409|
|mul_simple.asm |	207929325 |	345|

### メモ
ここでのmul8 は,符号なし8bit x 符号なし8bit = 符号なし16bit.  
1Kのバイナリサイズが飲めるなら_netで、そうでないなら無印がベターか.  

- 無印  
よくあるタイプ
- 2  
よくあるタイプをループにしたやつ
- 3    
シフト時のキャリーで分岐してみたやつ.  
- table   
4bit x 4bitのテーブルに還元したやつ. シフト多くてダメ  
x * y  = a*c*2^8 + (a*d + b*c)*2^4 + b*d  
  x = a * 2^4 + b  
  y = c * 2^4 + d   

- net  
下記の末尾にある奴を実装  
f(x) = x^2 / 4  
としてf(x)をテーブル化しておき  
a*b を f(a+b) - f(a-b) で計算  
https://www.msxcomputermagazine.nl/mccw/92/Multiplication/en.html  
- simple  
単純ループ