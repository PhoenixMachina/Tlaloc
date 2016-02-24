module Tlaloc

using ConfParser

export TlalocEngine, Page,render,addArg

keywords = ["extends","for","endfor","addResource"] #Not all implemented yet

#Type Tlaloc
type TlalocEngine
  viewPath::ASCIIString # path to views
  templatePath::ASCIIString # path to templates
  resourcePath::ASCIIString # path to resources
  #Constructor
  function TlalocEngine(path::ASCIIString="")
    if path != ""
      conf = ConfParse(path)
      parse_conf!(conf)
      viewPath = retrieve(conf, "default", "viewPath")
      templatePath = retrieve(conf, "default", "templatePath")
      resourcePath = retrieve(conf, "default", "resourcePath")

      if((viewPath[end-1:end] != "/") && (viewPath[end-1:end] != "\\"))
        viewPath = string(viewPath,"/")
      end
      if((templatePath[end-1:end] != "/") && (templatePath[end-1:end] != "\\"))
        templatePath = string(templatePath,"/")
      end
      if((resourcePath[end-1:end] != "/") && (resourcePath[end-1:end] != "\\"))
        resourcePath = string(resourcePath,"/")
      end

    end
    new(viewPath, templatePath, resourcePath)
  end
end

#Type Page
type Page
  tlaloc::TlalocEngine # Instance of Tlaloc
  view::ASCIIString # Contains body
  args::Dict # Arguments sent by Julia that need to be added into the body
  #Constructor
  function Page(tlaloc::TlalocEngine, view::ASCIIString, args::Dict)
    new(tlaloc,view,args)
  end
end

# Adds arguments to page
function addArg(page::Page, name::ASCIIString, value::ASCIIString)
  push!(page.args,(name=>value))
end

# This function parses the view by adding the defined variables into the HTML
function parseView(page::Page)
  response = open(readall, page.tlaloc.viewPath * page.view)

  reponse = recursiveKeywordProcessing(response,page)

  return response
end

function recursiveKeywordProcessing(content,page)
  difference = 0 # We need this because eachMatch collects all the match and then treats them, which means the data concerning indexes starting from the second match needs to be adjusted
  for amatch in eachmatch(r"\$\{([a-zA-Z0-9_ .\"]+)\}",content)
    for keyword in keywords
      reg_string =  "$(keyword)"
      reg = Regex(reg_string)
      if ismatch(reg,amatch.match)
        if keyword == "extends"
          if ismatch(Regex("extends \"([a-zA-Z0-9_. ]+)\""),amatch.match)
            statement = match(Regex("\"([a-zA-Z0-9_. ]+)\""),amatch.match)
            tmpContent = open(readall,page.tlaloc.templatePath * (statement.match)[2:end-1])
            content = string(content[1:(amatch.offset)-1 + difference],tmpContent,content[((amatch.offset)+difference+(length(amatch.match))):end] )
            difference = difference + length(content) - length(amatch.match)
          end
        elseif keyword == "for"
          recursiveKeywordProcessing(content[length(match(r"\${for ([a-zA-Z0-9_. ]+) in ([a-zA-Z0-9_. ]+)}").match):match(r"\${forend}".offset)],page)
        end
      end
    end

    if haskey(page.args,(amatch.match)[3:end-1])
      var = (page.args)[(amatch.match)[3:end-1]]
      content = string(content[1:(amatch.offset)-1 + difference],var,content[((amatch.offset)+difference+(length(amatch.match))):end] )
      difference = difference + length(var) - length(amatch.match)
    end
  end
end

# Gets final content
function render(page::Page)
  return parseView(page)
end

end
