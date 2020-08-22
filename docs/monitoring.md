# 監視

ここではデプロイしたアプリケーションの状態を確認できる方法を紹介します。
必要に応じて読んでください。

みなさんが ECS 上で実行するのは普通のアプリケーションのデプロイ(hako deploy)、そして単発のコード実行(hako oneshot)があります。
前者は ECS Service という形で、後者は ECS Task という形で動いています。

- ECS Service 一覧: <https://ap-northeast-1.console.aws.amazon.com/ecs/home?region=ap-northeast-1#/clusters/hako-fargate/services>
- ECS Tasks 一覧: <https://ap-northeast-1.console.aws.amazon.com/ecs/home?region=ap-northeast-1#/clusters/hako-fargate/tasks>

## ECS サービス

### ログ

一覧で自分が見たいサービスをクリックするとサービスの詳細が出てきます。
`https://ap-northeast-1.console.aws.amazon.com/ecs/home?region=ap-northeast-1#/clusters/hako-fargate/services/<サービス名>/details`

どのクラスタで動いてるか、どの Task definition を使っているかとか、いろんな情報が乗ってると思います。
その下にはいくつかのタブが見えますが、そこから `Logs` を選択します。

`Select a container to view logs :` でみたいコンテナを選択します。
そうするとログが確認できます。

## ECS タスク

タスクの注意点としては、ログを見ようと思ったタイミングではすでにタスクが終了している場合が多いことです。
クラスタのタスク一覧は現在動いているものしかみせてくれないので、一覧からみたいタスクのステータス(`Desired task status`)を `Stopped` に変更する必要があります。

### ログ

ECS サービスと同様に一覧からみたいタスクを探します。
詳細画面に `Logs` というタブがあるのでそれを選択します。

`Select a container to view logs :` でみたいコンテナを選択します。
そうするとログが確認できると思います。

## CloudWatch Metrics

<https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/working_with_metrics.html>

AWS はあらゆるメトリクスを CloudWatch Metrics という機能を利用して記録しています。
これには ECS サービスの動作状況などを含め、 ELB のメトリクス(レイテンシー、コネクションの数、リクエストの数)などが含まれます。

`https://ap-northeast-1.console.aws.amazon.com/cloudwatch/home?region=ap-northeast-1#metricsV2:graph=~()`

このページの検索フィールドに自分の IAM username を入れてみましょう
今回のハンズオンではあらゆるリソースに username を付けているので自分が作ったほぼすべてのリソースのメトリクスが検索されると思います。
必要によって参考してください。
