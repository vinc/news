require "dotenv"
require "json"
require "openai"
require "rest_client"
require "reverse_markdown"
require "wikicloth"
require "word_wrap"

class WikiParser < WikiCloth::Parser
  link_for do |page, text|
    text || page
  end

  external_link do |url, text|
    text || url
  end
end

def fetch(time)
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
  json["query"]["pages"].values.first
end

def parse(page)
  text = ""
  is_text = false
  page["revisions"].first["*"].each_line do |line|
    is_text = false if line =~ /news \w+ above this line/
    text += line if is_text
    is_text = true if line =~ /news \w+ below this line/
  end
  html = WikiParser.new(data: text).to_html
  ReverseMarkdown.convert(html)
end

def summarize(time, text)
  prompt = ""
  prompt += "Summarize the following daily news in two or three paragraphes. "
  prompt += "Include the date in the first paragraph."
  prompt += "\n\n"
  prompt += time.strftime("# %A, %B %d, %Y")
  prompt += "\n\n"
  prompt += text
  fmt(model(prompt))
end

def model(input)
  openai = OpenAI::Client.new
  begin
    res = openai.chat(parameters: {
      model: ENV.fetch("OPENAI_MODEL"),
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

Dotenv.load(".env", "~/.news.env")
OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_API_KEY")
end

def news(time)
  cache = File.expand_path("~/.news.txt")
  if File.exist?(cache) && (Time.now - File.mtime(cache) < 3600)
    puts File.read(cache)
    exit
  end
  page = fetch(time)
  text = summarize(time, parse(page))
  File.write(cache, text)
  text
end

puts news(Time.now - 24 * 60 * 60)
