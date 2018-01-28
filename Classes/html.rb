#!/usr/bin/ruby

class HtmlElement
  def initialize(inTag, inParent = nil, inContent = nil)
    @tag = inTag
    @attributes = Hash.new
    @content = Array.new
    @indent = 0

    if !inParent.nil?
      inParent.addContent(self)
    end
    
    addContent(inContent)
  end
  
  def addAttribute(inAttribute, inValue)
    @attributes[inAttribute] = inValue;
  end

  def addContent(inContent)
    if inContent.nil?
      return
    end
    
    if inContent.is_a?(HtmlElement) 
      for i in 0..@indent
        inContent.indent()
      end
    end

    @content.push(inContent)
    
  end

  def indent()
    @indent += 1
    @content.each do |content|
      if content.is_a?(HtmlElement) 
        content.indent()
      end
    end
  end

  
  def to_s
    str = ""

    if @indent > 0
        str += "\n"
    end

    for i in 1..@indent
        str += "  "
    end
    
    str += "<" + @tag

    @attributes.each do |key, value|
        str += " " + key + "=\"" + value.to_s + "\"" 
    end

    str += ">"

    lastContentIsElement = false
    
    @content.each do |content|
      str += content.to_s
      lastContentIsElement = content.is_a?(HtmlElement) 
    end


    if @content.length > 0
      if lastContentIsElement
        str += "\n"
        
        for i in 1..@indent
          str += "  "
        end
      end
      
      str += "</" + @tag + ">"
    end
    
    str
  end

  def length
    to_s.length
  end

end
