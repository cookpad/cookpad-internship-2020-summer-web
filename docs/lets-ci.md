# Let's ci

ここでは継続的なデプロイのための環境を構成してみます。

## ゴール

- Git push から CI テストをし、Docker イメージを作り、 ECR にプッシュする、そのあとは staging 環境にデプロイするパイプラインを作成する
- staging 環境の動作を確認し、 production 環境にデプロイをする

## 入る前に

まず CodeBuild プロジェクトを作る前にまず hako 定義を用意しましょう。
レポジトリの `hako/` の下にはすでに定義が用意されてるのでそれを使いましょう。

- `hako/tinypad-staging.jsonnet.example` を `hako/<iam username>-staging.jsonnet` にリネームしてください。
- `hako/tinypad-production.jsonnet.example` を `hako/<iam username>-production.jsonnet` にリネームしてください。

そして適切なコミットメッセージと一緒にコミットしてください。
レポジトリ側にプッシュするのも忘れずに。

定義の詳細に関してはファイルに書かれてるので必要なタイミングで読んでください。

## パイプラインの作成

さて、パイプラインは以下のような仕事をする必要があります。

- テストを実行する
- Docker イメージを作り、 ECR にプッシュする
- プッシュしたイメージを利用し staging 環境にデプロイする

各作業を 1 CodeBuild プロジェクトとして扱いましょう。
やることは独立しているし、その方が扱いやすいからです。

### テスト用プロジェクトを作る

CodeBuild -> Build projects 画面で `Create build project` を右クリックします。
以下、必須の設定を書きます

- Project configuration
  - Project name: `<iam username>-test`
- Source
  - Source provider: AWS CodeCommit
  - Repository: `<iam username>`
  - Reference type: Branch
  - Branch: master
- Environment
  - Environment image: Managed image
  - Operating system: Ubuntu
  - Runtime: Standard
  - Image: aws/codebuild/standard:4.0
  - Image version Always use latest image for this runtime version
  - Environment type: Linux
  - Privileged: true(チェックを入れてください)
  - Service role: Existing service role
  - Role ARN: CodeBuildServiceRole を選択
  - Allow AWS CodeBuild this service role: **false**
    - **忘れずチェックを外してください**
- Buildspec
  - Build specifications: Use a buildspec file
  - Buildspec name: buildspec.rspec.yml
- Artifacts
  - Additional configuration を右クリックして展開する
  - Cache type: Local
  - Custom cache をチェック

作られたら試しに Start Build してみましょう。実行時に聞かれる設定はデフォルトのままで大丈夫です。
テストが通ったら成功です。

#### buildspec.rspec.yml

このファイルは CodeBuild 上でテスト環境を構成し、テストを実行します。
詳細は該当ファイルを読んでください。

#### Troubleshooting

> User: arn:aws:iam::xxxxx:user/riseshia is not authorized to perform: iam:DeletePolicyVersion on resource: policy CodeBuildBasePolicy-riseshia-docker-ap-northeast-1

設定を変更したいけどこのように権限がないと出てくる場合があります。
この場合は `Allow AWS CodeBuild to modify this service role so it can be used with this build project` のチェックを外してください。

### Docker build 用プロジェクトを作る

<https://ap-northeast-1.console.aws.amazon.com/ecr/repositories?region=ap-northeast-1>

ページにアクセスしてみるとすでにレポジトリが存在してるのがわかります。
自分のものは `<iam username>` になってるのですぐわかると思います。
後で使うので自分のレポジトリの URI をどこかに保存しておきましょう。

それではプロジェクトの Docker イメージをビルドし、レポジトリにプッシュする CodeBuild プロジェクトを作りましょう。

- Project configuration
  - Project name: `<iam username>-docker`
- Source
  - Source provider: AWS CodeCommit
  - Repository: `<iam username>`
  - Reference type: Branch
  - Branch: master
- Environment
  - Environment image: Managed image
  - Operating system: Ubuntu
  - Runtime: Standard
  - Image: aws/codebuild/standard:4.0
  - Image version Always use latest image for this runtime version
  - Environment type: Linux
  - Privileged: true(チェックを入れてください)
  - Service role: Existing service role
  - Role ARN: CodeBuildServiceRole を選択
  - Allow AWS CodeBuild this service role: **false**
    - **忘れずチェックを外してください**
  - Additional configuration
    - Environment variables
      - Name: REPO
      - Value: `<作った ECR レポジトリの URI>`
        - 注意: `http://` は省略してください
- Buildspec
  - Build specifications: Use a buildspec file
  - Buildspec name: buildspec.docker.yml

こちらも試しに実行してみましょう。ビルドが成功し、 ECR レポジトリにイメージがプッシュされていれば大丈夫です。

#### buildspec.docker.yml

このファイルは CodeBuild 上で docker build を実行し、 ECR にビルドしたイメージをプッシュするよう指示を出します。
詳細は該当ファイルを読んでください。

### Staging デプロイプロジェクトを作る

#### CodeBuild のプロジェクトを作る

それではまた CodeBuild プロジェクトを作りましょう。これが最後です。

- Project configuration
  - Project name: `<iam username>-staging-deploy`
- Source
  - Source provider: AWS CodeCommit
  - Repository: `<iam username>`
  - Reference type: Branch
  - Branch: master
- Environment
  - Environment image: Managed image
  - Operating system: Ubuntu
  - Runtime: Standard
  - Image: aws/codebuild/standard:4.0
  - Image version Always use latest image for this runtime version
  - Environment type: Linux
  - Privileged: true(チェックを入れてください)
  - Service role: Existing service role
  - Role ARN: CodeBuildHakoDeployRole を選択
  - Allow AWS CodeBuild this service role: **false**
    - **忘れずチェックを外してください**
  - Additional configuration
    - Environment variables
      - Name: HAKO_DEFINITION
      - Value: `<iam username>-staging.jsonnet`
      - Name: ACCOUNT_ID
      - Value: AWS account id
        - 作業インスタンスで `echo $ACCOUNT_ID` すれば確認できます
- Buildspec
  - Build specifications: Use a buildspec file
  - Buildspec name: buildspec.staging-deploy.yml
- Artifacts
  - Additional configuration を右クリックして展開する
  - Cache type: Local
  - Custom cache をチェック

Misc: 今回 CodeDeploy は Hako 定義を使い回すために使いません。

こちらも実行してみましょう。
デプロイが完了したら、次の命令を実行して hako アプリケーションに紐付いている ALB の DNSName を確認します。

```
aws elbv2 describe-load-balancers --region ap-northeast-1 --names hako-<iam username>-staging
```

確認ができたら正常にデプロイされているかアクセスしてみましょう。

#### buildspec.staging-deploy.yml

このファイルは CodeBuild 上で staging 環境にデプロイをするように指示を出します。
詳細は該当ファイルを読んでください。

#### Troubleshooting

> app has stopped without exit_code: reason=CannotPullContainerError: Error response from daemon: manifest for xxxx.dkr.ecr.ap-northeast-1.amazonaws.com/riseshia:xxxx not found

現在組み込まれてるスクリプトはレポジトリの HEAD revision をタグ名として使うようになっているので、
該当リビジョンの Docker イメージがまだ作られてないということになります。
Docker build & push するプロジェクトのビルドを実行して最新リビジョンのイメージを作り再度実行しましょう。

### パイプラインを作成してみよう！

Pipeline コンソールから Create pipeline を右クリックします。
以下のように埋めていきましょう

- Pipeline Settings
  - Pipeline name: `<iam username>-ci`
  - Service role: Existing service role
  - Role ARN: CodePipelineServiceRole を選択
- Source
  - Source provider: AWS CodeCommit
  - Repository: `<iam username>`
  - Reference type: Branch
  - Branch: master
  - Change detection options: Amazon CloudWatch Events
- Add build stage
  - Build provider: AWS CodeBuild
  - Region: Asia Pacific (Tokyo)
  - Project name: `<iam username>-test`
  	- 上で作ったテスト用のプロジェクトです
  - Build type: Single build
- Add deploy staging
  - スキップします
- レビュー画面から Create pipeline を右クリック

出来上がったら Edit をクリックしてテストが終了したら Docker イメージを作り ECR にプッシュし、 staging 環境にデプロイするようにしましょう。
やることは今まで作った CodeBuild プロジェクトを順次実行するようにするだけです。

一番下の Add stage をクリックして、 `DockerBuild`, `StagingDeploy` という stage を作ります。
そして、各 stage に対して Add action group をクリックし、実行したいプロジェクトを選択肢ましょう。

- DockerBuild
  - Action name: DockerBuild
  - Action provider: AWS CodeBuild
  - Region: Asia Pacific (Tokyo)
  - Input artifact: SourceArtifact
  - Project name: `<iam username>-docker`
  - Build type: Single build
- StagingDeploy
  - Action name: StagingDeploy
  - Action provider: AWS CodeBuild
  - Region: Asia Pacific (Tokyo)
  - Input artifact: SourceArtifact
  - Project name: `<iam username>-staging-deploy`
  - Build type: Single build

できたら保存します。警告が出ますが、今回は初期設定なので無視して進めて問題ありません。
そして実際実行するために、コードに適当な変更を入れてプッシュしてみましょう。
少し待つと pipeline が勝手に動き始めるのが観測できると思います。

### production デプロイ

パイプラインを作り終えたので、最後に本番を手元からデプロイしてましょう。
何の安全装置もなしに production 環境へのデプロイを自動化するのは危険なので今回は staging を確認してから手ですることにします。

作業インスタンスのプロジェクトディレクトリに移動して次を打ちます。

```
scripts/hako-deploy.sh `<iam username>-production.jsonnet`
```

これで production 環境のアプリケーションがデプロイされます。
ロールバックは以下のコマンドでできますので必要なら利用してください。

```
scripts/hako-rollback.sh `<iam username>-production.jsonnet`
```

ちなみにデプロイを 1回しかやってない状態だと、ロールバックができません。
hako のロールバックは 1つ前の Task definition を使うようにするのですが、
デプロイを1回しかしたことがない場合、持っている Task definition が一つしかないだめ、
1つ前のもの、というのがそもそも存在しないためです。
