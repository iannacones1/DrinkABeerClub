#!/usr/bin/ruby

require '/home/pi/git/DrinkABeerClub/Classes/html.rb'

html = HtmlElement.new("html")

    head = HtmlElement.new("head")

        noRobots = HtmlElement.new("meta")
        noRobots.addAttribute("name", "robots")
        noRobots.addAttribute("content", "noindex, nofollow")
        head.addContent(noRobots)

        charset = HtmlElement.new("meta")
        charset.addAttribute("charset", "UTF-8")
        head.addContent(charset)

        style = HtmlElement.new("style")
        style.addContent("table { border-collapse: collapse; padding: 5px; } ")
        style.addContent("th,td { text-align: center; border: 1px dotted black; padding: 5px; }")
        head.addContent(style)

    html.addContent(head)

    body = HtmlElement.new("body")

        table = HtmlElement.new("table")

        caption = HtmlElement.new("caption")
        time = Time.now.strftime "%b %d %l:%M %p"
        caption.addContent("Last Updated: #{time}")
        table.addContent(caption)
        
        test = HtmlElement.new("tr", "My name is steve")
        test.addAttribute("height", 100)
        table.addContent(test)

        body.addContent(table)
        
                
    html.addContent(body)

puts "#{html}"
