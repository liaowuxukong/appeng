class AppsController < ApplicationController
  def new
    @app = App.new
  end

  def index
    @apps = App.all
  end

  def show
    @app = App.find_by_id(params[:id])
  end

  def create
    @app = App.new(params[:app])

    # 上传 && 上传cf
    if push_app && @app.push
      flash[:success] = "create app success!"
      redirect_to @app
    else
      render 'new'
    end
  end

  private
    def push_app
      return true if upload
      false
    end

    def upload
      uploadfile = @app[:path]
      unless uploadfile
        flash[:error] = "path is null"
        return false
      end
      unzip_file(uploadfile)
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

      require 'fileutils'
      FileUtils.cp uploadfile.path, filename
      system unzip_cmd 
      if $?.to_i == 0
        system "rm #{filename}"
        return true
      end
      false
    end



end
