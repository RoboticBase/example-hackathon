# Kubernetes ハッカソン用リポジトリ

## Kubernetes ハッカソン参加者用ユーザー追加
### 前提条件
* クライアントPCのOSがMacOSあるいはLinuxであること
* 以下のコマンドがクライアントPCにインストールされていること
    * openssl
    * base64
    * envsubst
    * kubectrl
* KubernetesがRBACで動作済みで、 `system:masters` グループに所属する特権ユーザとしてアクセスできること

### 管理者PCでの作業
#### 環境変数を設定

1. 作成するユーザー名を環境変数に設定（以下は `user-01` を作成する場合の例）

    ```
    $ export USER_NAME="user-01"
    ```
    * ユーザー名は、アルファベットの小文字と数字、及び"-"のみ（最初と最後は"-"ではないこと）

#### 鍵と署名済みの証明書の生成

1. スクリプトを用いて、当該ユーザー用の秘密鍵と証明書を生成

    ```
    $ ./scripts/create_user_certs.sh ${USER_NAME}
    ```

#### Kuberntesに当該ユーザー用のnamespaceを作成し、権限を設定

1. 当該ユーザー用のnamespaceを作成

    ```
    $ envsubst < k8s/user-namespace.yaml | kubectl create -f -
    ```

1. 当該ユーザーが自分のnamespaceを使えるようにRBACを設定

    ```
    $ envsubst < k8s/user-rbac.yaml | kubectl create -f -
    ```
#### ユーザーに渡す圧縮ファイルを生成する

1. ユーザーを作成したいKubernetesクラスタの名前とserver urlを確認する

    ```
    $ kubectl config view
    ```
    * clusterの `name` と `server` を探す
1. スクリプトを用いて、当該ユーザー用の秘密鍵・証明書及びそれらをkubectlに登録するスクリプトをまとめた圧縮ファイルを生成する

    ```
    $ ./scripts/pack_certs.sh <<クラスタのAPI ServerのURL>> <<クラスタの名前>> ${USER_NAME}
    ```
1. ハッカソン参加者へ生成した圧縮ファイルを渡す

### ハッカソン参加者PCでの作業
### 前提条件
* 参加者のPCのOSがMacOSあるいはLinuxであること
* 以下のコマンドがクライアントPCにインストールされていること
    * kubectrl

## 参加者のkubectlに、Kuberntesクラスタへの接続情報を登録する

1. 参加者のPC上で、圧縮ファイルに同梱されているシェルスクリプトを実行する
1. `kubectl get pods` 等を実行して、Kuberntesクラスタに接続できることを確認する
    * `node` や `namespace` の情報は取得できない
    * 自身のnamespace以外のnamespaceの情報は取得できない

## License

[Apache License 2.0](/LICENSE)

## Copyright
  Copyright (c) 2019 [TIS Inc.](https://www.tis.co.jp/)
