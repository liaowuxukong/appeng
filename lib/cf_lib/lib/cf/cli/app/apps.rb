require "cf/cli/app/base"

module CF::App
  class Apps < Base
    desc "List your applications"
    group :apps
    input :space, :desc => "Show apps in given space",
          :default => proc { client.current_space },
          :from_given => by_name(:space)
    input :name, :desc => "Filter by name regexp"
    input :url, :desc => "Filter by url regexp"
    input :full, :desc => "Verbose output format", :default => false
    def apps
      #if space = input[:space]
      if space = client.current_space
        begin
          space.summarize!
        rescue CFoundry::APIError
        end

        apps =
          with_progress("Getting applications in #{c(space.name, :name)}") do
            space.apps
          end
      else
        apps =
          with_progress("Getting applications") do
            client.apps(:depth => 2)
          end
      end

      app_infos = []

      line unless quiet?

      if apps.empty? and !quiet?
        #line "No applications."
        return [true,app_infos]
      end

      apps = apps.sort_by(&:name)

      apps.each do |app|
        health = app.health
        health = 
          if app.debug_mode == "suspend" && health == "0%"
            "suspended"
          else
            health.downcase
        end
        app_infos << { name: app.name,
                       instance:app.total_instances,
                       memory_limit: human_mb(app.memory).downcase,
                       status: health,
                       domain: app.url }

      end
      return [true,app_infos]
    end

  end
end
