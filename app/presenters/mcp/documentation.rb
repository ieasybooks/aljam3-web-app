module Mcp
  class Documentation
    ORIGIN = "https://aljam3.com".freeze
    ENDPOINT = "#{ORIGIN}/mcp".freeze
    CLIENTS = {
      chatgpt: { name: "ChatGPT", source: "https://developers.openai.com/plugins/quickstart" },
      claude: { name: "Claude", source: "https://claude.com/docs/connectors/custom/add-unlisted" }
    }.freeze
  end
end
