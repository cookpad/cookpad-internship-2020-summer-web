# 作業インスタンスに関して

## 詳細

- Ubuntu 20.04 LTS
- Ruby 2.7.0
- Python 3.8.2
- Node 14.7.0
- MySQL 8.0.21
- Docker 19.03.8
- jsonnet 0.15.0
- Emacs-nox 26.3
- vim 8.1
- sudo 権限あり

これ以外にほしいパッケージがあればインストールしても構いません。

## QA

### ECR に docker push ができません

手元から ECR に docker push することは原則お勧めしませんが、どうしてもやりたい場合は次の命令を打ち込んで ECR へプッシュ可能な状態にしてください。

```
$(aws ecr get-login --no-include-email --region=ap-northeast-1)
```
