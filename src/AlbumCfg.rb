#
# (c) Copyright 2010 ayaby. All Rights Reserved. 
# 
# config情報を保持し、読み出すためのクラス

class AlbumCfg
  
  @@Val = Hash.new();

  def AlbumCfg.Val
    @@Val
  end
    
  # 設定内容をファイルから読み込む。
  def self.Load(configName="AlbumGen.config")
    f = File.open(configName)
    f.each{|line|
      if (/\A#/ =~ line)
        next;
      end

      /(.*)=(.*)/ =~ line;
      @@Val[$1]= $2;
    }
    f.close();
    
    return self;
  end
  
  # 設定内容をファイルに書き出す。
  def self.Save(configName="AlbumGen.config")          
    buff = Array.new();
    
    # ファイルの内容を読み出す
    f = File.open(configName,"r")

    f.each{|line|
      if (/\A#/ =~ line)
        buff.push(line);
        next;
      end

      # 現在のファイルの内容を抜き出す
      /(.*)=(.*)/ =~ line;
            
      # ファイル中身と、現在のValの値が異なる場合、置換する
      if ( !$1.nil? && !$2.nil? && @@Val[$1] != $2 )
        buff.push("#{$1}=#{@@Val[$1]}\n")
      else
        buff.push(line);
      end
    }    
    f.close();
          
    # ファイルに書き出す
    open(configName,"w"){|io|
      io.write(buff);
    }     
  end
  
  def self.TmpWorkDirPath
    return File::expand_path(@@Val["TMP_DIR_NAME"]);
  end
  
  def self.ZipExtractDirPath
    return self.TmpWorkDirPath + "/" + @@Val["ZIP_EXTRACT_DIR_NAME"]
  end
  
  def self.HtmlWorkingDirPath
    return self.TmpWorkDirPath + "/" + @@Val["HTML_WORK_DIR_NAME"]
  end
  
  def self.ImgStoredDirPath
    return self.HtmlWorkingDirPath + "/" + @@Val["IMG_STORED_DIR_NAME"]    
  end
  
  def self.OutputFileName
    return @@Val["ALBUM_NAME"];
  end
  
  def self.OutputDirPath
    return @@Val["OUTPUT_DIR"];
  end

  def self.TmpZipStoredDir
    return File::expand_path(@@Val["TMP_ZIP_STORED_DIR"]);
  end

end