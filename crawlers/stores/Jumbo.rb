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
          price = [unparsedprice[0..-3], unparsedprice[-2..-1]].join(".").to_f

          # Weird way of getting the amount
          unparsed_amount = product.css(".jum-sale-price-info > .jum-comparative-price").text
          unparsed_amount["("] = ""
          unparsed_amount[")"] = ""

          amount_type = unparsed_amount.split("/")[1]
          amount = unparsed_amount.split("/")[0].split(",")
          amount = amount[0].to_f + (amount[1].to_f / 100)

          if(amount != 0)

            amount = price / amount

            # Change all the amount types to types we know
            amount_change_hash = {
              "stuks" => "stks",
              "Stuks" => "stks",
              "stuk" => "stks",
              "kilo" => "kg",
              "liter" => "l"
            }

            amount_change_hash.each do |key, value|
              amount_type.gsub!(key, value)
            end

            # We don't want complicated amounts..
            if(amount_type == "stks")
              amount = amount.round
            else
              amount = amount.round(2)
            end

            amount = amount.to_s + " " + amount_type
            name = product.css("h3 > a").text


            # Update/save this information in the database
            if(dbproduct = Product.find_by(identifier: name, storechain: @storechain))
              dbproduct.update_attributes(price: price)
            else
              Product.create(name: name, price: price, amount: amount, identifier: name, storechain: @storechain)
            end
          end
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
