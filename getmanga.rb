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


<<<<<<< HEAD
  def manga_name 
=======
  def comic_name 
>>>>>>> 60c9b8d846afbb1fcf67ac0cd8b5f8d639287a01
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
<<<<<<< HEAD
    Nokogiri::HTML(open(page_url)).inner_html.match(/\<img.*src="(.*#{manga_name}-\d+.jpg)/)[1]
=======
    Nokogiri::HTML(open(page_url)).inner_html.match(/\<img.*src="(.*#{comic_name}-\d+.jpg)/)[1]
>>>>>>> 60c9b8d846afbb1fcf67ac0cd8b5f8d639287a01
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
<<<<<<< HEAD
    url = "#{@params['site']}/#{manga_name}/#{chapter}"
=======
    url = "#{@params['site']}/#{comic_name}/#{chapter}"
>>>>>>> 60c9b8d846afbb1fcf67ac0cd8b5f8d639287a01

    # get total page numbers
    pages = page_count url
    puts "total pages in chapter #{chapter} is #{pages}"

    # create folders if not available.
<<<<<<< HEAD
    folder = File.join(@params['folder'],manga_name,chapter.to_s)
=======
    folder = File.join(@params['folder'],comic_name,chapter.to_s)
>>>>>>> 60c9b8d846afbb1fcf67ac0cd8b5f8d639287a01
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
