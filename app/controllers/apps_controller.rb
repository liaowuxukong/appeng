libdir = File.expand_path(File.join(File.dirname(__FILE__), "../../lib"))

mothershiplibdir = "#{libdir}/mothership/lib"
$LOAD_PATH.unshift(mothershiplibdir) unless $LOAD_PATH.include?(mothershiplibdir)
cfliddir = "#{libdir}/cf_lib/lib"
$LOAD_PATH.unshift(cfliddir) unless $LOAD_PATH.include?(cfliddir)


require "cf"
require "cf/plugin"

$stdout.sync = true

CF::Plugin.load_all


class AppsController < ApplicationController
  def new
    @app = App.new
  end

  def index
    status,app_infos = CF::App::Apps.new.apps
    @apps = app_infos
  end

  def show
    @app = App.find_by_id(params[:id])
  end

  def create
    @app = App.new(params[:app])

    # 上传 && 上传cf
    #if @app.save
    if upload && @app.push #&& @app.save
      flash[:success] = "create app success!"
      redirect_to @app
    else
      render 'new'
    end
  end

  private

    def upload
      require 'fileutils'
      uploadfile = @app[:path]
      unless uploadfile
        flash[:error] = "path is null"
        return false
      end
      return false unless unzip_file(uploadfile) && add_apibus_file(uploadfile)
      true
    end

    def unzip_file(uploadfile)
      type = uploadfile.content_type.split('/')[1]
      dirpath = Rails.root.join('public', 'data')
      filename  = Rails.root.join('public', 'data', uploadfile.original_filename)
      unzip_cmd = "cd #{dirpath};"

      puts "=="*10
      puts "type = #{type}"
      puts "filename=#{filename}"

      if type=="x-zip-compressed" || type == "zip"
        unzip_cmd += "unzip #{filename}"
      elsif type == "gzip"
        if uploadfile.original_filename.index("tar.gz")
          unzip_cmd += "tar zxvf #{filename}"
        else
          unzip_cmd += "gzip -d #{filename}"
        end
      elsif type=="x-tar"
        unzip_cmd += "tar xvf #{filename}"
      else
        puts "error"
        flash[:error] = "wrong file type"
        return false
      end
      puts "unzip_cmd = #{unzip_cmd}"
      puts "=="*10

      FileUtils.cp uploadfile.path, filename
      system unzip_cmd 
      if $?.to_i == 0
        system "rm #{filename}"
        return true
      end
      false
    end

    # 在本地解压完成的文件夹中，添加apibus和所有地址的文件
    ## 判断目录下有没有lib文件夹，如果没有，建立lib文件夹
    ## 生成apibus需要用的yaml文件
    ## apibus文件和yaml文件移动到lib目录下
    def add_apibus_file(uploadfile)
      filename  = Rails.root.join('public', 'data', uploadfile.original_filename).to_s
      filename = filename.split(".")[0]
      libfold = filename+"/"+"lib"
      unless  File.exist?(libfold)
        Dir.mkdir(libfold)
      end

      yaml_file_path = libfold + "/service_map.yaml"
      yaml_file_content = {}
      App.all.each{ |app| yaml_file_content[app.name] = "http://"+app.domain.to_s }
      if File.exist?(yaml_file_path)
        File.delete(yaml_file_path)
      end
      File.open(yaml_file_path, 'w'){|f| YAML.dump(yaml_file_content, f)}
      puts "make yaml file to "+yaml_file_path

      apibus_file_source = Rails.root.join('lib','apibus.rb')
      apibus_file_target = libfold + "/apibus.rb"
      if File.exist?(apibus_file_target)
        File.delete(apibus_file_target)
      end
      FileUtils.cp(apibus_file_source, apibus_file_target)
      puts "make apibus file to "+apibus_file_target

      true
    end

end
