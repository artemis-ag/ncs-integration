require 'net/http'
require 'uri'
require 'httparty'

module CCA
  include Constants
  include Errors

  class Client
    #headers 'Content-Type' => 'application/json'

    attr_accessor :debug,
                  :response,
                  :api_key,
                  :parsed_response,
                  :uri

    def initialize(opts = {})
      @debug = opts[:debug]
      @api_key = opts[:api_key]
      @uri = opts[:uri]
      #self.class.default_params Bearer: api_key
      sign_in
    end

    def api_get(url, options = {})
      puts "in api_get: #{@uri}#{url}" if @debug
      self.response = HTTParty.get("#{@uri}#{url}",
                                   :headers => {'Authorization' => "Bearer #{@api_key}", 'Content-Type' => 'application/json'}
      )
      puts self.response.response.code if debug
      puts self.response.headers if debug
      puts self.response.body if debug
      raise_request_errors
      JSON.parse(self.response.body)
    end

    def api_post(url, body)
      puts "in api_post #{@uri}#{url}" if @debug
      self.response = HTTParty.post("#{@uri}#{url}",
                                    :headers => {'Authorization' => "Bearer #{@api_key}", 'Content-Type' => 'application/json'},
                                    :body => body
      )
      puts self.response.response.code if debug
      puts self.response.headers if debug
      puts self.response.body if debug
      raise_request_errors
      #JSON.parse(self.response.body)
    end

    def api_delete(url, options = {})
      options.merge!('Authorization' => api_key)
      puts "\nCCA API Request debug\nclient.delete('#{url}', #{options})\n########################\n" if debug
      self.response = self.class.get(url, options)
      raise_request_errors
      if debug
        puts "\nCCA API Response debug\n#{response.to_s[0..360]}\n[200 OK]\n########################\n"
        response
      end
    end

    def api_put(url, options = {})
      options.merge!('Authorization' => api_key)
      puts "\nCCA API Request debug\nclient.put('#{url}', #{options})\n########################\n" if debug
      self.response = self.class.get(url, options)
      raise_request_errors
      if debug
        puts "\nCCA API Response debug\n#{response.to_s[0..360]}\n[200 OK]\n########################\n"
        response
      end
    end

    def get(resource, resource_id)
      api_get("pos/#{resource}/v1/#{resource_id}")
    end

    def post(resource, resource_id, resources)
      api_post("pos/#{resource}/v1/#{resource_id}", resources)
    end

    #----- ROOMS
    #
    def room_get_all
      get('rooms', 'all')
    end

    def room_create(room)
      post('rooms', 'create', JSON.generate([room]))
    end

    def room_update(room)
      post('rooms', 'update', JSON.generate([room]))
    end

    #----- STRAINS
    #
    def strain_create(strain)
      post('strains', 'create', JSON.generate([strain]))
    end

    def strain_update(strain)
      post('strains', 'update', JSON.generate([strain]))
    end

    def strain_get_all
      get('strains', 'all')
    end

    #----- ITEMS and ITEM CATEGORIES
    #
    def item_category_create(category)
      post('items', 'create/categories', JSON.generate([category]))
    end

    def item_category_update(category)
      post('items', 'update/categories', JSON.generate([category]))
    end

    def item_category_get_all
      get('items', 'categories')

    end

    def item_create(item)
      post('items', 'create', JSON.generate([item]))
    end

    def item_update
      post('items', 'update', JSON.generate([item]))
    end

    def item_get_all
      get('items', 'all')
    end

    #----- PLANT BATCHES
    #
    def plant_batches_get_active
      get('plantbatches', 'active')
    end

    def plant_batches_get_inactive
      get('plantbatches', 'active')
    end

    def plant_batches_get_by_id(id)
      get('plantbatches', "plantid/#{id}")
    end

    def plant_batches_create_planting(planting)
      post('plantbatches', 'createplantings', JSON.generate([planting]))
    end

    def plant_batches_create_package(package)
      post('plantbatches', 'createpackages', JSON.generate([package]))
    end

    def plant_batches_destroy(plantbatch)
      post('plantbatches', 'destroy', JSON.generate([plantbatch]))
    end

    def plant_batches_change_growth_phase(plantbatch)
      post('plantbatches', 'changegrowthphase', JSON.generate([plantbatch]))
    end

    #----- PLANTS
    #
    def plants_get_all
      get('plants', 'all')
    end

    def plants_get_vegetative
      get('plants', 'vegetative')
    end

    def plants_get_flowering
      get('plants', 'flowering')
    end

    def plants_get_by_id(id)
      get('plants', "#{id}")
    end

    def plants_create_planting(planting)
      post('plants', 'create/plantings', JSON.generate([planting]))
    end

    def plant_destroy_plant(planting)
      post('plants', 'destroyplants', JSON.generate([planting]))
    end

    def plant_change_growth_phases(planting)
      post('plants', 'changegrowthphases', JSON.generate([planting]))
    end

    def plants_move_plant(planting)
      post('plants', 'moveplants', JSON.generate([planting]))

    end

    def plant_manicure_plant(planting)
      post('plants', 'manicureplants', JSON.generate([planting]))

    end

    def plant_harvest_plant(planting)
      post('plants', 'harvestplants', JSON.generate([planting]))
    end

    #----- HARVESTS
    #
    #----- PACKAGES
    #
    #----- SALES
    #
    #----- TRANSFERS
    #

    private

    def sign_in
      raise Errors::MissingConfiguration if configuration.incomplete?

      true
    end

    def configuration
      CCA.configuration
    end

    def raise_request_errors
      return if response.success?
      raise Errors::BadRequest.new("An error has occurred while executing your request. #{CCA::Errors.parse_request_errors(response: response)}") if response.bad_request?
      raise Errors::Unauthorized.new('Invalid or no authentication provided.') if response.unauthorized?
      raise Errors::Forbidden.new('The authenticated user does not have access to the requested resource.') if response.forbidden?
      raise Errors::NotFound.new('The requested resource could not be found (incorrect or invalid URI).') if response.not_found?
      raise Errors::TooManyRequests.new('The limit of API calls allowed has been exceeded. Please pace the usage rate of the API more apart.') if response.too_many_requests?
      raise Errors::InternalServerError.new('An error has occurred while executing your request.') if response.server_error?
    end
  end

end
