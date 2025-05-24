Meilisearch::Rails.configuration = {
  meilisearch_url: ENV.fetch("MEILISEARCH_HOST", "http://localhost:7701"),
  meilisearch_api_key: ENV.fetch("MEILISEARCH_API_KEY", nil)
}
