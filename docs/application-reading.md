# アプリケーションを読み解いていく

ハンズオンで触っていく予定のアプリケーションを見ていきましょう。
ここでは実装について、Rails や周辺ツールについての説明を交えつつ説明します。

## Gemfile, Gemfile.lock

Bundler という gem パッケージ管理ツールの設定ファイル。
Ruby アプリケーションは（当然 Rails アプリケーションも）依存 gem パッケージを Bundler で管理するのが普通です。
Rails そのものも gem パッケージとして提供されています。

<https://bundler.io/>

### バージョン指定

Gemfile ではアプリケーションで利用する gem パッケージを指定します。

```ruby
gem 'rails', '~> 6.0.3'
gem 'mysql2'
gem 'ridgepole'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
```

`gem 'rails', '~> 6.0.3'` は `'rails'` が gem 名、 `'~> 6.0.3'` がバージョンを指定しています。
（公式の）gem パッケージは <https://rubygems.org/> でホスティングされており、
rails gem だと <https://rubygems.org/gems/rails> を見るとリリースされている gem のバージョンやその gem が依存している gem の情報などが確認できます。

`'~> 6.0.3'` というバージョン指定は少し複雑で `>= 6.0.3` かつ `< 6.1` という意味で、`6.0.3`, `6.0.4` といったバージョンを含みます。

`gem 'mysql2'` のような指定はバージョン番号を指定していません。

上記のように Gemfile で対象パッケージを指定したアプリケーションのディレクトリにて
`bundle install` コマンドを実行すると対象 gem とそれらの gem が依存している gem がインストールされ、`Gemfile.lock` が作成されます。
この時インストールされる gem のバージョンは Gemfile 内で指定された gem で矛盾のない適切なバージョンとなります。

Gemfile しかない状態でインストールされる gem のバージョンは `bundle install` を実行する時期によって異なります。
しかし各開発者が `bundle install` するタイミング、また本番サーバにデプロイされるタイミングで違うバージョンの
gem がインストールされては困ります。そのため初めて `bundle install` を実行すると
インストールされた gem のバージョンが記録された
`Gemfile.lock` というファイルが生成されます。
`Gemfile.lock` がある状態で `bundle install` を実行すると必ず同じバージョンの gem がインストールされるので常に同じバージョンのパッケージをインストールすることができます。

### bundle update

`Gemfile.lock` に記述された gem のバージョンについては `bundle update` コマンドを実行することでアップデートできます。
Gemfile を変更していなくても、対象 gem の新規リリースがある場合などバージョンが更新されることもあります。
Gemfile でのバージョン指定を更新した場合にも `bundle update` を実行し、gem のバージョンを更新します。

Gemfile に記述するバージョン指定については全て細かく指定することもできますが、
ある程度大きめに指定して
`bundle update` による gem 更新をしやすくしておくのがオススメです。

具体的にどういう指定をすべきかは時と場合によりますが、重要度や
バージョンアップポリシーが不安定な gem ほど対象バージョンの指定を狭くする
というのがよくある方針です。

### group 指定

以下のような `group :development` ブロックで指定された gem は development 時、つまり手元での開発時のみ利用される開発用の gem パッケージです。

```ruby
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
end
```

また `group :development, :test` のような指定では development 時と test 時に有効となります。

### Gemfile

tinypad では（development, test を除くと）以下の gem が指定されています。

- rails
  - Rails 本体の gem です。
- mysql2
  - https://github.com/brianmario/mysql2
  - Ruby で mysql へ接続するために使われるメジャーな gem です。
- ridgepole
  - https://github.com/winebarrel/ridgepole
  - DB スキーマを管理するための gem です。
- puma
  - https://github.com/puma/puma
  - Rails でデフォルトでインストールされる Rack 対応ウェブサーバ gem です。
- sass-rails
  - https://github.com/rails/sass-rails
  - sass/scss を Rails で使うための gem です
- bootsnap
  - Rails でデフォルトでインストールされる起動高速化のための gem です。
- warning
  - https://github.com/jeremyevans/ruby-warning
  - Ruby 2.7 は Ruby 3.0 に向けて一部仕様変更に対する警告を吐くようになっており、これらを無視するための gem です。
  - Ref: https://www.ruby-lang.org/en/news/2019/12/12/separation-of-positional-and-keyword-arguments-in-ruby-3-0/

つまり Gemfile から tinypad は Rails を利用しているウェブアプリケーションだろうなというのがわかります。

## config/routes.rb

Rails アプリケーションのルーティングが記述された設定ファイルです。
この設定ファイルを読むとアプリケーションがどのようなリクエストに対応しているかわかります。

記述方法などは <https://railsguides.jp/routing.html> にまとまっています。

```ruby
Rails.application.routes.draw do
  resource :session, only: %w[new create destroy]
  resources :users
  resources :recipes do
    resources :tsukurepos, only: %w[new create destroy]
  end
  resources :images, only: %w[show]

  root to: 'top#index'
end
```

### resources, resource

Rails の一番基本的なリソースベースのルーティング記述方法です。

<https://railsguides.jp/routing.html#リソースベースのルーティング-railsのデフォルト>

Rails がこの記述方法をデフォルトとしているのは二つの基本理念

- 同じことを繰り返すな (Don't Repeat Yourself)
- 設定より規約 (Convention Over Configuration)

が強く現れている部分です。つまり Rails は URL は REST に沿って設計すべきであるという規約で設計されたフレームワークであり、規約に基づいていると記述が簡潔になるように設計されています。

実際の設定は以下のようなルーティングに対応します。

- `resource :session, only: %w[new create destroy]`
  - `GET /session/new` -> `SessionsController#new`
  - `POST /session` -> `SessionsController#create`
  - `DELETE /session` -> `SessionsController#destroy`
- `resources :images, only: %w[show]`
  - `GET /images/:id` -> `ImagesController#show`

これは resources, resource を利用しなかった場合以下のような記述と同じ意味となります。

```ruby
get "/session/new", to: "sessions#new", as: "new_session"
post "/session", to: "sessions#create", as: "session"
delete "/session", to: "sessions#destroy", as: "session"
get "/images/:id", to: "images#show", as: "image"
```

### db/

db/ 以下にはマイグレーションなどデータベース関連のファイルが格納されてるはず、なんですが、
このアプリケーションでは Rails のデフォルトの migration 機能を使わず ridgepole という gem を導入しています。
Rails 基本の db migration 機能は適用前後の差分を管理するという意図を持っており、実際そのへんの違いが分かりやすいものの、変更が多すぎると運用が大変難しくなるという問題があります。一方で ridgepole は変更履歴の管理を VCS に任せ、 DB スキーマを状態として捉えることで長期に渡る運用を比較的楽にしてくれます。そのため、クックパッドを多くの社内サービスからは ridgepole を重宝されているので今回のハンズオンでも同じ構成を取りました。

構成としては Schemafile を起点とし、 `db/*.schema` を読み込みます。
各 schema ファイルは 1 テーブルに対応しており、中身は Ruby DSL です。試しに `db/recipes.schema` を開いてみましょう。

```ruby
create_table "recipes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
  t.string   "title",       limit: 255, null: false
  t.string   "description", limit: 512, null: false

  t.integer  "user_id",                 null: false
  t.integer  "image_id"

  t.datetime "created_at",              null: false
  t.datetime "updated_at",              null: false
end

add_index "recipes", ["user_id"], name: "users_idx", using: :btree
add_index "recipes", ["image_id"], name: "images_idx", using: :btree
```

recipes というテーブルの定義、及びそのテーブルのカラム定義、貼ってるインデックスに関する情報が乗っています。

ridgepole はこの定義と実際データベース上のテーブルを突き合わせてどういう変更が必要なのか判断し必要な SQL を生成します。
例えば上記のテーブルから description というカラムを消して `bin/rails ridgepole:dry-run` を実行すると

```
bin/ridgepole --apply --dry-run --config config/database.yml --env development --file db/Schemafile
Apply `db/Schemafile` (dry-run)
remove_column("recipes", "description")

# ALTER TABLE `recipes` DROP COLUMN `description`
```

description というカラムを落とすための SQL が発行されることがわかります。
この状態で `bin/rails ridgepole:apply` を実行すると実際カラムが削除されます。

Tips: staging/production 環境のデータベースを変更したい場合 `scripts/hako-oneshot.sh` で `bin/rails ridgepole:apply` を実行してください。

#### テーブルを追加する

`db/<table name>.schema` というファイルを追加し、そこにテーブルの仕様を記述すればいいです。
DSL は Rails のスキーマで使われるものと同じなため、そちらを参照してください。

<https://railsguides.jp/active_record_migrations.html#スキーマダンプの種類>

#### db/seeds.rb

このファイルには初期データを投入するための記述をします。

seeds.rb に記述した内容は `bin/rails db:seed` で実行されます。

<https://railsguides.jp/active_record_migrations.html#マイグレーションとシードデータ>

tinypad の seeds.rb にはいくつかのユーザーやレシピ、つくれぽのデータをいくつか生成します。
中身は普通の Rails コードです。

```ruby
# ...
users = []
10.times do |i|
  users << User.create!(name: "chef#{i}", password_digest: DigestGenerator.digest("password"))
end
# ...
```

## app/models/

app/models/ 以下には「モデル」を定義するクラスが格納されます。
Rails アプリケーションの場合、モデルのクラスのその多くは Active Record のクラスです。

<https://railsguides.jp/active_record_basics.html>

tinypad で定義してるモデルクラスはいくつかあります。

- ApplicationRecord を継承する一般的な Active Record クラス
  - user, recipe, tsukurepo, image, ingredient, step などがそうです。
- xxx_form.rb
  - フォームを扱うためのクラスです。いわゆるフォームオブジェクトというもので、フォーム入力の検証及び、 Active Record オブジェクトに渡すデータ生成の役割を担っています。
- xxx_parser.rb
  - ユーザーにはレシピを作成する時、材料や手順の入力してもらう時あるルールに従ってもらってます。そのルール通りに文字列を実際のデータにパースするクラスです。
- concerns/direct_creation_prohibitable.rb
  - フォームオブジェクトを利用するモデルの場合、検証の役割をフォームの方でしか持ってないためを通さずデータベースに保存することを禁じたほうが安全です。それを実現するための実装です。

`User`, `Recipe`, `Tsukurepo` などの定義を見るとマッピングするテーブル名やカラム名などが一切記述されていないことに気づくかと思います。

```ruby
class User < ApplicationRecord
  has_many :recipes, dependent: :destroy
  has_many :tsukurepos, dependent: :destroy
end
```

これはまさに「同じことを繰り返すな」「設定より規約」の思想に従い「カラム名や型などは Rails がデータベースから自動的に取得する」「`User` というクラス名なら `users` テーブルを扱うモデルのはず」というように自動的に設定したりデフォルト値を決めているため記述が簡潔になっている例です。

### has_many, belongs_to

User, Recipe モデルではそれぞれ `has_many :recipes`, `belongs_to :user` という記述があります。
これらはモデル間の「ユーザーは複数のレシピを持つことができる」「レシピは一つのユーザーに属する」というアソシエーションが定義しています。

<https://railsguides.jp/association_basics.html>

## app/controllers/

先の routes.rb の解説で先行していくつかのコントローラが登場しましたが、クライアントからのリクエストを受ける処理を記述するところがコントローラです。

<https://railsguides.jp/action_controller_overview.html>

tinypad には以下のいくつかのコントローラが存在します。

- ApplicationController
  - ApplicationController は基本的に app/controllers 以下の全てのコントローラの継承元として設定するような基本的なメソッドを定義するコントローラです。通常 ApplicationController に直接ルーティングするようなことはしません。
- ImagesController
  - Image モデル（リソース）を扱うコントローラです。
- RecipesController
  - Recipe モデル（リソース）を扱うコントローラです。
- SessionsController
  - ログイン・ログアウトを扱うコントローラです。
- TopController
  - メインページを扱うコントローラです。
- TsukureposController
  - Tsukurepo モデル（リソース）を扱うコントローラです。
- UsersController
  - User モデル（リソース）を扱うコントローラです。

## spec/

RSpec で記述するテストケース、設定などは spec/ 以下に配置します。

テスト間で共通の設定等は spec/spec_helper.rb, spec/rails_helper.rb に書きます。

ドキュメントは https://relishapp.com/rspec にまとまっているのでそちらを参照してください。
RSpec 記法や `rspec` コマンドの使い方などのコア機能については RSpec Core を、RSpec での Rails のテストの書き方等は RSpec Rails のドキュメントを参照してください。

- rspec-core: https://relishapp.com/rspec/rspec-core/v/3-9/docs
- rspec-rails: https://relishapp.com/rspec/rspec-rails/docs

ディレクトリの構成は以下のようになっています。

- factories
  - FactoryBot の factory の置き場です。後で説明します。
- fixtures
  - テストに必要な各種ファイルを起きます。 tinypad だと画像のアップロードのテストするため画像が1枚入っています。
- models
  - モデルのテストが入っています
- requests
  - コントローラのテストが入っています
- support
  - テストに必要なユティリティ(i.e. ログイン状態を作るためのもの)があります

### FactoryBot

FactoryBot はテストデータの作成を手伝ってくれる gem です。

https://github.com/thoughtbot/factory_bot
https://github.com/thoughtbot/factory_bot_rails

自分でテストデータを作ってもいいですが、 FactoryBot を導入することで以下の方なメリットがあります

- データのデフォルトのデータセットを定義しておくことで、使い回しが楽になる
- そのテストに必要な属性だけを露出させることでテスト要件をより明確にできる

例えば、Rails では以下のように使えます。

```ruby
FactoryBot.define do
  factory :user do
    name { 'default' }
  end
end

FactoryBot.create(:user) # => User モデルのレコードを作り、それに紐づくインスタンスを返す
FactoryBot.build(:user) # => User モデルのインスタンスを作るがレコードを作らない

FactoryBot.create(:user, name: 'shia') # => デフォルトのデータの　name を 'shia' に置き換えしてレコードを生成する
```

詳細な使い方に関しては公式ドキュメントを参照してください。
<https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md>

### テストの実行

```
bundle exec rspec # すべてのテストを実行する
bundle exec rspec spec/models/ # spec/models/ 以下のテストのみ実行する
bundle exec rspec spec/models/recipe_form_spec.rb # spec/models/recipe_form_spec.rb のテストのみ実行する
bundle exec rspec spec/models/recipe_form_spec.rb:16 # spec/models/recipe_form_spec.rb の 16 行目に書かれてるテストのみ実行する
```

### テストの書き方

以下の記述は `GET /recipes` の正常系のテストを記述したものです。

```ruby
RSpec.describe "/recipes", type: :request do
  let(:image) do
    FactoryBot.create(:image)
  end
  let(:user) do
    FactoryBot.create(:user)
  end

  describe "GET /index" do
    it "renders a successful response" do
      FactoryBot.create(:recipe)
      get recipes_url
      expect(response).to be_successful
    end
  end
# ...
```

- `describe` ではテストする対象に `GET /index` という名称をつけつつ、そのブロック以下をひとまとめにしています。
- `let(:image) { ... }` は `{ ... }` の評価結果を `image` として参照できるように宣言しています。
  - ただし `image` が呼び出させるまでは `image` は作成されません。
  - `let!(:image) { ... }` のように `!` をつけると呼び出されなくても先に `image` が作成されます。
- `it` のブロックでは実際の検証したい処理内容（example と呼びます）を記述します。
  - `get recipes_url` は `GET /recipes` というリクエストを送ります
  - `expect(response).to be_successful` はレスポンスが成功することを検証します

つまりこの記述は `GET /recipes` のリクエストが送られてきた時に tinypad が期待したレスポンスを返してくれることを検証するテストコードです。

このように Rails アプリケーションに対しリクエストを送った時の振る舞いを記述するテストを Request spec と呼びます。

Ref:
- RSpec documentation: <https://rspec.info/documentation/>
  - 最新バージョンを参照すれば問題ありません。
- 使えるRSpec入門 <https://qiita.com/jnchito/items/42193d066bd61c740612>
