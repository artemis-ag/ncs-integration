module NcsAnalytics
  module Resources
    class Sale < NcsAnalytics::Resource
      def all
        get(:receipts)
      end

      def create(payload)
        # TODO: Validate the payload
        payload = [payload] unless payload.is_a?(Array)
        post(:receipts, payload)
      end
    end
  end
end
