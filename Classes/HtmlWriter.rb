#!/usr/bin/ruby

class HtmlWriter
    def initialize(inFileName)
        @indent = 0
        @output = open(inFileName, "w")
        openTag("html")
        openTag("head")
        writeLine("<meta name=\"robots\" content=\"noindex, nofollow\">")
        openTag("style")
        write("    table\n")
        write("    {\n")
        write("        border-collapse: collapse;\n")
        write("    }\n\n")
        write("    th,td\n")
        write("    {\n")
        write("        text-align: center;\n")
        write("        border: 1px dotted black;\n")
        write("        padding: 5px;\n")
        write("    }\n")
        closeTag("style")
        closeTag("head")
    end

    def write(inLine)
        @output.write(inLine)
    end
    
    def writeLine(inLine)
        indent()
        write(inLine)
        write("\n")
    end

    def openTag(inTag)
        indent()
        write("<#{inTag}>\n")
        @indent += 1
    end

    def closeTag(inTag)
        @indent -= 1
        indent()
        write("</#{inTag}>\n")
    end

    def close
        closeTag("html")        
        @output.close
    end

    def startRow
        openTag("tr")
    end

    def endRow
        closeTag("tr")
    end

    def writeTableData(inData)
        startLine("td")
        write(inData)
        endLine("td")
    end

    def writeTableHeader(inHeader)
        startLine("th")
        write(inHeader)
        endLine("th")
    end

    def startLine(inTag)
        indent()
        write("<#{inTag}>")
    end        

    def endLine(inTag)
      write("</#{inTag}>\n")
    end

    def addLink(inAddr, inText)
      write(getLink(inAddr, inText))
    end


    def getLink(inAddr, inText)
       result = "<a href=\"#{inAddr}\">#{inText}</a>"
    end

    def indent()
        i = 0
        while i < @indent            
            @output.write("  ")
            i += 1
        end
    end

end
