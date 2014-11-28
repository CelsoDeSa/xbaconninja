class Post < ActiveRecord::Base
  include PgSearch
    pg_search_scope :search,
                    against: :title,
                    using: {
                      tsearch: {
                        dictionary: "portuguese"
                      }
                    }
  belongs_to :blog

  validates :media, presence: true, uniqueness: true

  scope :videos, -> { where(category: "video").order(created_at: :desc) }
  scope :pictures, -> { order(created_at: :desc) }

  BADWORDS = %w(bunda bundas bundinha bundinhas caralho caralhos gostosa gostosas
                sexual sexuais buceta bucetas cu cus merda fuder transar homem homens
                mulher mulheres garoto garotos garota garotas
                )

  def self.content_check(title, content)
    @badwords = 0

    if title
      title_scanned = title.scan(/\w+/)
    else
       title_scanned = [""]
    end

    if content
      content_scanned = content.scan(/\w+/)
    else
      content_scanned = [""]
    end

    BADWORDS.each do |b|
      title_scanned.each do |t|
          if b == t
            @badwords+=1
          end
        end
    end

    BADWORDS.each do |b|
      content_scanned.each do |c|
          if b == c
            @badwords+=1
          end
        end
    end
  end

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
  	#feed = Urss.at(feed_url)
  	feed = Feedjira::Feed.fetch_and_parse(feed_url)
  	records = Post.where(blog_id: "#{@blog.id}")

  	feed.entries.each do |entry|
      @title = entry.title
      @url = entry.url
      @content = entry.content

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

      Post.content_check(@title, @content) #will check for badwords

      if fail == 0 and @badwords == 0
          Post.define_media(@content, @blog.feed, @url)
          #if string.match(/(src\W+)/).present? and string.match(/.(png|jpg|gif|jpeg)/).present?
          #  string = string.match(/src="(http.*?(png|gif|jpg|jpeg))"/) ? string.match(/src="(http.*?(png|gif|jpg|jpeg))"/)[1] : fail
          #elsif string.match(/href='(http.*?(youtube).*?)'/).present?
            ##para vimeo|youtube: /(http:..player.vimeo.com.video.\d+)|(http:..www.youtube.com.*?)\"/
          #  string = entry.url
          #end

    		create(
    			media: @media,
          		title: @title,
          		url: @url,
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

        unless url.path.empty?
          res = req.request_head(url.path)
          res = res.code
        else
          res = "000"
        end

  		  if res == "200"
          Post.update_from_feed(@blog.feed)
        else
          next
        end
  	end
  end
end
