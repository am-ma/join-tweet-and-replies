# TwitterHistory(join-tweet-and-replies)
twitter公式からDLできる履歴（のうちtweets.jsをJSONに加工したもの）を加工するためのプログラムです。
tweetとそれにぶら下がるリプライを一続きの文字列にし、てきとうなCSVファイルにして出力。
主に自分用。

## 加工前後

```
ツイート
-------
@hogehoge #test1 #test2
これはリプ
```

↓

```
ツイート
これはリプ
```