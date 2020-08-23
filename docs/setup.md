# AWS アカウントのセットアップ

## マネジメントコンソールへのアクセス

共有されている AWS コンソール url にアクセスします。
IAM user name には自分のユーザ名、Password には `Saikoun0-$ummer-internship` を入力します。
ユーザー名はみなさんが提出してくださった GitHub アカウント名を小文字に変換し、`-` を `_` に置き換えたものになります。
例えば、 GitHub アカウント名が Rise-Shia ならログインユーザー名は rise_shia になります。
今後、ユーザー名と言われてるのはすべてこの小文字に変換したものを指します。

次にパスワードリセットを促されます。
Old password には同様に `Saikoun0-$ummer-internship`, New Password と Retype new password には次のパスワードポリシーに従ったパスワードを入力して次に進みます。

- 20 文字以上
- 最低 1 文字以上は小文字アルファベット
- 最低 1 文字以上は大文字アルファベット
- 最低 1 文字以上は数字
- 最低 1 文字以上は記号

ログインに成功するとコンソール画面が見えます。

# 作業インスタンスのセットアップ

コンソールにアクセス可能になったので、次は作業用インスタンスにアクセスしてみましょう。

## 作業インスタンスとは

ハンズオンを手軽く進めるための EC2 インスタンスです。このインスタンスは以下のようなものを提供します。

- ハンズオンに必要な AWS リソースへの操作権限
- 開発に必要な各種の依存性(i.e. Ruby, MySQL, ...)

中身に関しては別途のページを用意したので興味があれば、もしくは疑問点ができた時に読んでください。
[作業インスタンスに関して](workspace)

## 作業インスタンスの確認

<https://ap-northeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#Instances:sort=instanceId>

EC2 コンソールにアクセスしてみるといくつかのインスタンスが起動していることがわかります。
その中から名前が自分の Github アカウント名になってるインスタンスを探し、 `Public DNS` を確認してください。
以下のような形式でできています。

```
ec2-xxx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com
```

## ssh config 設定

`~/.ssh/config` に、インスタンスにログインするための設定を追加します。

```
Host cookpad-summer-internship-2020
  User ubuntu
  HostName ec2-xxx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com
  Port 22
  IdentityFile <GitHub アカウントに登録している公開鍵の一つの秘密鍵のパス>
```

できたら ssh 接続できるのか確認しましょう。

```
$ ssh cookpad-summer-internship-2020
```

ログインができたら成功です。

### Troubleshooting

接続ができない場合、以下を順番に確認してください。

- 自分用のインスタンスの Public DNS を指定しているか
- GitHub に公開鍵を登録しており、 `https://github.com/<アカウント>.keys` からその公開鍵が確認できるか
- それらの一つに対応する正しい秘密鍵を使っているか
- インスタンスを再起動してみてください。インスタンスをクリックし、 Actions -> Instance State -> Reboot で再起動できます
- それでも駄目なら講師か TA に相談してください

## VSCode Remote 設定

まず Remote Development の Extension を入れます。

その後、左タブの Remove Explorer アイコンをクリックするとタブが開きます。そこの SSH TARGETS から、さきほど `~/.ssh/config` に追加した cookpad-spring-internship-2020 を探し、
右クリックして `Connect to Host in Current Window` を選択します。もしくは、右の `+` マークのついた窓のアイコンをクリックすると、別ウィンドウで開くこともできます。

## 作業インスタンスでの準備

### Git ユーザーの設定

まず git user の設定を済ませておきましょう。

```
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

# コードの準備

## レポジトリクローン

ssh 接続して、もしくは VS Code を利用してレポジトリを clone します。
レポジトリの情報は以下になります。

- web: `https://ap-northeast-1.console.aws.amazon.com/codesuite/codecommit/repositories/<iam username>/browse?region=ap-northeast-1`
- clone url: `https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/<iam username>`

<https://ap-northeast-1.console.aws.amazon.com/codesuite/codecommit/repositories?region=ap-northeast-1> から探してもいいです。

```bash
cd ~
git clone https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/<iam username> tinypad
```

クローンができたら Explorer アイコン(左上)をクリックし、 Open Folder を選択し、クローンしたディレクトリを選択し OK を右クリックましょう。
そうするとディレクトリが開き、編集可能な状態になります。

### スクリプトの実行

今後いろんなスクリプトを実行していくのですが、これはターミナルを開きそこから SSH 接続してもいいし、 VS Code を利用してもよいです。
後者の場合、VS Code をリモートにつないでる状態でターミナルを開くと自動で接続中のサーバのターミナルが開きますので参考にしてください。

## アプリケーションの環境設定

クローンしてきたレポジトリで `bin/setup` を実行します。

実行が完了したらサーバを起動してみましょう。ターミナルで `bin/rails server` でサーバを立ち上げます。
デフォルトとして 3000番のポートが利用されます。サーバは作業用インスタンスで起動しているので、そのサーバの 3000番ポートにアクセスする必要があります。
そのためにポートフォワーディングを設定しましょう。

VS Code の左タブから Remote Explorer アイコンを右クリックし、左下から FORWARDED PORTS というパネルが出ます。
「Forward a Port...」もしくは、右の `+` マークをクリックし、 `3000` を入力しましょう。
エンターを押すと、 3000 -> localhost:3000 という設定が見えるようになります。

ブラウザから <http://localhost:3000> にアクセスしてみましょう。
不格好なトップページが出てきたら成功です。

### 初期データを追加してみる

データが何もないと寂しいので用意されてる開発用のデータを入れてみましょう。

```bash
bin/rails db:seed
```

このスクリプトは `db/seed.rb` というスクリプトを実行します。
実装は普通の Rails コードでいくつかのデータを development 環境のデータベースに流し込みます。
これを実行した後、改めてプラウザからアクセスしてみると色々データが増えてるのがわかると思います。

### `bin/setup` は

必要な依存性を設定したり、開発用のデータベースを設定したりします。
詳細は該当スクリプトを読んでください。

### ポートフォワーディングとは

特定ポートへの通信を別のアドレスのポートへ自動的に転送することを指します。
今回は手元からのアクセスを許可するために各 EC2 には Public IP が紐付いていますが、開発環境のポートをむやみにインターネットに公開するのは危険です。
ですので今回はウェブサーバのポートを直接公開せず、こういった方法で手元からのみアクセスできるようにしています。
