#!/usr/bin/ruby -Ku
# アプリケーションの設定をWebブラウザからできるようにするクラス

require "AlbumCfg"

# Generate Html
def generateHtml()
  print "Content-type: text/html\n\n"
  print <<"EOB"
<html>
<head>
<title>Album Generator Setting</title>
</head>
<body>

<hr>
<center>
Setting Parameters
</center>
<hr>
<FORM METHOD="post" ACTION="AlbumCfgSetter.rb">
#{makeSettingField()}
<br />
<INPUT TYPE="submit"> 
</FORM>
<br />
<a href="index.rb">back</>
EOB
  
end

def makeSettingField()
  buff = Array.new();
  
  buff.push("<table border=0>");
  
  AlbumCfg.Val.each{|key,val| 
    next if ( (val.nil?) || (val.empty?) );
    
    buff.push("<tr><td width='200'><strong>#{key}</strong></td>");
    buff.push("<td><input size='50' type='text' name='#{key}' value='#{val}'></td>");
    buff.push("</tr>");
  }
  buff.push("</table>");

  return <<"EOB"
  #{buff.join("\n")}
EOB
  
end

# メイン処理スタート
AlbumCfg.Load();
generateHtml();
