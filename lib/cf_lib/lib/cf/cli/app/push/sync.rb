module CF::App
  module Sync
    def apply_changes(app)
      app.memory = megabytes(input[:memory]) if input.has?(:memory)
      app.total_instances = input[:instances] if input.has?(:instances)
      app.command = input[:command] if input.has?(:command)
      app.buildpack = input[:buildpack] if input.has?(:buildpack)
    end

    def display_changes(app)
      return unless app.changed?

      line "Changes:"

      indented do
        app.changes.each do |attr, (old, new)|
          line "#{c(attr, :name)}: #{diff_str(attr, old)} -> #{diff_str(attr, new)}"
        end
      end
    end

    def commit_changes(app)
      if app.changed?
        with_progress("Updating #{c(app.name, :name)}") do
          wrap_message_format_errors do
            app.update!
          end
        end
      end

      if input[:restart] && app.started?
        invoke :restart, :app => app
      end
    end

    private

    def diff_str(attr, val)
      case attr
      when :memory
        human_mb(val)
      when :command, :buildpack
        "'#{val}'"
      else
        val
      end
    end

    def bool(b)
      if b
        c("true", :yes)
      else
        c("false", :no)
      end
    end
  end
end
