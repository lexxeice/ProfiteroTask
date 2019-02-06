require 'curb'
require 'nokogiri'
require 'csv'
# try to connect progressbar - optional

start_time = Time.now
url = ARGV[0] + "?p=#{(page_number = 1)}" || abort('Wrong URL')
file =  if ARGV[1].nil? then 'Petsonic.csv' elsif ARGV[1].end_with?('.csv') then ARGV[1] else ARGV[1] + '.csv' end
puts 'Category page processing'
count = 0
begin
  http = Curl.get(url).body_str
  html = Nokogiri::HTML(http)
  puts "Get product links for page #{page_number}"
  product_links = html.xpath("//*[contains(@class, 'product-list-category-img')]/@href") # get product links
  url = url.sub("?p=#{page_number}","?p=#{page_number += 1}") # change page
  puts 'Product page processing'
  product_links.each do |link|
    http = Curl.get(link).body_str
    html = Nokogiri::HTML(http)
    puts "Collection of product information, number: #{count+=1}"
    name = html.xpath("//h1[contains(@class, 'product_main_name')]").text.strip
    image = html.xpath('//img[@id="bigpic"]/@src')
    parameter_list = []
    html.xpath('//div[@class="attribute_list"]/ul/li/label/span').each do |parameter| # get the list of parameters, weight and price
      parameter_list.push(parameter.text)
    end
    puts "Write product to file, number: #{count}"
    while parameter_list.size > 0
      CSV.open(file, 'a') do |csv| # write to file
        csv << ["#{name} - #{parameter_list.shift}", parameter_list.shift, image]
      end
    end
  end
end while http.size > 0
puts "Lead time #{ (Time.now - start_time).round(2) } sec"



