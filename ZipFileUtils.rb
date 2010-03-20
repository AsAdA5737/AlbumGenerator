#!/usr/bin/ruby -Ku
#
# Ruby Zip Utility.
# ref:http://d.hatena.ne.jp/alunko/20071021
#

# 使い方の例 #
#
# c:¥rubyをruby.zipに圧縮
#  ZipFileUtils.zip('c:/ruby', 'c:/ruby.zip')
#
# ruby.zipをc:¥rubyに展開
#  ZipFileUtils.unzip('c:/ruby.zip', 'c:/ruby')
#
# c:¥rubyをruby.zipにファイル名のエンコードをShift_JISに指定して圧縮
#  ZipFileUtils.zip('c:/ruby', 'c:/ruby.zip', {:fs_encoding => 'Shift_JIS'})
#
# ruby.zipをc:¥rubyにファイル名のエンコードをShift_JISに指定して展開
#  ZipFileUtils.unzip('c:/ruby.zip', 'c:/ruby', {:fs_encoding => 'Shift_JIS'})

require 'rubygems'
require 'kconv'
require 'zip/zipfilesystem'
require 'fileutils'

module ZipFileUtils
  
  # src  file or directory
  # dest  zip filename
  # options :fs_encoding=[UTF-8,Shift_JIS,EUC-JP]
  def self.zip(src, dest, options = {})
    src = File.expand_path(src)
    dest = File.expand_path(dest)
    File.unlink(dest) if File.exist?(dest)
    Zip::ZipFile.open(dest, Zip::ZipFile::CREATE) {|zf|
      if(File.file?(src))
        zf.add(encode_path(File.basename(src), options[:fs_encoding]), src)
        break
      else
        each_dir_for(src){ |path|
          if File.file?(path)
            zf.add(encode_path(relative(path, src), options[:fs_encoding]), path)
          elsif File.directory?(path)
            zf.mkdir(encode_path(relative(path, src), options[:fs_encoding]))
          end
        }
      end
    }
  end
  
  # ここの処理だけ変更済。
  # もともとの処理では、zipを解凍した結果、内部にディレクトリがあると処理に失敗することが
  # あった。
  def self.unzip(src, dest, options = {})
    dest = (dest + "/").sub("//", "/")
    Zip::ZipInputStream.open(src) do |s|
      while f = s.get_next_entry()
        d = File.dirname(f.name)
        FileUtils.makedirs(dest + d)
        f =  encode_path(dest + f.name, options[:fs_encoding]);
        unless f.match(/\/$/)
          $logger.debug("unzip:#{f}");
          File.open(f, "w+b") do |wf|
            wf.puts(s.read())
          end
        end
      end

    end
  end
  
  private
  def self.each_dir_for(dir_path, &block)
    dir = Dir.open(dir_path)
    each_file_for(dir_path){ |file_path|
      yield(file_path)
    }
  end
  
  def self.each_file_for(path, &block)
    if File.file?(path)
      yield(path)
      return true
    end
    dir = Dir.open(path)
    file_exist = false
    dir.each(){ |file|
      next if file == '.' || file == '..'
      file_exist = true if each_file_for(path + "/" + file, &block)
    }
    yield(path) unless file_exist
    return file_exist
  end
  
  def self.relative(path, base_dir)
    path[base_dir.length() + 1 .. path.length()] if path.index(base_dir) == 0
  end
  
  def self.encode_path(path, encode_s)
    return path if encode_s.nil?()
    case(encode_s)
    when('UTF-8')
      return path.toutf8()
    when('Shift_JIS')
      return path.tosjis()
    when('EUC-JP')
      return path.toeuc()
    else
      return path
    end
  end
  
end