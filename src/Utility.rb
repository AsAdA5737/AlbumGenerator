#
# Created by Yoshinobu Ayabe
# 

class Utility
  
  # Platform判別メソッド。
  # Windowsかどうか（Windowsでpopen3メソッドを利用したかったため）
  def self.is_win?
    begin
      require('Win32API.so')
      return true   #Windowsならture
    rescue Exception
      return false
    end
  end
  
  # src_path:zipファイルへのパス
  def self.unzip(src_path, output_path)
    output_path = (output_path + "/").sub("//", "/")
    Zip::ZipInputStream.open(src_path) do |s|
      while f = s.get_next_entry()
        d = File.dirname(f.name)
        FileUtils.makedirs(output_path + d)
        f =  output_path + f.name
        unless f.match(/\/$/)
          $logger.debug("unzip:#{f}");
          File.open(f, "w+b") do |wf|
            wf.puts(s.read())
          end
        end
      end
    end
  end
  
  # dir 検索したいディレクトリを指定
  # ftype 検索対象の拡張子を指定するex) .jpg .zip等々
  def self.findFiles(dir,ftype)
    ary = Array.new();
    
    # /**/* は、指定されたディレクトリ内部のサブディレクトリも返却するために指定が必要。
    Dir::glob(dir + "/**/*").each{|entry|
      next unless entry.match(/#{ftype}/i); # 一致しない場合、スキップする
      ary.push(entry);
    }
    
    return ary;
  end

  
end


