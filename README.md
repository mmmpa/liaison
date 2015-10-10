# liaison

CGIとして動くRubyをつかった簡易メールフォーム。

リッチなライブラリをふんだんに使っているので、とてもおもい。

# Usage

## ファイル配置

app以下をhttpアクセスで表示出来ない場所に配置。

public以下をrubyをcgiで動かせる場所に配置。

index.rbとready.rbの

```ruby
require(Pathname.new(__dir__) + "../app/app.rb")
```

のパスをapp/app.rbに通す。

## 設定

app/configuration/configurtaion.yamlの内容を変更。

## 表示

configurtaion.yamlのtemplateで指定したHTMLを編集。

ERBで動く。

## データベース準備

設定が終わればready.rbにアクセス。

データベースのテーブルが作成されたのを確認してready.rbは削除。

# メールはどうなるか

configurtaion.yamlのmail項目の内容に従って送信されるほか、databaseにも保持される。
