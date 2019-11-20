desc 'Automatically add reasonable half-width spaces between Latin and CJK characters in topic title and post content'
task 'cjk:text_spacing' => :environment do
  Post.where(topic_id: 11961).each do |p|
    r = p.raw.dup
    puts r.auto_correct!
  end
end

