#!/usr/bin/ruby -Ku
#パーミッションに注意

require "rubygems"
require "cgi"
require "time"
require "AlbumCfg"

AlbumCfg.Load();

cgi = CGI.new
print "Content-type: text/html\n\n"

# データはフォーム区切りで送られる。
# multipart/form 形式でデータが送られてきた場合、オブジェクトの型は、TmpFileオブジェクト（1024バイト未満の場合はStringIOオブジェクト）となる
# multipart/form 形式でなければ通常のText形式のまま取得可能っぽい。

AlbumGen = Dir.getwd + "/" + "AlbumGenerator.rb";

begin
  
  # .zipディレクトリを作成する
  FileUtils.mkdir_p(AlbumCfg.TmpZipStoredDir) unless FileTest.exist?(AlbumCfg.TmpZipStoredDir);
  
  srcZipFile = AlbumCfg.TmpZipStoredDir + "/" + cgi['zipfile'].original_filename;
  
  # ファイルを保存
  open(srcZipFile,"w") do |fh|
    fh.binmode
    fh.write cgi['zipfile'].read
  end
  
  # 日付情報を保持
  dateStr = cgi['date'].read;
  # タイトル情報を保持
  titleStr = cgi['title'].read;
  
  Time.parse(dateStr,0);
  
  `ruby -rubygems #{AlbumGen} -D #{dateStr} -t #{titleStr} #{srcZipFile} -L -d`
    
  print "convert finished. <br />";
  print "remove source file : #{srcZipFile}....<br />";
  FileUtils.remove_entry_secure(AlbumCfg.TmpZipStoredDir,true) if FileTest.exist?(AlbumCfg.TmpZipStoredDir);

  print "<br />";
  print "<br />";
  print "<a href='index.rb'>back</a>";
  
rescue => ex
  print "Error Occured<br>";
  print ex.message + "<br>";
  print "<a href='index.rb'>back</a>";

end

