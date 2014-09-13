desc "This task is called by the Heroku scheduler add-on"

#rake crawl
task :posts_update => :environment do
  puts "Updating..."
  Post.update
  puts "done."
end