require "dotenv"
require "json"
require "openai"
require "rest_client"
require "reverse_markdown"
require "wikicloth"
require "word_wrap"

cache = File.expand_path("~/.news.txt")

if File.exist?(cache) && (Time.now - File.mtime(cache) < 3600)
  puts File.read(cache)
  exit
end

Dotenv.load(".env", "~/.news.env")
OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_API_KEY")
end

class WikiParser < WikiCloth::Parser
  link_for do |page, text|
    text || page
  end

  external_link do |url, text|
    text || url
  end
end

def chat(openai, input)
  begin
    res = openai.chat(parameters: {
      model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini"),
      messages: [{ role: "user", content: input }],
      temperature: 0.7
    })
  rescue Net::ReadTimeout, Errno::ECONNRESET
    retry
  end
  if (err = res.dig("error", "message"))
    puts err
    exit 1
  end
  res.dig("choices", 0, "message", "content").strip
end

def fmt(text)
  WordWrap.ww(text, 72)
end

# Fetch yesterday's news
time = Time.now - 24 * 60 * 60
res = RestClient.get(
  "https://en.wikipedia.org/w/api.php",
  params: {
    prop: "info|revisions",
    rvprop: "timestamp|content",
    format: "json",
    action: "query",
    inprop: "url",
    titles: "Portal:Current_events/" + time.strftime("%Y_%B_%-d")
  }
)

json = JSON.parse(res.body)

text = ""
is_text = false
page = json["query"]["pages"].values.first
page["revisions"].first["*"].each_line do |line|
  is_text = false if line =~ /news \w+ above this line/
  text += line if is_text
  is_text = true if line =~ /news \w+ below this line/
end

html = WikiParser.new(data: text).to_html
markdown = ReverseMarkdown.convert(html)

prompt = ""
prompt += "Summarize the following daily news in two or three paragraphes. "
prompt += "Include the date in the first paragraph."
prompt += "\n\n"
prompt += time.strftime("# %A, %B %d, %Y")
prompt += "\n\n"
prompt += markdown

text = fmt(chat(OpenAI::Client.new, prompt))

puts text
File.write(cache, text)
