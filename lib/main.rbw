$:.push(Dir.pwd)
#http://wxruby.rubyforge.org/wxrubydoc.html
#高亮：StyledTextCtrl
require 'Win32API'
$sci=Win32API.new('kernel32','LoadLibraryW','p','i').call("SciLexer.DLL")
require 'rubygems'
require "win32api"
require "wx"
require 'wx_sugar/all'
require 'erb'  
require 'yaml'  
include Wx
require "lang/zh-cn"
Dir["ui/*.rb"].each{|f|require("./"+f)} 
#require "ui/RMMain.rb"
#require "bin/*"
#require "plugins/*"
require "rpg/ace"
require "rpg/Table"
require 'uri'
require "rpg/DataManager"
require "rpg/ProjectManager"
module Helpers
  module_function
  def str2float(str)
    return str.unpack("d")[0]
  end
  def float2str(float)
    return [float].pack("d")
  end
  def createMenu(menu,lang,fLAG,hash={})
    for i in lang
      if (i[0]==:separator)
        menu.append_separator()
      else
        menu.append(fLAG.size, i[1],i[0].to_s)
        hash[i[0]]=fLAG.size
        fLAG<<i[0]
      end
    end    
  end
end
H=Helpers
def debugOut(data)
  File.open("#{Config.ProgramPath}debug.cfg", "ab") { |f|
    f.write(data)
  }
end
def load_data(filename)
  obj=nil
  File.open(filename, "rb") { |f|
    obj = Marshal.load(f)
  }
  return obj
end
def save_data(obj, filename) 
  File.open(filename, "wb") { |f|
    Marshal.dump(obj, f)
  }
end
def copyall(src,target)
  list=Dir.entries(src)
  list.each_index do |x| 
    next if list[x]=="." or list[x]==".." or list[x]==".svn" or list[x]=="entries" or list[x]==".git"
    #puts list[x]
    unless File.directory?(src+list[x]) 
      FileUtils.cp "#{src+list[x]}",target
    else
      Dir::mkdir(target+list[x])
      copyall(src+list[x]+"\\",target+list[x]+"\\")
    end
  end
end
def pathary2path(path)
    path1=""
  
  for i in path
    path1<<i<<"\\"
  end
  return path1
end
module Config
  @@config={:ver=>"0.0.1 b03",:lastOpen=>"(none)"}
  path=Dir.pwd
  path.gsub!(/\//){"\\"}
  path = path.split(/\\/)
 
  path.delete_at(path.size-1)
  path1=pathary2path(path)
  @@programPath = path1
  @@config[:savePath] = path1+"projects\\"
  
  def self.init
    if File.exists?(@@programPath+"config.cfg")
      config=load_data(@@programPath+"config.cfg")
      if config[:ver]!=@@config[:ver]
        save_data(@@config,@@programPath+"config.cfg")
      else
        @@config=config
      end
    else
      save_data(@@config,@@programPath+"config.cfg")
    end
  end
  def self.save
    save_data(@@config,@@programPath+"config.cfg")
  end
  def self.getProjectSaveUrl
    return @@config[:savePath]
  end
  def self.ProgramPath
    return @@programPath
  end
end

Config.init
ProjectManager.init
ProjectManager.programURL=Dir.pwd
$DEBUG=true
#Win32API.new('user32', 'MessageBox', %w(p p p i), 'i').call(0,Dir.pwd  , "ACE-Project", 0) 
def msgbox(code,title="ACE-Project",hwnd=0,unit=0)
  return Win32API.new('user32', 'MessageBox', %w(p p p i), 'i').call(hwnd,code, title, unit)  if $DEBUG
end 

class RMApp < App
   def on_init   
     $mainWindow = RMMain.new
     $mainWindow.show
   end

end
$mainApp=RMApp.new

#$plugins=Plugins.new($plugins)
#$plugins.start($mainApp,$mainWindow)
$mainApp.main_loop
Config.save