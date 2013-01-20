#enhanced image save
require 'nokogiri'
require 'open-uri'
require 'yaml'
require "fileutils"

class GetManga

  attr_accessor :params
  @params = {}

  def initialize
    # Load @params and prepare
    @params = YAML::load(DATA)   
  end

  def download!   
    chapters = chapter_range
    if chapters.to_a.size == 1
      puts "Downloading chapter #{chapters.first}"
    else
      puts "Downloading chapters #{chapters.first} to #{chapters.last}" 
    end 
    puts "Total chapters : #{(chapters.max - chapters.min) + 1}"
    puts "*" * 25

    chapter_threads = []

    chapters.each do |chapter|
      chapter_threads << Thread.new(chapter) {|c| download_chapter c}      
    end
    chapter_threads.each {|ct| ct.join}
  end


  def comic_name 
    @params['name'].downcase.gsub(/[^\d|\w| ]/,'').gsub(/ /,'-') #downcase the name, remove special chars and replace spaces with hyphen.
  end


  def chapter_range
    chapters = @params['chapter'].to_s
    chapters = chapters.split('-').map { |e| e.to_i }
    (chapters.first..chapters.last)  
  end

  def create_folder folder
    puts "creating folder #{folder}"
    unless Dir.exists? folder
      FileUtils.mkdir_p folder
    end
  end  

  def get_image_url(page_url)
    Nokogiri::HTML(open(page_url)).inner_html.match(/\<img.*src="(.*#{comic_name}-\d+.jpg)/)[1]
  end

	def download_image(src, dest)
		begin
	    File.open(dest, "wb") do |saved_file|
				open(get_image_url(src), 'rb') do |read_file|
			    saved_file.write(read_file.read)
				end
			end
		rescue Exception => e
			puts "Error #{e.message} : Downloading #{src}"
		end
	end

  def page_count(url)        
      Nokogiri::HTML(open(url)).inner_html.match(/<\/select> of (\d+)/)[1].to_i        
  end
    
  def download_chapter(chapter)
    puts "Downloading chapter #{chapter}"
    url = "#{@params['site']}/#{comic_name}/#{chapter}"

    # get total page numbers
    pages = page_count url
    puts "total pages in chapter #{chapter} is #{pages}"

    # create folders if not available.
    folder = File.join(@params['folder'],comic_name,chapter.to_s)
    create_folder folder

    threads = []

    # for each page
    1.upto pages do |page|
      threads << Thread.new(page) {|pagenum|
        page_url = url + "/" + pagenum.to_s           
        #puts img        
        download_image(page_url, File.join(folder,"#{pagenum}.jpg"))
        print "#"
      }
    end
    threads.each {|aThread| aThread.join}      
  end 

end

GetManga.new.download!

__END__
site: http://www.mangareader.net
name: PSYCHIC ODAGIRI KYOUKO'S LIES
chapter: 1
folder: d:/temp/comics
