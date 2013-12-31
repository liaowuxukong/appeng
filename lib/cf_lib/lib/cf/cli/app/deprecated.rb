require "cf/cli/app/base"

module CF::App
  class Deprecated < Base
    desc "DEPRECATED. Use 'push' instead."
    input :app, :argument => :optional
    def update
      fail "The 'update' command is no longer needed; use 'push' instead."
    end
  end
end
