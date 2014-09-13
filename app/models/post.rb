class Post < ActiveRecord::Base
  belongs_to :blog

  validates :media, presence: true, uniqueness: true

  scope :videos, -> { where(category: "video").order(created_at: :desc) }
  scope :pictures, -> { where(category: "picture").order(created_at: :desc) }

  def self.define_media(content, feed, media_url)
    content = content
    feed = feed
    fail = "http://www.coin.it/repository/bigevents/thumb/ico-youtube-26-09-07.jpg"

    if feed.match(/.*gdata.*/).present?
      media_url.gsub!(/(watch\?v\=)/, 'embed/').gsub!(/(&.*gdata)/, '')
      @media = media_url
      @category = "video"
    else  
      if content.match(/(http:..www.youtube.com.embed.*?)\"/).present?
         @media = content.match(/(http:..www.youtube.com.embed.*?)\"/)[1]
         @category = "video"
      elsif content.match(/(http:..player.vimeo.com.video.\d+)/).present?            
        @media = content.match(/(http:..player.vimeo.com.video.\d+)/)[1]
        @category = "video"
         else
           if content.match(/src="(http.*?(png|gif|jpg|jpeg))"/).present?
             @media = content.match(/src="(http.*?(png|gif|jpg|jpeg))"/) ? content.match(/src="(http.*?(png|gif|jpg|jpeg))"/)[1] : fail
          	 @category = "picture"
           end
      end
    end
  end

  def self.update_from_feed(feed_url)
  	feed = Urss.at(feed_url)
  	#feed = Feedjira::Feed.fetch_and_parse(feed_url)
  	records = Post.where(blog_id: "#{@blog.id}")

  	feed.entries.each do |entry|

    	if records
        count = (records.length)-1
        fail = 0
        n = (records.length)-1 #< 10 ? records.length-1 : 10

        n.times do
          if records[count].url == entry.url #check for duplicates
            fail += 1 #number of times found duplicates if 0 creates new record
            count -= 1
          else
            count -= 1
          end
        end

      end

      if fail == 0
        @content = entry.content
        @url = entry.url

          Post.define_media(@content, @blog.feed, @url)
          #if string.match(/(src\W+)/).present? and string.match(/.(png|jpg|gif|jpeg)/).present?
          #  string = string.match(/src="(http.*?(png|gif|jpg|jpeg))"/) ? string.match(/src="(http.*?(png|gif|jpg|jpeg))"/)[1] : fail
          #elsif string.match(/href='(http.*?(youtube).*?)'/).present? 
            ##para vimeo|youtube: /(http:..player.vimeo.com.video.\d+)|(http:..www.youtube.com.*?)\"/
          #  string = entry.url
          #end
          
    		create(
    			media: @media,
          		title: entry.title,
          		url: entry.url,
    			category: @category,   			
    			blog_id: @blog.id
    		).valid?
      else
        next
      end
  	end	
  end

  def self.update
  	blogs = Blog.all

  	blogs.each do |blog|
  		@blog = blog
      url = URI.parse(@blog.feed)
      req = Net::HTTP.new(url.host, url.port)
      res = req.request_head(url.path)

  		  if res.code == "200"
          Post.update_from_feed(@blog.feed)
        else
          next
        end
  	end
  end
end
