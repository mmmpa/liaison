# liaison

CGIとして動くRubyをつかった簡易メールフォーム。

Heroku上ではSinatraで稼働する。

# Usage

## CGIとしてのファイル配置

app以下をhttpアクセスで表示出来ない場所に配置。

public以下をrubyをcgiで動かせる場所に配置。

index.rbの

```ruby
require(Pathname.new(__dir__) + "../app/app.rb")
```

のパスをapp/app.rbに通す。

## 設定

app/configuration/configurtaion.yamlの内容を変更。

## 表示

configurtaion.yamlのtemplateで指定したHTMLを編集。

ERBで動く。

## トークンディレクトリ用意

configurtaion.yamlのstore tokenに設定したディレクトリを作成しておく。

# メールはどうなるか

configurtaion.yamlのmail項目の内容に従って送信される。

環境変数でSendGriアカウントを設定するか、mailer.rbを書き換える。
