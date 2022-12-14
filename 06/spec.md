

### mod7の消費リソース

|     | バイナリサイズ<br>[byte] | 呼び出し１回辺りの<br>平均クロック |
|-----|-----------:|---------:|
|テーブル256|	259	|   12.0|
|テーブル130|	143	|   48.0|
|テーブル67|	86	|   66.1|
|if＆引き算|	40	|   117.8|
|掛け算&シフト|	38	|   198.0|
|ネットの    |	34	|   351.2|
|ネットの<br>を最適化    |	32	|   141.8|
|ネットの<br>+テーブル39    |	51	|   54.0|
|ネットの<br>+引き算<br>+テーブル21    |	39	|   71.7|
|ネットの<br>を最適化2    |	15	|   120.1|
|引き算ループ|  12 |    474.9|

### mod7の消費リソース[%]

|     | バイナリサイズ<br>/4K[%] | 呼び出し１回辺りの<br>平均クロック/15K[%] |
|-----|-----------:|---------:|
|テーブル256|	6.3	|   0.1|
|テーブル130|	3.5	|   0.3|
|テーブル67|	2.1	|   0.4|
|if＆引き算|	1.0	|   0.8|
|掛け算&シフト|	0.9	|   1.3|
|ネットの    |	0.8	|   2.3|
|ネットの<br>を最適化    |	0.8	|   0.9|
|ネットの<br>+テーブル39    |	1.2	|   0.4|
|ネットの<br>+引き算<br>+テーブル21    |	1.0	|   0.5|
|ネットの<br>を最適化2    |	0.4	|   0.8|
|引き算ループ|  0.3 |    3.2|

- バイナリサイズは4Kからの割合[%]
- クロックは15Kからの割合[%]


### 生データからmod7の消費リソースだけ切り出した表

|     | バイナリサイズ<br>[byte] | クロック |
|-----|-----------:|---------:|
|空	      |     0 |    0|
|テーブル256|	259	|   3072|
|テーブル130|	143	|   12300|
|テーブル67|	86	|   16920|
|if＆引き算|	40	|   30144|
|掛け算&シフト|	38	|   50688|
|ネットの    |	34	|   89904|
|ネットの<br>を最適化    |	32	|   36312|
|ネットの<br>+テーブル39    |	51	|   13824|
|ネットの<br>+引き算<br>+テーブル21    |	39	|   18360|
|ネットの<br>を最適化2    |	15	|   30750|
|引き算ループ|  12 |    121584|

- クロックはr0に0~255を渡してループしたときの合計値

### 生データ

|     | binサイズ<br>[byte] | クロック |
|-----|-----------:|---------:|
|空	      |     78 |    8478|
|テーブル256|	337	|   11550|
|テーブル130|	221	|   20778|
|テーブル67|	164	|   25398|
|if＆引き算|	118	|   38622|
|掛け算&シフト|	116	|   59166|
|ネットの    |	112	|   98382|
|ネットの<br>を最適化    |	110	|   44790|
|ネットの<br>+テーブル39    |	129	|   22302|
|ネットの<br>+引き算<br>+テーブル21    |	117	|   26838|
|ネットの<br>を最適化2    |	93	|   39228|
|引き算ループ|  90 |    130062|
