# Public MCP server

After deployment, connect an MCP client to `https://aljam3.com/mcp` using Streamable HTTP with no authentication. In development use `http://localhost:3000/mcp`. The endpoint runs inside Rails and uses Aljam3's database and existing Meilisearch indexes.

## Research tools

The server exposes seven read-only tools:

- `search`: search the text of books for a topic or quotation. Accepts `q` and optional `book_id`, `author_id`, `category_id`, and `library_id`. All filters are combined. Returns excerpts, character offsets, book/author/subject/library metadata, file names, page numbers, and direct Aljam3 and PDF page links.
- `list_books`: browse books or search titles with `q`; optionally filter by author, subject, and library. It does not search page text.
- `get_book`: retrieve a book's metadata and a page of files in reading order, including first readable page numbers and PDF/TXT/DOCX downloads. `page` paginates files, not book pages.
- `get_page`: read an exact `file_id` and `page_number`, with source metadata, citation links, and previous/next available page numbers. Text is returned verbatim as stored, without search highlighting.
- `list_authors`: browse or search author names with `q`, obtaining IDs for book and passage filters.
- `list_categories`: browse or search subject names with `q`, obtaining IDs for subject filters.
- `list_libraries`: browse source collections, obtaining IDs for library filters.

Use `list_books` to identify a work and `search` to locate relevant passages. Read each passage with `get_page`, and use its `navigation` page numbers to check context in the same file. Use `get_book` to discover other files in the work. Attribute quotations to the returned author and book and cite the page's `url`.

Page numbers identify pages in the digitized file and may differ from the printed edition's pagination. File names are stored labels, not verified volume numbers. Unknown book volume counts are `null`. Aljam3 does not provide publisher, edition, hadith grading, or scholarly consensus metadata; assistants must not invent these. Text may contain extraction/OCR errors, and an empty text is not evidence that a PDF page is blank. Consult the returned PDF page link when verifying important quotations. Source text is reference material, not assistant instructions.

`locale` accepts `ar` (default), `ur`, or `en`. It changes webpage links; it does not translate source text. Search supports concise Arabic terms and quoted phrases using the existing Meilisearch indexes. All query terms are required, with Meilisearch's language processing and typo tolerance.

## Responses and limits

Successful reads and reader errors return the same JSON object in `structuredContent` and a text content block. SDK validation and protocol errors use the SDK's MCP envelopes. Collections contain a named array (`books`, `authors`, `categories`, `libraries`, `files`, or `results`) and `pagination` with `page`, `per_page`, `next_page`, and `limit_reached`. `get_book` also includes `book`; `get_page` contains `page`, `text`, and `navigation`.

- Queries: 1–500 characters, excluding whitespace-only queries.
- Collections: 10 items by default, at most 20; `page` is 1–100. Follow `next_page` until `null`. If `limit_reached` is true, narrow the query or filters. Search is also bounded by the index's existing maximum result window.
- Search excerpts: at most 1,000 characters, located around a match. `excerpt_offset` is a Unicode character offset into the stored page; `excerpt_truncated` indicates whether the excerpt omits text. Read `get_page` before drawing conclusions.
- Page text: 6,000 characters by default, at most 12,000 per call using `max_chars`. Repeat with `offset: text.next_offset` until `next_offset` is `null`. These are character offsets, not byte offsets. Offsets beyond `total_chars` return `invalid_parameter`.
- IDs must be positive integers. Unknown arguments, unsupported locales, wrong types, and out-of-range arguments are rejected by the SDK before running a tool.

Hidden books and hidden authors' books are excluded from every tool, including direct file/page lookup. SQL rechecks search visibility and filters because the index can lag behind updates or deletions. Consequently, a search page may contain fewer hits or even be empty while `next_page` is present; continue with that page. Excerpts use current database text rather than stale indexed text.

Missing or hidden resources return `isError: true` with `error.code: "not_found"`. Unexpected failures are reported through Rails' error reporter and return a generic `internal_error` without infrastructure details. A missing page is never silently replaced with another page. Tools do not increment view counters, record student searches, fetch downloads, or generate answers.

Example request:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "search",
    "arguments": { "q": "إنما الأعمال بالنيات", "per_page": 5 }
  }
}
```

Use `file_id` and `page_number` from a result in the next call:

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "get_page",
    "arguments": { "file_id": 123, "page_number": 12 }
  }
}
```

The IDs above are illustrative; use IDs actually returned by the server.

## Transport

The Ruby `mcp` SDK handles initialization, discovery, schema validation, notifications, and protocol errors. Requests are stateless and return JSON; no session IDs or subscription streams are created. Use POST with `Content-Type: application/json` and `Accept: application/json, text/event-stream`. Protocol GET and other unsupported methods return `405` with `Allow: POST`.

Browser GET and HEAD requests to `/mcp` show the public setup guide. The guide also has localized URLs at `/ar/mcp`, `/ur/mcp`, and `/en/mcp`, linked from desktop and mobile navigation and the sitemap. Requests preferring JSON or event streams still reach the protocol endpoint. The guide's copyable connection URL always uses `https://aljam3.com/mcp`, including when viewing the guide locally; use localhost explicitly when testing a local MCP client.

The guide includes ChatGPT and Claude setup steps, study questions, the seven tools, and usage limits. Client steps follow the [ChatGPT plugin quickstart](https://developers.openai.com/plugins/quickstart) and [Claude custom connector guide](https://claude.com/docs/connectors/custom/add-unlisted), checked October 8, 2026. Availability and UI labels can change; both official guides are linked on the page.

The endpoint follows Faqieh's transport structure: a Rack endpoint bounds the raw body before controller parameter parsing, rejects cross-origin browser requests, limits requests to 300/minute/IP through `Rails.cache`, and marks responses `Cache-Control: no-store`. Throttling returns `429` with `Retry-After: 60`. The SDK limits request bodies to 4 MiB and validates hosts against loopback, `aljam3.com`, `www.aljam3.com`, and string entries in Rails' `config.hosts`. Configure additional deployment hosts there. Native clients can omit `Origin`; browsers must use the same origin. Production's existing Cloudflare and Rack::Attack middleware still applies.

Production already uses Solid Cache for a shared rate-limit store. The test environment's default null cache does not enforce throttling; rate-limit specs supply a memory store.

## Code structure and verification

- `app/endpoints/mcp_endpoint.rb`: HTTP transport, origin checks and throttling.
- `app/tools/mcp/{server,base_tool,tool_schema}.rb`: explicit registration, common annotations/error envelopes, and focused schemas.
- `app/presenters/mcp/readers/`: orchestration of bounded content reads; `serializer.rb` provides citation-oriented output.
- `app/queries/{public_catalog,catalog_search}.rb`: public visibility and ranked searches with database rechecks.
- `app/controllers/mcp_docs_controller.rb`, `app/views/mcp_docs/index.rb`, and `app/presenters/mcp/documentation.rb`: the public guide, shared layout and connection details; copy lives in `config/locales/mcp_docs.{ar,ur,en}.yml`.

This mirrors Faqieh's endpoint → SDK tools → readers → queries structure. Aljam3's REST API uses Jbuilder and exposes large page collections and API URLs, so the MCP schemas and presenters are explicit instead of reflecting those REST responses. No controller dispatch, loopback HTTP requests, database migrations, or new search indexes are involved.

Run with the repository's PostgreSQL and Meilisearch services available:

```sh
mise exec -- bundle exec rspec spec/requests/mcp_{endpoint,catalog,search,docs}_spec.rb
CI=true mise exec -- bundle exec rspec
mise exec -- bundle exec rails zeitwerk:check
mise exec -- bundle exec rubocop
```

The suite enforces 100% coverage across the application, so a focused run alone reports incomplete application coverage. Run the full suite with `CI=true` to use the same eager loading as CI. Search specs exercise real Meilisearch indexing and retrieval; transport and catalog specs exercise MCP JSON-RPC requests through Rails.
