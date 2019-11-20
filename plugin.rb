# name: discourse-cjk-text-spacing
# about: automatically add a half-width whitespace between Latin/CJK characters.
# version: 1.0.0
# authors: Marguerite Su <marguerite@opensuse.org>
# url: https://github.com/openSUSE-zh/discourse-cjk-text-spacing

gem 'auto-correct', '0.1.0.pre0'

after_initialize do
  NewPostManager.class_eval do
    def initialize(user, args)
      @user = user
      args[:title] = args[:title].dup.auto_correct! if args[:title].present?
      args[:raw] = args[:raw].dup.auto_correct!
      @args = args.delete_if { |_, v| v.nil? }
    end
  end
end
