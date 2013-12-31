require "cf/cli"

module LoginRequirements
  def precondition
    check_logged_in

    unless client.current_organization
      "Please select an organization with 'cf target --organization ORGANIZATION_NAME'. (Get organization names from 'cf orgs'.)"
    end

    unless client.current_space
      "Please select a space with 'cf target --space SPACE_NAME'. (Get space names from 'cf spaces'.)"
    end
  end
end
