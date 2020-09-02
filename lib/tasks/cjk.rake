desc 'Automatically add reasonable half-width spaces between Latin and CJK characters in topic title and post content'
task 'cjk:text_spacing' => :environment do
  Post.where("posts.created_at >= ?", Date.today - 60.days) do |post|
    post.update("baked_version = NULL")
    post.update("raw = ?", post.raw.dup.auto_correct!)
    topic = Topic.where("id = ?", post.topic_id)
    topic.update("title = ?", topic.title.dup.auto_correct!)
    topic.update("excerpt = ?", topic.excerpt.dup.auto_correct!)
    topic.update("fancy_title = ?", topic.fancy_title.dup.auto_correct!)
  end
  Rake::Task["posts:rebake_uncooked_posts"].invoke
end

