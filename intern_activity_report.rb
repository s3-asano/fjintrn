# -*- coding: utf-8 -*-
require 'cgi'
require 'date'

def weekago(i)  # ask for how many weeks ago
  case Date.today.wday
  when 0 then
    mday = Date.today - 6
  when 1 then
    mday = Date.today
  when 2 then
    mday = Date.today - 1
  when 3 then
    mday = Date.today - 2
  when 4 then
    mday = Date.today - 3
  when 5 then
    mday = Date.today - 4
  when 6 then
    mday = Date.today - 5
  end
  # The start of a week is Monday
  i_date = Date.parse(i)
  if i_date < mday
    wkag = (mday - i_date).div(7) + 1
  else
    wkag = 0
  end
  return wkag
end

def users_list_parse(page_source)
  # ユーザ一覧ページをparse
  member_link = page_source.scan(%r!<a class="users-item__name-link" href="(.+?)">(.+?)</a>!)
end

def user_page_parse(page_source)
  # ユーザページをparse
  report_day = page_source.scan(%r!pubdate="pubdate">(.{14})!)
  return report_day
end

def format_text(title, url, member_link_ary)

  ope_day = Date.today
  s = "\nLink: #{title}\nURL: #{url}\nOperation_day: #{ope_day}\n
   [weeks ago->],0 week_ago,1 week_ago,2 week_ago,3 week_ago,4 week_ago,5 week_ago,6 week_ago,7 week_ago,8 week_ago,9 week_ago,10 week_ago,11 week_ago,12 week_ago\n"  # タイトル、オペレーション実施日、表タイトルをセット

  member_link_ary.each do |amember_link|  # 各メンバーのID、日報報告情報を１行づつセット
    # 初期化
    s_days = s_week = ""
    dn = []
    wn = {}
    s << "\n* #{amember_link[1]},"
    puts("#{amember_link[1]}\n")  # メンバーIDセット
    report_day_ary = user_page_parse(`/usr/local/bin/wget -w2 -q -O- http://256interns.com#{amember_link[0]}`)  # 各メンバーページをpurseし全ての日報提出日を取得

    report_day_ary.each do |areport_day|  # 日報提出日と提出日がオペレーション実施日から何週間前に該当するかを算出し週間提出回数をセット
      dn.push("#{areport_day[0]}")  # 日報提出日を配列でセット
      a = "#{weekago(areport_day[0])}".to_i  # 日報提出日が何週間前かを取得
#      puts(a)
      # 週間の提出件数を求めるため、何週間前かをキーに１づつ加算
      if wn[a].nil?
        wn[a] = 1
      else
        wn[a] = wn[a] + 1
      end
    end
    # セットしたハッシュを元に週毎の提出件数の出力イメージを生成
    for i in 0..12
      if wn[i].nil?
        s_week << " ,"
      else
        s_week << "#{wn[i]},"
      end
    end
    # セットした配列を元に参考情報である提出日の出力イメージを生成
    dn.each do |d|
      s_days << "#{d},"
    end
    s << s_week  # 週毎提出件数情報をセット
  end
  return s
end

File.open("intern_activity_report.txt", "w") do |f|
  f.puts format_text("作業週メンバー日報状況",
  "http://256interns.com/users?target=working",
  users_list_parse(`/usr/local/bin/wget -q -O- http://256interns.com/users?target=working`))
end

File.open("intern_activity_report.txt", "a") do |f|
  f.puts format_text("学習週メンバー日報状況",
  "http://256interns.com/users?target=learning",
  users_list_parse(`/usr/local/bin/wget -q -O- http://256interns.com/users?target=learning`))
end
