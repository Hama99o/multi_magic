# == Schema Information
#
# Table name: blog_app_articles
#
#  id           :bigint           not null, primary key
#  title        :string
#  subtitle     :text
#  published_at :datetime
#  user_id      :bigint           not null
#  deleted_at   :datetime
#  status       :integer          default("trashed"), not null
#  description  :jsonb
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  duration     :string
#
# Indexes
#
#  index_blog_app_articles_on_user_id  (user_id)
#
FactoryBot.define do
  factory :blog_app_article, class: 'BlogApp::Article' do
    title { "MyText" }
    description { "MyText" }
    user factory: %i[user]
  end
end
