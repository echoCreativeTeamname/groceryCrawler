module Crawler
  class Store

    def initialize(logger)
      @logger = logger

      #find storechain
      unless(@storechain = Storechain.where(name: @name).first)
        @logger.error "Couldn't find the correct storechain for store #{@name}, creating new one"
        @storechain = Storechain.create(name: @name)
      end
    end


  end
end
