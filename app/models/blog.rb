class Blog < ActiveRecord::Base
	has_many :posts

	validates :url, presence: true, uniqueness: true

	after_create :update_feed #, :add_score

	def update_feed #nem sempre consegue pegar o feed, ex.: escoladinheiro.com
		self.update(feed:  FeedSearcher.search(self.url).first) || ""
	end
end
