require 'anemone'
require 'cgi'
require 'pg'

#url = "http://hopamviet.com/"
url = "http://hopamviet.com/chord/alphabet/a"
valid_url_patterns = {
  :pagination_regex => /^http:\/\/hopamviet\.com\/chord\/alphabet\/[a-z]+\/[0-9]*$/,
  :post_regex => /^http:\/\/hopamviet\.com\/chord\/detail\/[0-9]+\/[a-zA-Z0-9-]*$/
}

options = {
  # run 4 Tentacle threads to fetch pages
  :threads => 4,
  # disable verbose output
  :verbose => false,
  # don't throw away the page response body after scanning it for links
  :discard_page_bodies => false,
  # identify self as Anemone/VERSION
  :user_agent => "Anemone/#{Anemone::VERSION}",
  # no delay between requests
  :delay => 0,
  # don't obey the robots exclusion protocol
  :obey_robots_txt => false,
  # by default, don't limit the depth of the crawl
  #:depth_limit => false,
  :depth_limit => 1,
  # number of times HTTP redirects will be followed
  #:redirect_limit => 5,
  # storage engine defaults to Hash in +process_options+ if none specified
  :storage => nil,
  # Hash of cookie name => value to send with HTTP requests
  :cookies => nil,
  # accept cookies from the server and send them back?
  :accept_cookies => false,
  # skip any link with a query string? e.g. http://foo.com/?u=user
  :skip_query_strings => false,
  # proxy server hostname 
  :proxy_host => nil,
  # proxy server port number
  :proxy_port => false,
  # HTTP read timeout in seconds
  :read_timeout => nil
}

#db_conf = {
#  :dbname => 'pocket_chords',
#  :user=> 'khang',
#  :password => '123'
#}
#def setup_db() 
#  conn = PG.connect(dbname: db_conf[:dbname], user: db_conf[:user], password: db_conf[:password] )
#end

Anemone.crawl(url, options) do |anemone|
  anemone.storage = Anemone::Storage.MongoDB
  # focus_crawl receive a block to filter links you want to get on a page, 
  #this block will be called when anemone start processing a page to get all links on that page.
  #it should return an array of links.
  anemone.focus_crawl do |page|
    unless page.url.to_s =~ valid_url_patterns[:post_regex]
      links = page.links.select do |link| 
        link.to_s =~ Regexp.union(valid_url_patterns.values)
      end
    else
      links = []
    end
    #puts "================== #{page.url.to_s}"
    #puts links.size
    #links.each {|link| puts link}
    links
  end

  anemone.on_every_page do |page| 
    # Process the post
    if page.url.to_s =~ valid_url_patterns[:post_regex]
      puts "================== #{page.url.to_s}"
      # Get url name of the song
      puts page.url.to_s.split("/").last

      # Get song name
      name = page.doc.xpath("//h3")
      name = name.to_s.gsub(/<\/?[^>]*>/, "").gsub(/\\s+/, " ").strip
      puts name
    end
  end

end
