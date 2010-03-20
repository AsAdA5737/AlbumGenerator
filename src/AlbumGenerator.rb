#!/usr/bin/ruby
#
# 1.needs install ruby gems
#  ex) Fedora12,
#     % yum install rubygems
# 2.needs ruby following module
#  gem install rubyzip  //zipを解凍するモジュール
#  gem install pikl     //画像を編集するモジュール
#     →エラーが出る場合、追加で以下をインストールすること。
#       $ sudo yum install ruby-devel
#       $ sudo yum install libjpeg
#       $ sudo yum install libjpeg-devel
#       $ sudo yum install libpng
#       $ sudo yum install libpng-devel 
# IN:
#   AlbumGenerator.rb <TargetZip>
# OUT:
#   カレントディレクトリに、album.zipファイルが生成される。
# 
# 3.piklをインストールしているにも関わらずエラー（no such file to load -- pikl (LoadError)）が出る場合
#　 piklのライブラリのパーミッションが正しく設定されていない。
#　 /usr/lib/ruby/gems/1.8/gems/pikl-0.3.0/libの下にある *.rbを全て755に変更すればOK.
#   なお、デフォルトの権限は以下
#  
#[root@localhost lib]# ls -l *
#-rwx------. 1 root root  459 Mar  2 06:46 pikl.rb
#
#pikl:
#total 584
#-rwx------. 1 root root    933 Mar  2 06:46 color.rb
#-rwx------. 1 root root   2086 Mar  2 06:46 const.rb
#-rwx------. 1 root root    111 Mar  2 06:46 errors.rb
#-rwx------. 1 root root   6029 Mar  2 06:46 ext.rb
#-rwx------. 1 root root  12484 Mar  2 06:46 filter.rb
#-rwx------. 1 root root   9718 Mar  2 06:46 image.rb
#-rwxr-xr-x. 1 root root 245746 Mar  2 06:46 pikl.so
#-rwx------. 1 root root    144 Mar  2 06:46 version.rb

require "rubygems"
require 'optparse'
require 'zip/zipfilesystem'
require 'fileutils'
require 'Utility'
require 'ZipFileUtils'
require 'logger'
require 'pikl'
require "AlbumCfg"


Version="2.1.0";

# Optionを解析する
def parseOption(argv)
  props = Hash.new
  
  opt = OptionParser.new do |opt|
    opt.on('-h', '--help') {
      |v| props['help'] = v}
    opt.on('-d', '--debug') {
      |v| props['debug'] = v}
    opt.on('-c', '--clean') {
      |v| props['clean'] = v}
    opt.on('-t TITLE', '--title') {
      |v| props['title'] = v}
    opt.on('-D DATE', '--date') {
      |v| props['date'] = v}
    opt.on('-L', '--Logger') {
      |v| props['logger'] = v}
    
  end
  
  if (opt.parse!(ARGV)) then
    return props
  else
    opt.usage()
    exit(1)
  end
end

def startMain(props)

  srcFileName = ARGV[0];   # .zipファイルを取得する
  
  # 正規表現でファイルの拡張子をチェックする
  if !(srcFileName =~ /.zip/i)
    puts "Invalid file . Target file needs *.zip, but providing file name is #{ARGV[0]}";
    exit(0);
  end
  
  # 最初にclean
  clean(0);
  
  # 出力ディレクトリを日付に変更する
  if (props['date'] != nil)
    AlbumCfg.Val['HTML_WORK_DIR_NAME'] = props['date'];
    $logger.debug("-D option found.");    
    $logger.debug("HTML_WORK_DIR_NAME => #{AlbumCfg.Val['HTML_WORK_DIR_NAME']} ALBUM_NAME => #{AlbumCfg.Val['ALBUM_NAME']} ");    
  end
  
  # 一時作業ディレクトリを作成
  $logger.info("Making temporary working dir......");
  prepareDir();
  $logger.info("Succeeded");
  
  # .tmp/srcディレクトリにzipファイルを展開する
  $logger.info("Uncompressing zip files.....");
  $logger.debug("srcFileName = #{srcFileName} AlbumCfg.ZipExtractDirPath=#{AlbumCfg.ZipExtractDirPath}");
  Utility.unzip(srcFileName,AlbumCfg.ZipExtractDirPath);
  $logger.info("Succeeded");
  
  # .tmp/srcディレクトリ内部の.imgファイルの名前を取得する(.img以外はスキップすること)
  $logger.info("Checking img files.....");
  #files = findJpgFiles(AlbumCfg.ZipExtractDirPath);
  files = Utility.findFiles(AlbumCfg.ZipExtractDirPath,".jpg");
  $logger.info("Succeeded");
  
  # 取得したファイル名から、htmlを生成する。
  $logger.info("Generating html file.....");
  generateHtml(files,props['title']);
  $logger.info("Succeeded");
  
  # リンクに合わせて画像をコピーするメソッド。
  $logger.info("Storing img files, and resize image.....");
  storedImgFile(files);
  $logger.info("Succeeded");
 
  # Outputを全てzip化してOUTPUT_DIRで指定されたディレクトリに出力する
  $logger.info("Complessing output files.....");
  ZipFileUtils.zip(AlbumCfg.HtmlWorkingDirPath,AlbumCfg.OutputDirPath + "/" + AlbumCfg.Val['HTML_WORK_DIR_NAME'] + ".zip");
  $logger.info("Succeeded");
  
  # .tmpディレクトリを削除する
  $logger.info("Cleaning temporary working dir......");
  clean(9);
  $logger.info("Succeeded");

end

# 引数で渡されたディレクトリ中から、.JPGファイルパスを検索し、Arrayとして返却する。
# 戻り値としては、画像ファイルへの絶対パスの配列が返却される。
def findJpgFiles(dir)  
  ary = Array.new();
  
  # /**/* は、指定されたディレクトリ内部のサブディレクトリも返却するために指定が必要。
  Dir::glob(dir + "/**/*").each{|entry|
    next unless entry.match(/.jpg/i); # 一致しない場合、スキップする
    $logger.debug("find:#{entry}");
    ary.push(entry);
  }
  
  return ary;
end

# HTMLファイルを生成する。
def generateHtml(files,title)
  
  output= <<"HTML"
<HTML> 
<HEAD> 
<TITLE>
  #{title}
</TITLE> 
</HEAD> 
  
<body bgcolor="#FFFFFF" text="#111111" link="#00FFFF" vlink="#0000FF" alink="#00ffff"> 
<CENTER>
#{title}
<br>
<BR>
#{makeTables(files)}
</CENTER> 
</BODY> 
</HTML>
HTML
  
  File.open(AlbumCfg.HtmlWorkingDirPath + "/" + AlbumCfg.Val['ALBUM_NAME']+".html",'w'){|f|
    f.write output;
  }
  $logger.debug("write html file: #{AlbumCfg.HtmlWorkingDirPath + "/" + AlbumCfg.Val['ALBUM_NAME']+".html"}")
  
end

# テーブル部分を生成する
def makeTables(files)
  colNumber = AlbumCfg.Val["COLUMN_NUMBER"].to_i;
  buff = Array.new();
  tmpAry = Array.new();
  
  buff.push("<TABLE BORDER='2'>");
  
  for i in 0..files.length-1
    fileName = File::basename(files[i]); # ファイル名のみ切り出す。    
    tmpAry.push("<TD>");
    
    # サムネイルの画像は、小さい画像を表示する。
    tmpAry.push("
        <A HREF= \"./#{AlbumCfg.Val["IMG_STORED_DIR_NAME"]}/#{fileName.sub(".jpg",".html")}\"
        TARGET=main> <IMG SRC=\"#{AlbumCfg.Val["IMG_STORED_DIR_NAME"]}/small_#{fileName}\"></A>"); 
    tmpAry.push("</TD>");
    
    if ( ( (i+1) % colNumber ) == 0 || i == (files.length-1))
      buff.push("<TR>")
      buff.push(tmpAry.join("\n"));
      buff.push("</TR>");
      tmpAry.clear();
    end
  end
  buff.push("</TABLE>");
  
  return buff.join("\n");
end

# srcディレクトリから、imgディレクトリにコピーする
def storedImgFile(files)
  
  files.each{|srcFile|    
    # ファイルのコピー
    if (AlbumCfg.Val["IMG_WIDTH"].to_i == 0)
      $logger.debug("Original copy: " + srcFile);
      FileUtils.copy_entry(srcFile,AlbumCfg.ImgStoredDirPath + "/" + File::basename(srcFile));
    else
      # ☆*を指定することにより、配列を展開して引数として渡すことが可能☆
      Pikl::Image.open(srcFile) do |img|
        img.resize(AlbumCfg.Val["IMG_WIDTH"].to_i,:auto).save(AlbumCfg.ImgStoredDirPath + "/" + File::basename(srcFile),:jpg)
        
        $logger.debug("Resize image: " + srcFile + "->" + AlbumCfg.ImgStoredDirPath + "/" + File::basename(srcFile));
      
      end
    end
    
    # サムネイル用の縮小画像を生成する
    Pikl::Image.open(srcFile) do |img|
      img.resize(AlbumCfg.Val["THUMBNAIL_WIDTH"].to_i,:auto).save(AlbumCfg.ImgStoredDirPath + "/small_" + File::basename(srcFile),:jpg)
      
    end
  }
  
end

# 各作業用ディレクトリを作成する。
def prepareDir()
  # .tmp/srcディレクトリを作成する
  FileUtils.mkdir_p(AlbumCfg.ZipExtractDirPath) unless FileTest.exist?(AlbumCfg.ZipExtractDirPath);
  
  # .tmp/albumディレクトリを作成する
  FileUtils.mkdir_p(AlbumCfg.HtmlWorkingDirPath) unless FileTest.exist?(AlbumCfg.HtmlWorkingDirPath);
  
  # album/imgディレクトリを作成する
  FileUtils.mkdir_p(AlbumCfg.ImgStoredDirPath) unless FileTest.exist?(AlbumCfg.ImgStoredDirPath);
  
  # ./datastoreディレクトリを作成する
  FileUtils.mkdir_p(AlbumCfg.OutputDirPath) unless FileTest.exist?(AlbumCfg.OutputDirPath);
  
end

def clean(level)
  
  if (level >= 0)
    #.tmpファイルを削除する
    FileUtils.remove_entry_secure(AlbumCfg.TmpWorkDirPath,true) if FileTest.exist?(AlbumCfg.TmpWorkDirPath);
  end
  
  if (level >= 9)
    # Nothing to do, now
  end
end


#引数の解析
props = parseOption(ARGV);

#Load Config File.
AlbumCfg.Load();

# Regenerate logger

# ファイルに書き出す
if (props['logger'])
  $logger = Logger.new(AlbumCfg.Val["LOG_FILE"])
else # STDOUTに書き出す。
  $logger = Logger.new(STDOUT)
end

$logger.level = Logger::INFO
$logger.level = Logger::DEBUG if props['debug']; # set debug mode
$logger.datetime_format = "%Y/%m/%d %H:%M:%S";

# Helpの表示
if (props['help']) then
  puts <<"EOB"
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
  -L:
     Set log file output mode.
EOB
elsif (props['clean']) then
  puts "Clean working dir....";
  clean(true);
else
  
  #ログへの初期情報書き出し
  $logger.info("================================");
  $logger.info("   AlbumGenerator #{Version}   ");
  $logger.info("================================");
  
  # メイン処理開始
  startMain(props);
  
  # 終了処理
  $logger.info("Finish Album Generator. Check output file : #{AlbumCfg.OutputFileName}");
end
