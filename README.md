# daigoroubot

他人のツイートから学習して発言するタイプのTwitterのBotです。

語尾に「なのだ！」をつけるところがチャームポイントです。

[旧daigoroubot](https://github.com/gam0022/daigoroubot)もありましたが、随分と古くなってきたので、作り直しました。

## Setup

### Ubuntuの場合

```bash
# 依存パッケージのインストール (非UTF-8のmecab-ipadicでは正常に動きません)
sudo apt-get install mecab mecab-ipadic-utf8

git clone git@github.com:gam0022/daigoroubot2.git
cd daigoroubot2
bundle install

# 実行
export MECAB_PATH=/usr/lib/libmecab.so.2
ruby bin/tweet.rb
```

### macOSの場合

```bash
# 依存パッケージのインストール
brew install mecab mecab-ipadic

git clone git@github.com:gam0022/daigoroubot2.git
cd daigoroubot2
bundle install

# 実行
export MECAB_PATH=/usr/local/Cellar/mecab/0.996/lib/libmecab.dylib
ruby bin/tweet.rb
```


### config.yaml の設定

config.yaml に認証情報を設定してください。

```
cd daigoroubot2
cp config.yaml.example config.yaml
vim config.yaml
```

## 使い方

### bin/tweet.rb

他人のツイートから学習して発言するスクリプトです。

#### 仕組み

- トレンドからランダムにキーワードを拾う
- キーワードからツイートを検索
- 検索したツイートを学習して、マルコフ連鎖で文章を生成
- 語尾に「なのだ！」をつける

#### オプション

- `-n`, `--dry-run`
  - ドライランです。文章の生成だけ行い、ツイートは行いません
- `-t`, `--text`
  - ツイートの生成は行わず、指定した文章をツイートさせます

### bin/folllow.rb

自動フォロー・自動リムーブを行うスクリプトです。

なお、config.yaml で強制フォロー・強制リムーブ対象のユーザを設定できます。

#### 仕組み

- フォローユーザの一覧、フォロワーユーザの一覧を取得
- 片思われの（フォローしているが、フォローはされていない）ユーザをフォロー
- 片思いの(フォローされているが、フォローしていない)ユーザをリムーブ

#### オプション

- `-n`, `--dry-run`
  - ドライランです。フォロー・リムーブ対象のユーザの洗い出しだけを行います
