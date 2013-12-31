require "cf/cli"
require "cf/cli/app/base"
require "cf/cli/app/push/sync"
require "cf/cli/app/push/create"
require "cf/cli/app/push/interactions"

module CFConsole::App

  class Push < Base
    include Create

    desc "Push an application, syncing changes if it exists"

    input :name,      :desc => "Application name", :argument => :optional
    input :path,      :desc => "Path containing the bits", :default => "."
    input :host,      :desc => "Subdomain for the app's URL"
    input :domain,    :desc => "Domain for the app",
                      :from_given => proc { |given, app|
                        if given == "none"
                          given
                        else
                          app.space.domain_by_name(given) ||
                            fail_unknown("domain", given)
                        end
                      }
    input :memory,    :desc => "Memory limit"
    input :instances, :desc => "Number of instances to run", :type => :integer
    input :command,   :desc => "Startup command", :default => nil
    input :plan,      :desc => "Application plan"
    input :start,     :desc => "Start app after pushing?", :default => true
    input :restart,   :desc => "Restart app after updating?", :default => true
    input :buildpack, :desc => "Custom buildpack URL", :default => nil
    input :stack,     :desc => "Stack to use", :default => nil
    input :create_services, :desc => "Interactively create services?",
          :type => :boolean, :default => proc { force? ? false : interact }
    input :bind_services, :desc => "Interactively bind services?",
          :type => :boolean, :default => proc { force? ? false : interact }


    def push(inputs)

      puts "start push"

      name = inputs[:name]
      path = inputs[:path]

      puts "in push: name = #{name}"
      puts "in push: path = #{path}"

      # cfoundry/v2/model_magic/queryable_by.rb
      # cfoundry/v2/client.rb
      # 如果已经上传过得到 app = #<CFoundry::V2::App:0x9419aac>,CFoundry::V2::App
      # 如果没有上传过 app = ,NilClass
      app = client.app_by_name(name)
      puts "app = #{app},#{app.class}" 
      if app
        sync_app(app, path)
      else
        setup_new_app(path)
      end

    end

    def setup_new_app(path)
      self.path = path
      
      # 在get_inputs中得到需要的变量，返回的是一个hash，内容为{:name=>"name",....}
      app = create_app(get_inputs)
      map_route(app)
      create_services(app)
      bind_services(app)
      upload_app(app, path)
      start_app(app)
    end

    private

    def sync_app(app, path)
      upload_app(app, path)
      apply_changes(app)
      input[:path]
      display_changes(app)
      commit_changes(app)

      warn "\n#{c(app.name, :name)} is currently stopped, start it with 'cf start'" unless app.started?
    end

    def url_choices(name)
      client.current_space.domains.sort_by(&:name).collect do |d|
        # TODO: check availability
        "#{name}.#{d.name}"
      end
    end

    def upload_app(app, path)
      app = filter(:push_app, app)

      with_progress("Uploading #{c(app.name, :name)}") do
        app.upload(path)
      end
    rescue
      err "Upload failed. Try again with 'cf push'."
      raise
    end

    def wrap_message_format_errors
      yield
    rescue CFoundry::MessageParseError => e
      md = e.description.match /Field: ([^,]+)/
      field = md[1]

      case field
      when "buildpack"
        fail "Buildpack must be a public git repository URI."
      end
    end
  end
end

