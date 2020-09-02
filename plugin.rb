# name: discourse-cjk-text-spacing
# about: automatically add a half-width whitespace between Latin/CJK characters.
# version: 2.0.0
# authors: Marguerite Su <marguerite@opensuse.org>
# url: https://github.com/openSUSE-zh/discourse-cjk-text-spacing

gem 'auto-correct', '0.3.1'
require 'json'

CJK_WORD_LIST = Dir.glob(File.join(File.dirname(__FILE__), 'dict') + '/*.json')
                   .map! do |f|
  JSON.parse(File.open(f, 'r:UTF-8').read)
end.reduce({}, :merge!)

after_initialize do
  String.class_eval do
    alias_method :old_auto_correct!, :auto_correct!
    def auto_correct!
      # sometimes we meet frozen string like bot's message
      unless frozen?
        begin
          old_auto_correct!
        rescue => e
          Discourse.warn_exception(e, message: "Plugin cjk-text-spacing: auto-correct gem crashed with unknown error, string will remain unformatted: #{self}")
        end
      else
        Discourse.warn("Plugin cjk-text-spacing: auto-correct gem crashed with frozen string error", string: self)
      end
      scan(/[A-Za-z]+/).each do |s|
        if CJK_WORD_LIST.key?(s.downcase)
          sub!(s, CJK_WORD_LIST[s.downcase])
        else
          Discourse.warn("Plugin cjk-text-spacing: unhandled word", word: s)
        end
      end
      self
    end
  end

  NewPostManager.class_eval do
    def initialize(user, args)
      @user = user
      args[:title] = args[:title].auto_correct! if args[:title].present?
      args[:raw] = args[:raw].auto_correct!
      @args = args.delete_if { |_, v| v.nil? }
    end
  end

  PostRevisor.class_eval do
    alias_method :old_revise!, :revise!

    def revise!(editor, fields, opts = {})
      fields[:raw] = fields[:raw].auto_correct! if fields[:raw].present?
      fields[:title] = fields[:title].auto_correct! if fields[:title].present?
      old_revise!(editor, fields, opts)
    end
  end
end
