#!/usr/bin/ruby -Ku
#パーミッションに注意

require "cgi"

cgi = CGI.new
print "Content-type: text/html\n\n"

# データはフォーム区切りで送られる。
# multipart/form 形式でデータが送られてきた場合、オブジェクトの型は、TmpFileオブジェクト（1024バイト未満の場合はStringIOオブジェクト）となる
# multipart/form 形式でなければ通常のText形式のまま取得可能っぽい。

begin
  cgi.params.each{|name,value|
    
    # value->Arrayが入っている模様。
    next if (cgi[name] != 'del');
    
    File.delete(name)
    print "File delete #{name}<br />"
    
  }
  
  print "<br />"
  print "<br />"

  print "<a href='index.rb'>back</a>";
rescue => ex
  print "Error Occured<br>";
  print ex.message + "<br>";
end