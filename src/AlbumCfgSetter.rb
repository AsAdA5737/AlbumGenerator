#!/usr/bin/ruby -Ku

require "cgi"
require "AlbumCfg"

cgi = CGI.new
print "Content-type: text/html\n\n"

# データはフォーム区切りで送られる。
# multipart/form 形式でデータが送られてきた場合、オブジェクトの型は、TmpFileオブジェクト（1024バイト未満の場合はStringIOオブジェクト）となる
# multipart/form 形式でなければ通常のText形式のまま取得可能っぽい。

begin
  AlbumCfg.Load();
  
  cgi.params.each{|name,value|
    AlbumCfg.Val[name] = cgi[name];
  }

  AlbumCfg.Save();
  print "Changed parameters";
  print "<br />";
  print "<br />";
  print "<a href='index.rb'>back</a>";
  
rescue => ex
  print "Error Occurred<br>";
  print ex.message + "<br>";
end
