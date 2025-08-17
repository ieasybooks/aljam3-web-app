# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://aljam3.com"
SitemapGenerator::Sitemap.compress = false

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
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  add categories_path, priority: 0.9, lastmod: Category.maximum(:updated_at)
  add authors_path, priority: 0.9, lastmod: Author.maximum(:updated_at)
  add books_path, priority: 0.9, lastmod: Book.maximum(:updated_at)

  Category.find_each do |category|
    add category_path(id: category.id), priority: 0.7, lastmod: category.updated_at
  end

  Author.find_each do |author|
    add author_path(id: author.id), priority: 0.7, lastmod: author.updated_at
  end

  Book.joins(files: :pages)
      .select("books.*, pages.id as first_page_id, pages.number as first_page_number, pages.book_file_id as first_page_file_id")
      .where('pages.number = (
        SELECT MIN(p2.number)
        FROM pages p2
        INNER JOIN book_files bf2 ON p2.book_file_id = bf2.id
        WHERE bf2.book_id = books.id
      )')
      .find_each do |book|
        add book_file_page_path(book_id: book.id, file_id: book.first_page_file_id, page_number: book.first_page_number), priority: 0.5, lastmod: book.updated_at
      end
end
