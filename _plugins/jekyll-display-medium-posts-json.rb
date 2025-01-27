require 'uri'
require 'net/http'
require 'json'
require 'nokogiri'
module Jekyll
  class JekyllDisplayMediumPosts < Generator
    safe true
    priority :high
def generate(site)
      jekyll_coll = Jekyll::Collection.new(site, 'medium_posts_json')
      site.collections['medium_posts_json'] = jekyll_coll
      uri = URI("https://api.rss2json.com/v1/api.json?rss_url=https://medium.com/feed/@erap129")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
      data = JSON.parse(response.read_body)
      data['items'].each do |item|
        title = item['title']
        path = "./medium_posts/" + title + ".md"
        path = site.in_source_dir(path)
        doc = Jekyll::Document.new(path, { :site => site, :collection => jekyll_coll })
        puts "====== #{title} ======"
        puts "#{item['link']}"
        doc.data['title'] = title;
        doc.data['image'] = item['thumbnail'];
        doc.data['link'] = item['link'];
        doc.data['date'] = item['pubDate'];
        doc.data['categories'] = item['categories'];
        html_document = Nokogiri::HTML(item['description']);
        doc.data['description'] = html_document.search('p').to_html;
        jekyll_coll.docs << doc
      end
    end
  end
end