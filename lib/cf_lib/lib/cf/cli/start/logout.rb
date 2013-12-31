require "cf/cli/start/base"

module CF::Start
  class Logout < Base
    def precondition
      check_target
    end

    desc "Log out from the target"
    group :start
    def logout
      with_progress("Logging out") do
        remove_target_info
      end
    end
  end
end
