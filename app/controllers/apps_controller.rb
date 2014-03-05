
class AppsController < ApplicationController
  def new
    @app = App.new
  end

  # 将从cf中读取的app分为两个部分，注册过的和没有注册过的
  def index
    status,app_infos = App.get_apps_from_cf
    @apps = app_infos
    apps_from_db = App.all
    # 数据库中保存的app，不全都是注册的，还有一个条件是需要service_map.yaml文件
    @register_apps = apps_from_db.dup.delete_if{|app| app.service_file_path==nil}

    
    # 数据库中没有保存app的status，需要结合apps_from_cf的结果标注
    @register_apps.map do |app1|
      status = @apps[@apps.index{|app2| app1.name == app2[:name]}][:status]
      app1.status = status
    end
    
    # 删除注册过的app
    @apps.delete_if{|app1| @register_apps.index{|app2| app2.name == app1[:name]}}

  end

  def show
    @app = App.find_by_id(params[:id])
  end

  def create
    @app = App.new(params[:app])
    @app[:instance] = @app[:instance].to_s
    
    # tar包上传到服务器
    # 解压tar包，并上传cf
    # 将资料保存数据库
    # 将注册域名保存10.10.1.159数据库 
    if upload && @app.push && @app.save && @app.save_to_database
      flash[:success] = "create app success!"
      redirect_to apps_path
    else
      flash[:error] = "some thing is wrong!"
      render 'new'      
    end
  end

  def destroy

    app_name = params[:id]

    if delete_app = App.find_by_name(app_name)
      delete_app.destroy
      delete_app.delete(app_name)
    end
    
    redirect_to apps_path
  end

  private

    def upload
      require 'fileutils'
      uploadfile = @app[:path]
      return false unless uploadfile
      return false unless unzip_file(uploadfile)
      
      #获得解压之后的文件夹路径
      upload_fold  = Rails.root.join('public', 'data', uploadfile.original_filename).to_s
      upload_fold = upload_fold.split(".")[0]
      @app[:path] = upload_fold

      # 根据解压之后的内容判断是服务还是正常的app
      ## 如果是服务，则读取配置文件
      ## 如果是app则加入apibus文件 
      upload_service_path = upload_fold + '/service.yaml'
      if File.exist?(upload_service_path)
        service_file_path = Rails.root.join('doc','service_info',"#{@app.name}.yaml").to_s
        puts "**"*10
        @app.service_file_path = service_file_path
        puts "#{@app.service_file_path}"
        puts "**"*10
        clean_file(service_file_path)
        FileUtils.cp(upload_service_path, service_file_path)
      else 
        add_apibus_file(upload_fold)
      end
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
    def add_apibus_file(upload_fold)
      libfold = upload_fold+"/"+"lib"
      unless  File.exist?(libfold)
        Dir.mkdir(libfold)
      end

      yaml_file_path = libfold + "/service_map.yaml"
      yaml_file_content = {}
      App.all.each{ |app| yaml_file_content[app.name] = "http://"+app.domain.to_s }
      clean_file(yaml_file_path)
      File.open(yaml_file_path, 'w'){|f| YAML.dump(yaml_file_content, f)}
      puts "make yaml file to "+yaml_file_path

      apibus_file_source = Rails.root.join('lib','apibus.rb')
      apibus_file_target = libfold + "/apibus.rb"
      clean_file(apibus_file_target)
      FileUtils.cp(apibus_file_source, apibus_file_target)
      puts "make apibus file to "+apibus_file_target
    end

    def clean_file(file_path)
      if File.exist?(file_path)
        File.delete(file_path)
      end
    end




end
