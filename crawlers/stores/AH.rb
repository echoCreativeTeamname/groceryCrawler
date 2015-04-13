require 'open-uri'
require 'json'
require 'date'
require 'nokogiri'

module Crawler::Stores
  class AH < Crawler::Store

    def initialize(logger)
      @name = "Albert Heijn"

      super logger
    end

    def products
      i = 0 # current page

      # information about number of products etc.
      startinformation = Nokogiri::HTML(open("http://www.ah.nl/zoeken?rq=a&sorting=name_asc&offset=#{i*60}").read)
      products_per_page = 60
      total_products = startinformation.css(".right").text.split(" ")[2].to_i

      puts total_products

      loop do

        # Check if loop should stop
        if(products_per_page * i > total_products)
          break
        end

        @logger.debug "Current product page: #{i}"

        products = Nokogiri::HTML(open("http://www.ah.nl/zoeken?rq=a&sorting=name_asc&offset=#{i*products_per_page}").read).css("[data-appie='productpreview']")

        # loop through every product
        products.each do |product|

          # product name
          name = product.css(".image > img").attribute('alt').to_s

          # Get the un-parsed amount
          amount = product.css(".unit").text.strip

          # Change all the amount types to types we know
          amount_change_hash = {
            "per stuk" => "1 stks",
            "per bos" => "1 stks",
            "per paar" => "1 stks",
            "per set" => "1 stks",
            "stuks" => "stks",
            "gr" => "g",
            "lt" => "l",
            "," => ".",
            "rollen" => "stks",
            "ca. " => "",
            "zakjes" => "stks",
            "paar" => "stks",
            "mtr" => "m",
            "plakjes" => "stks",
            "g." => "g",
            "tabl" => "stuks"
          }

          regex_amount_change_hash = [{regex: /[0-9]+-[0-9]+ pers./, replace: "\\2 stks"}]

          amount_change_hash.each do |key, value|
            amount.gsub!(key, value)
          end

          regex_amount_change_hash.each do |hash|
            amount.gsub!(hash[:regex], hash[:replace])
          end

          if(amount =~ /([0-9.,]+)[\space][x][\space]([0-9.,]+)/)
            regex_matches = /([0-9.,]+)[\space][x][\space]([0-9.,]+)/.match(amount).captures
            amount.gsub!(/([0-9.,]+)[\space][x][\space]([0-9.,]+)/, (regex_matches[0].to_f * regex_matches[1].to_f).to_s)
          end

          # product price
          price = product.css(".price").text.strip.to_f

          #puts "#{name} (#{amount}/#{price})" # debug

          # Update/save this information in the database
          if(dbproduct = Product.find_by(identifier: name, storechain: @storechain))
            dbproduct.update_attributes(price: price)
          else
            Product.create(name: name, price: price, amount: amount, identifier: name, storechain: @storechain)
          end
        end

        # Go to next page
        i+=1
      end

    end #/products

    def stores

      #http://www.ah.nl/data/winkelinformatie/winkels/json
      #http://www.ah.nl/winkel/1465?skipSitestat=true

      # Get list of all stores
      stores = JSON.parse(open('http://www.ah.nl/data/winkelinformatie/winkels/json').read)["stores"]

      stores.each do |store|

        # Download more info about the store
        fullstoreinformation = Nokogiri::HTML(open("http://www.ah.nl/winkel/#{store['no']}?skipSitestat=true").read)

        # Check if we already know this store
        unless(currentstore = ::Store.where(identifier: store["no"], chain: @storechain).first)

          # Save store in the database
          currentstore = ::Store.new(
            name: store["street"],
            street: "#{store["street"]} #{store["housenr"]}",
            city: store["city"],
            postalcode: store["zip"],
            latitude: store["lat"],
            longitude: store["lng"],
            identifier: store["no"],
            chain: @storechain
          )

        end

        # Update lastupdated for this store
        currentstore.lastupdated = DateTime.now

        unless(currentstore.save)
          @logger.error "Couldn't save store with identifier #{store["no"]} from #{@name}."
        end

        # Save all Openinghours for store
        beginningofweek = Date.today.beginning_of_week
        openinghours = fullstoreinformation.css("[itemprop=\"openingHours\"]")

        7.times do |i|

          openinghour = openinghours[i].css("td")
          day = beginningofweek + i

          w1 = openinghour[1].text
          if(w1 != "gesloten" && ::Openinghour.where(store: currentstore, date: day).size == 0)
            w1 = w1.split(" – ")

            # Save openinghour to the database
            begin
              newopeninghour = ::Openinghour.new(
                store: currentstore,
                date: day,
                openingtime: Time.parse(w1[0]),
                closingtime: Time.parse(w1[1])
              )

              unless(newopeninghour.save)
                @logger.error "Couldn't save openinghour with for store #{unparsedstoresmall["uuid"]} from #{@name} on day #{day}."
              end
            rescue ArgumentError
              @logger.error "Couldn't save openinghour with for store #{unparsedstoresmall["uuid"]} from #{@name} on day #{day}."
            end

          end

          day = beginningofweek + i + 7
          w2 = openinghour[2].text
          if(w2 != "gesloten" && ::Openinghour.where(store: currentstore, date: day).size == 0)
            w2 = w2.split(" – ")

            # Save openinghour to the database
            begin
              newopeninghour = ::Openinghour.new(
                store: currentstore,
                date: day,
                openingtime: Time.parse(w2[0]),
                closingtime: Time.parse(w2[1])
              )

              unless(newopeninghour.save)
                @logger.error "Couldn't save openinghour with for store #{unparsedstoresmall["uuid"]} from #{@name} on day #{day}."
              end
            rescue ArgumentError
              @logger.error "Couldn't save openinghour with for store #{unparsedstoresmall["uuid"]} from #{@name} on day #{day}."
            end

          end

        end


      end #/each store
    end #/stores

  end
end
