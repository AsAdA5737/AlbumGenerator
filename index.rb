#!/usr/bin/ruby -Ku
#パーミッションに注意

$ALBUMGEN_PATH="AlbumGenerator.rb";
$ALBUMGEN_VER=`ruby #{$ALBUMGEN_PATH} --version`;

require "Utility"
require "AlbumCfg"

def makeUploadForm()
  
  return <<"EOB"
<!-- Title領域 -->
<FORM ENCTYPE="multipart/form-data" METHOD="post" ACTION="AlbumGenController.rb">
<strong>Title(任意の文字数。アルバムのタイトル部分に利用されます)</strong><br />
<INPUT SIZE="80" NAME="title" TYPE="text">
<br>

<!-- 日付 -->
<strong>Date(ex:20091203)</strong><br />
<INPUT SIZE="80" NAME="date" TYPE="text">
<br>

<!-- アップロードファイル -->
<strong>File Upload</strong><br />
<INPUT SIZE="80" NAME="zipfile" TYPE="file"><br />
<INPUT TYPE="submit"> 
</FORM>

<br />
送信ボタン押下後、処理が完了するまでしばらく時間がかかります。<br />
変換されたファイルは、下のData Store部分に表示されます。  

<br />
<br />
EOB
  
end

def makeDatastoreList()
  
  zipFiles = Utility.findFiles(AlbumCfg.OutputDirPath,".zip");
  listHtml = "";
  
  zipFiles.each{|file|
    listHtml << "<tr><td><a href='#{file}'>#{File::basename(file)}</a></td><td  align=center><input type='checkbox' name=#{file} value='del'</td></tr>";
  }
  
  return <<"EOB"
<!-- 自動生成 -->
<FORM METHOD="post" ACTION="AlbumDelete.rb">
  <table border=2 width=400 >
  <tr>
  <th>ファイル名</th>
  <th>選択</th>
  </tr>
  #{listHtml}
  </table>
<input type="submit" value="削除">
</FORM>
</body>
</html>
EOB
  
end

def generateHtml()
  print "Content-type: text/html\n\n"
  print <<"EOB"
<html>
<head>
<title>Album Generator</title>
</head>
<body>

<center>
Album Generator<a href="./setting.rb">. </a><br />
VERSION:#{$ALBUMGEN_VER}
</center>
<br>
<br>
<!-- アップロードフォーム -->
<hr>
<strong>アップロードフォーム</strong><br />
<hr>
#{makeUploadForm()}
<hr>
<!-- データストア一覧 -->
<strong>Data Store</strong><br />
<hr>
<br />  
一覧を更新する場合、ブラウザの更新ボタンを押して下さい。<br />
<br />
#{makeDatastoreList()}
EOB
  
end

# メイン処理スタート
AlbumCfg.Load();
generateHtml();

# 終了。