require 'mechanize'
require 'json'

class Crawler
  def initialize
    @agent = Mechanize.new
    @page_limit = 2740
    @out_file = File.open('./data.json', 'w')
  end

  def perform
    p '------ 开始抓取任务 ------'
    data = { chapters: get_chapters, questions: get_questions }
    @out_file.puts data.to_json
    @out_file.close
    p '------ 结束抓取任务 ------'
  end

  def get_chapters
    p "开始抓取任务: #{chapter_link}"
    page = @agent.get(chapter_link)
    nums = page.search('//div[@class="titlelist"]//div[@class="num"]/text()').map(&:to_s)
    titles = page.search('//div[@class="titlelist"]//div[@class="title"]/text()').map(&:to_s)
    chapters = {}
    nums.each_with_index do |num,index|
      chapters[num.to_s] = titles[index]
    end
    chapters
  end

  def get_questions
    questions = []
    question_page_links.each do |link|
      p "开始抓取任务: #{link}"
      begin
        page = @agent.get(link)
        questions << JSON.parse(page.content)
        p "任务: #{link} ------ 抓取成功"
      rescue Exception => e
        next
      end
    end
    questions
  end

  private

  def question_page_links
    (1..@page_limit).to_a.map{|id| question_link_with_id(id)}
  end

  def question_link_with_id(id)
    "http://m.jxedt.com/mnksnew/g.asp?id=#{id}"
  end

  def chapter_link
    "http://m.jxedt.com/mnks/ckm1/zjlx/"
  end
end