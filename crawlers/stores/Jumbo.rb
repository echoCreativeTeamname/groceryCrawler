require 'open-uri'
require 'json'
require 'date'
require 'nokogiri'

module Crawler::Stores
  class Jumbo < Crawler::Store

    def initialize(logger)
      @name = "Jumbo Supermarkten"
      @sid_cookie = open('http://www.jumbo.com').meta['set-cookie'].split('; ', 2)[0]

      super logger
    end

    def products
      i = 0 # Current page

      loop do
        @logger.debug "Current product page: #{i}"
        unparsedproductspage = Nokogiri::HTML(open("http://www.jumbo.com/producten?PageNumber=#{i}"))
        unparsedproducts = unparsedproductspage.css(".jum-result")

        # Check if products page is empty
        if(unparsedproducts.size == 0)
          break
        end

        unparsedproducts.each do |product|
          unparsedprice = product.css(".jum-sale-price > .jum-price-format").text
          if(product.css(".jum-sale-price-info > .jum-pack-size").text != "")
            amount = product.css(".jum-sale-price-info > .jum-pack-size").text
          else
            amount = "1 " + product.css(".jum-comparative-price").text.split("/")[1].split(")")[0]
          end

          amount_change_hash = {
            "stuks" => "stks",
            "stuk" => "stks",
            "kilo" => "kg",
            "liter" => "l"
          }

          amount_change_hash.each do |key, value|
            amount.gsub!(key, value)
          end


          price = [unparsedprice[0..-3], unparsedprice[-2..-1]].join(".").to_f

          puts "#{product.css("h3 > a").text}: #{price} (#{amount})"

          Product.create(name: product.css("h3 > a").text, price: price, chain: @storechain, amount: amount)
        end

        # Go to next page
        i+=1
      end
    end

    def stores

      # Get list of all stores
      unparsedlist = JSON.parse(open('http://www.jumbo.com/INTERSHOP/rest/WFS/Jumbo-Grocery-Site/webapi/stores', 'Cookie' => @sid_cookie).read)["stores"]

      # Cooldown time
      sleep(1.0/4.0)

      # Get info of each store and save it in the database
      unparsedlist.each do |unparsedstoresmall|

        # Download more info about the store
        unparsedstore = JSON.parse(
          open(
            "http://www.jumbo.com/INTERSHOP/rest/WFS/Jumbo-Grocery-Site/webapi/stores/#{unparsedstoresmall["uuid"]}",
            'Cookie' => @sid_cookie
          ).read
        )

        # Check if it should actually save the store
        if(unparsedstore["attributes"]["location_type"]["value"] == "PuP")
          return
        end

        # Check if we already know this store
        unless(currentstore = ::Store.where(identifier: unparsedstoresmall["uuid"], chain: @storechain).first)

          # Save store in the database
          currentstore = ::Store.new(
            name: unparsedstore["street"],
            street: "#{unparsedstore["street"]} #{unparsedstoresmall["street2"]}",
            city: unparsedstore["city"],
            postalcode: unparsedstore["postalCode"],
            latitude: unparsedstoresmall["latitude"],
            longitude: unparsedstoresmall["longitude"],
            identifier: unparsedstoresmall["uuid"],
            chain: @storechain
          )

        end

        # Update lastupdated for this store
        currentstore.lastupdated = DateTime.now

        unless(currentstore.save)
          @logger.error "Couldn't save store with identifier #{unparsedstoresmall["uuid"]} from #{@name}."
        end

        # Save all Openinghours for store
        dayArray = ["mon", "tues", "weds", "thurs", "fri", "sat", "sun"]
        typesArray = ["This", "Next"]
        beginningofweek = Date.today.beginning_of_week
        for i in 1..14 do

          # Get day string
          savingday = "#{dayArray[(i%7)-1]}#{i <= 7 ? "This" : "Next"}"

          # Check if store isn't closed that day of if we already saved that day
          if(unparsedstore["attributes"]["#{savingday}Open"]["value"] == "Gesloten" || unparsedstore["attributes"]["#{savingday}Open"]["value"] == "Geslote"  || ::Openinghour.where(store: currentstore, date: beginningofweek+(i-1)).size > 0)
            next
          end

          # Save openinghour to the database
          begin
            newopeninghour = ::Openinghour.new(
              store: currentstore,
              date: beginningofweek+(i-1),
              openingtime: Time.parse(unparsedstore["attributes"]["#{savingday}Open"]["value"]),
              closingtime: Time.parse(unparsedstore["attributes"]["#{savingday}Close"]["value"])
            )

            unless(newopeninghour.save)
              @logger.error "Couldn't save openinghour with for store #{unparsedstoresmall["uuid"]} from #{@name} on day #{savingday}."
            end
          rescue ArgumentError
            @logger.error "Couldn't save openinghour with for store #{unparsedstoresmall["uuid"]} from #{@name} on day #{savingday}."
          end
        end

      end #/each store
    end #/stores

  end
end
