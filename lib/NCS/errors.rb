module NCS
  module Errors
    class MissingConfiguration < RuntimeError; end
    class MissingParameter < RuntimeError; end
    class RequestError < RuntimeError; end

    class BadRequest < RequestError; end
    class Unauthorized < RequestError; end
    class Forbidden < RequestError; end
    class NotFound < RequestError; end
    class TooManyRequests < RequestError; end
    class InternalServerError < RequestError; end

    # TODO: This may be Metrc-specific, will have to test
    class << self
      def parse_request_errors(response:)
        body = response.parsed_response
        if body.is_a? Array
          consolidate_errors_by_row(body).join(', ')
        elsif body.is_a? Hash
          body['Message']
        end
      end

      private

      def consolidate_errors_by_row(array)
        errors = array.each_with_object({}) do |errors, row|
          index = row['row']
          if errors[index]
            errors[index] += ", #{row['message']}"
          else
            errors[index] = row['message']
          end
          errors
        end

        errors.map do |index, message|
          "#{index}: #{message}"
        end
      end
    end
  end
end
