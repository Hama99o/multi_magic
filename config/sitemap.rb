# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = ENV['VITE_API_URL']
SitemapGenerator::Sitemap.compress = false  # Keep as false if you want to see the XML in the browser

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  BlogApp::Article.find_each do |article|
    add(
      "blog_app/articles/#{article.id}",
      lastmod: article.updated_at,
      changefreq: 'weekly',
      priority: 0.5,
    )
  end
end
