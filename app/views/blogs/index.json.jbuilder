json.array!(@blogs) do |blog|
  json.extract! blog, :id, :name, :url, :feed, :category
  json.url blog_url(blog, format: :json)
end
