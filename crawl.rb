require 'nokogiri'
require 'selenium-webdriver'
require 'sequel'

# baseUrl = 'https://allegro.pl/kategoria/podzespoly-komputerowe-procesory-257222?stan=nowe&offerTypeBuyNow=1&order=qd'
# baseUrl = 'https://allegro.pl/kategoria/trening-fitness-rowery-treningowe-110140?order=qd'

keywordPrefix ='&string='

# keyword ='kettler'

if ARGV.length == 2
    baseUrl = ARGV[0]

    keyword = ARGV[1]
    baseUrl = baseUrl + keywordPrefix + keyword
    puts baseUrl

elsif ARGV.length == 1
    puts "in"
    baseUrl = ARGV[0]
    puts ARGV[0]

else
    puts "give args [0] - url of category, [1](optional) - keyword"
    exit
end


# exit



driver = Selenium::WebDriver.for :firefox
DB = Sequel.connect('mysql2://root:root@127.0.0.1:3306/crawled') 
items = DB[:items]



driver.get(baseUrl)

data = driver.page_source

doc = Nokogiri.HTML5(data)

max_page = doc.xpath("//span[@class='_1h7wt mgmw_wo mh36_8 mvrt_8 _6d89c_wwgPl _6d89c_oLeFV']")

doc.xpath("//span[@class='_1h7wt mgmw_wo mh36_8 mvrt_8 _6d89c_wwgPl _6d89c_oLeFV']").each do |max|
    max_page = max.content
end

pages_to_visit = max_page





pages_to_visit = 2 # comment out to do full scraping

page_no = 0


while page_no < pages_to_visit do
    page_no += 1
    puts "start page" + page_no.to_s
    driver.get(baseUrl + '&p=' + page_no.to_s)
    

    data = driver.page_source
    doc = Nokogiri.HTML5(data)


    doc.xpath("//div[@class='mpof_ki mqen_m6 mp7g_oh mh36_8 mvrt_8 mg9e_8 mj7a_8 m7er_k4 mjyo_6x _1y62o _6a66d_snEkI _6a66d_wdSAd']").each do |position|
   
        name_to_save =''
        price_to_save =''
        link_to_save =''
        params_to_save =''


        sleep(2)
        positionDoc= Nokogiri.HTML5(position)


        positionDoc.xpath("//a[@class='_w7z6o _uj8z7 meqh_en mpof_z0 mqu1_16 m6ax_n4 _6a66d_LX75-  ']").each do |name|
            puts name.content
            name_to_save = name.content
        end


        positionDoc.xpath("//span[@class='mli8_k4 msa3_z4 mqu1_1 mgmw_qw mp0t_ji m9qz_yo mgn2_27 mgn2_30_s']").each do |price|
            puts price.content
            price_to_save = price.content
        end


        positionDoc.xpath("//a[@class='_w7z6o _uj8z7 meqh_en mpof_z0 mqu1_16 m6ax_n4 _6a66d_LX75-  ']/@href").each do |link|
            if link.content.include? "events/clicks"
                puts "link with redirect, will get you blocked, dont follow via normal request without context, only from selenium/browser during browsing, no point of saving the offer, can be fixed by clicking inside and checking current url"
                
                link_to_save = 'context link, use selenium to visit this page by cliks instead of get'
                
                items.insert(name: name_to_save, price: price_to_save, link: link_to_save, itemparams: params_to_save)
                
            else
                puts link.content
                link_to_save = link.content

                driver.get(link.content)
                puts "in link"
                # do parsing on subpage
                sleep(2)                
                subpage_data = driver.page_source
                subpage_doc = Nokogiri.HTML5(subpage_data)
                puts "paramki"
                subpage_doc.xpath("//*[@class='myre_zn mp7g_oh m7er_k4 qh857 mp0t_0a msts_pt']").each do |param|
                   
                   
                    # puts param.content # to sa dane wewnatzr tabelki
                    # puts param
                    rows_doc = Nokogiri.HTML5(param)
                    rc = ''
                    rows_doc.xpath("//tr[@class='mlkp_ag mnyp_co mx7m_0 q1728 qkenm mgn2_14']").each do |row|
                        rc += row.content
                        # puts row.content
                    end
                params_to_save = rc
                items.insert(name: name_to_save, price: price_to_save, link: link_to_save, itemparams: params_to_save)

                end
                #go back, parsed subpage details
                driver.navigate.back

            end
        end
    end
    # puts "end page" + page_no.to_s

end


driver.quit
