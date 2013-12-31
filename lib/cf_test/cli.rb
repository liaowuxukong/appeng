require "yaml"
require "socket"
require "net/http"
require "json/ext"
require "multi_json"
require "multi_json/adapters/json_gem"
require "fileutils"

require "cfoundry"

require "cf/constants"  # 载入常量
require "cf/errors" 
require "cf/spacing"

require "mothership"

$cf_asked_auth = false

module CFConsole
  class CLI < Mothership

    include CFConsole::Spacing

    option :help, :desc => "Show command usage", :alias => "-h",
      :default => false

    option :http_proxy, :desc => "Connect with an http proxy server", :alias => "--http-proxy",
      :value => :http_proxy

    option :https_proxy, :desc => "Connect with an https proxy server", :alias => "--https-proxy",
      :value => :https_proxy

    option :version, :desc => "Print version number", :alias => "-v",
      :default => false

    option :verbose, :desc => "Print extra information", :alias => "-V",
      :default => false

    option :force, :desc => "Skip interaction when possible", :alias => "-f",
      :type => :boolean, :default => proc { input[:script] }

    option :debug, :desc => "Print full stack trace (instead of crash log)",
           :type => :boolean, :default => false

    option :quiet, :desc => "Simplify output format", :alias => "-q",
      :type => :boolean, :default => proc { input[:script] }

    option :script, :desc => "Shortcut for --quiet and --force",
      :type => :boolean, :default => proc { !$stdout.tty? }

    option :color, :desc => "Use colorful output",
      :type => :boolean, :default => proc { !input[:quiet] }

    option :trace, :desc => "Show API traffic", :alias => "-t",
      :default => false


    def client_target
      return File.read(target_file).chomp if File.exists?(target_file)
    end

    def ensure_config_dir
      config = File.expand_path(CFConsole::CONFIG_DIR)
      FileUtils.mkdir_p(config) unless File.exist? config
    end

    def set_target(url)
      ensure_config_dir

      File.open(File.expand_path(CFConsole::TARGET_FILE), "w") do |f|
        f.write(url)
      end

      invalidate_client
    end

    def targets_info
      new_toks = File.expand_path(CFConsole::TOKENS_FILE)

      info =
        if File.exist? new_toks
          YAML.load_file(new_toks)
        end

      info ||= {}

      normalize_targets_info(info)
    end

    def normalize_targets_info(info_by_url)
      info_by_url.reduce({}) do |hash, pair|
        key, value = pair
        hash[key] = value.is_a?(String) ? { :token => value } : value
        hash
      end
    end

    def target_info(target = client_target)
      targets_info[target] || {}
    end

    def save_targets(ts)
      ensure_config_dir

      File.open(File.expand_path(CFConsole::TOKENS_FILE), "w") do |io|
        YAML.dump(ts, io)
      end
    end

    def save_target_info(info, target = client_target)
      ts = targets_info
      ts[target] = info
      save_targets(ts)
    end

    def remove_target_info(target = client_target)
      ts = targets_info
      ts.delete target
      save_targets(ts)
    end    

    def invalidate_client
      @@client = nil
      client
    end

    def client(target = client_target)
      return @@client if defined?(@@client) && @@client
      return unless target

      info = target_info(target)
      token = info[:token] && CFoundry::AuthToken.from_hash(info)

      fail "V1 targets are no longer supported." if info[:version] == 1

      @@client = build_client(target, token)

      @@client.trace = false

      uri = URI.parse(target)
      @@client.log = File.expand_path("#{LOGS_DIR}/#{uri.host}.log")

      unless info.key? :version
        info[:version] = @@client.version
        save_target_info(info, target)
      end

      @@client.current_organization = @@client.organization(info[:organization]) if info[:organization]
      @@client.current_space = @@client.space(info[:space]) if info[:space]

      @@client
    rescue CFoundry::InvalidTarget
    end

    def build_client(target, token = nil)
      client = CFoundry::V2::Client.new(target, token)
      client.http_proxy =  ENV['HTTP_PROXY'] || ENV['http_proxy']
      client.https_proxy =  ENV['HTTPS_PROXY'] || ENV['https_proxy']
      client
    end

    def fail_unknown(display, name)
      fail "Unknown #{display} '#{name}'."
    end

    def check_logged_in
      check_target
      unless client.logged_in?
        if force?
          fail "Please log in with 'cf login'."
        else
          line "Please log in first to proceed."
          line
          invoke :login
          invalidate_client
        end
      end
    end  

    def check_target
      unless client && client.target
        fail "Please select a target with 'cf target'."
      end
    end

    def quiet?
      input[:quiet]
    end

    def force?
      input[:force]
    end

    def debug?
      !!input[:debug]
    end

    def err(msg, status = 1)
      $stderr.puts msg
      exit_status status
    end

    def fail(msg)
      raise UserError, msg
    end 

    private
      # "~/.cf/target"
      def target_file
        File.expand_path(CFConsole::TARGET_FILE)
      end

      # "~/.cf/tokens.yml"
      def tokens_file
        File.expand_path(CFConsole::TOKENS_FILE)
      end



  end

end