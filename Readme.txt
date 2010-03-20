○改版履歴
1.0.0 : 
　- １版リリース
2.0.0 : 
　- Webからの変換機能をサポート
2.1.0 : 
　- Webからの設定変更機能をサポート
　- セットアップ手順の3. Ubuntuの場合の設定手順を追加。
    - アップデートインストール用スクリプトUpdate.shを追加

○動作環境
　- Debian Linux 
　- Fedora core 12

○セットアップ
　1.install rubygems
　　ex) Fedora12,
　　% yum install rubygems
　2.install ruby module
　　gem install rubyzip  //zipを解凍するモジュール
　　gem install pikl     //画像を編集するモジュール
     　　→エラーが出る場合、追加で以下をインストールすること。
    　   $ sudo yum install ruby-devel
       　$ sudo yum install libjpeg
       　$ sudo yum install libjpeg-devel
       　$ sudo yum install libpng
       　$ sudo yum install libpng-devel 
    
	3. piklのパーミッションを変更する。
　　 piklのライブラリのパーミッションはデフォルトでは正しく設定されていない。
　　 a) Fedora 12の場合
　　   /usr/lib/ruby/gems/1.8/gems/pikl-0.3.0/libの下にある *.rbを全て755に変更すること。
　     b) Ubuntuの場合
　　   /var/lib/gems/1.8/gems/pikl-0.3.0/libの下にある *.rbを755に変更すること。

　4. AlbumGenerator.zipの解凍
　　zipファイルを任意のディレクトリに解凍します。zip内部のディレクトリ構成は変更しないで下さい。

　5. AlbumGeneratorのパーミッション設定

　　以下の設定になるよう変更してください。

　　-rwx------. 1 apache apache 1162 Mar  2 23:14 AlbumCfg.rb
　　-rwx------. 1 apache apache  802 Mar  2 20:58 AlbumDelete.rb
　　-rwx------. 1 apache apache 1470 Mar  2 23:09 AlbumGen.config
　　-rwx------. 1 apache apache 1555 Mar  2 23:18 AlbumGenController.rb
　　-rwx------. 1 apache apache 9111 Mar  2 23:06 AlbumGenerator.rb
　　-rwx------. 1 apache apache 1295 Mar  2 19:51 Utility.rb
　　-rwx------. 1 apache apache 3006 Feb 23 19:53 ZipFileUtils.rb
　　drwxr-xr-x. 2 apache apache 4096 Mar  3 07:29 datastore
　　-rwx------. 1 apache apache 2308 Mar  2 22:24 index.rb
　　drwxr-xr-x. 2 apache apache 4096 Feb 23 06:36 log
   
　6. apacheの設定
　　index.rbを実行できるようにapacheを設定しておく。
　　また、rubyへのパスを設定しておく。

○アップデートインストール
　1. AlbumGenerator_X.X.X.zipを任意のディレクトリに解凍する。
　2. 解凍したディレクトリへ移動。
　3. 以下のコマンドを実行する
　　# sh update.sh <AlbumGeneratorへのパスを指定する>
　4. ruby AlbumGenerator.rb --version を実行し、Versionが上がっていることを確認する

○利用方法
　[コマンドライン]
  　ruby {-hdvc} AlbumGenerator.rb <ZipFile>
  　-h:
     　Show help.
  　-d:
     　Entering debug mode.
  　-v:
     　Show Version.
  　-c:
    　 Cleaning working dir.
  　-t TITLE:
     　Set Album title.
  　-D DATE:
     　Set Date.

　[Web]
　　ブラウザからindex.rbにアクセスする。
　　事前に、Apache等の設定を終わらせておくこと。

○制限事項
