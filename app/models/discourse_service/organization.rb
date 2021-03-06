module DiscourseService
  class Organization

    def initialize(organization)
      @organization = organization
    end

    def discourse_id
      @organization.discourse_id
    end

    def name
      "Discussion about #{@organization.name}"
    end

    def description
      "This is the general thread for discussing the organization; the thread is also visible on its page at #{url}
      "
    end

    def url
      Rails.application.routes.url_helpers.organization_url(@organization, host: Figaro.env.url)
    end

    def category
      Figaro.env.discourse_organization_category
    end

    def machine_params
      {title: name, raw: description, category: category}
    end

    def sync
      if discourse_id
        response = client.update_topic(discourse_id, machine_params)
        @organization.update_columns(discourse_errors: nil)
      else
        response = client.create_topic(machine_params)
        @organization.update_columns(discourse_id: response['topic_id'], discourse_errors: nil)
      end
    rescue ArgumentError => e
      @organization.update_column(:discourse_errors, e.message)
    end

    def client
      DiscourseService::Client.instance
    end
  end
end
