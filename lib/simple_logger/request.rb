module SimpleLogger
  class Request < Loggable
    attr_reader :data

    DEFAULT_LOGGED_KEYS = [
      :method, :path, :query, :status,
      :remote_ip, :user_agent, :language,
      :referrer, :request_uri
    ]

    def type
      :request
    end

    def ignore?
      self.value_for(:path) =~ SimpleLogger.config.ignore_paths
    end

    def serialize
      Hash[self.class.logged_keys.map {|key| [key, self.value_for(key)] }]
    end

    def value_for(key)
      value = super(key)
      case key
      when :query
        value = SimpleLogger::Helpers.symbolize_keys(::Rack::Utils.parse_nested_query(value)) unless value.is_a?(Hash)
      end
      value
    end

    class << self
      def logged_keys
        @@logged_keys ||= DEFAULT_LOGGED_KEYS
      end

      def include_key(key)
        logged_keys << key.to_sym
      end

      def exclude_key(key)
        logged_keys.delete(key.to_sym)
      end
    end
  end
end
