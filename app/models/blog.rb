class Blog < ActiveRecord::Base
	include PgSearch
		pg_search_scope :search,
										against: [:name, :url],
										using: {
											tsearch: {
												dictionary: "portuguese"
											}
										}

	has_many :posts, dependent: :destroy

	validates :url, presence: true, uniqueness: true

	after_create :update_feed #, :add_score

	def update_feed #nem sempre consegue pegar o feed, ex.: escoladinheiro.com
		self.update(feed:  FeedSearcher.search(self.url).first) || ""
	end
end
