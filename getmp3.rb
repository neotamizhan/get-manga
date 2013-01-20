require 'cgi'
require 'open-uri'
require 'net/http'
require 'nokogiri'

def fetch(uri_str, limit = 2)
  # You should choose better exception.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  response = Net::HTTP.get_response(URI.parse(uri_str))
  case response
  when Net::HTTPSuccess     then response
  when Net::HTTPRedirection then response['location']
  else
    response.error!
  end
end

def get_urls page_url
  Nokogiri::HTML(open(page_url)).inner_html.scan(/href="(.*download.tamilwire.com.*\.mp3)"/).flatten
end

def download_file(url, folder)
  begin    
    url = fetch(url).gsub(' ', '%20')
    file_name = url.split("\")[-1] #last part of the url
    dest = "#{folder}\\#{file_name}"
    File.open(dest, "wb") do |saved_file|
      open(url, "rb") do |read_file|
        saved_file.write(read_file.read)
      end
    end
  rescue Exception => e
    puts "Error #{e.message} : Downloading #{url}"
  end
end

def download(page_url)
  folder = "~\\Downloads\\paradesi"  
  get_urls(page_url).each do |url|
    download_file(url, folder)
  end  
end

download("http://mp3.tamilwire.com/paradesi-2012.html")

