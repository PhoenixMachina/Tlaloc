module Tlaloc

using ConfParser

export TlalocEngine, Page,render,addArg

keywords = ["extends","for","endfor","addResource"] #Not all implemented yet

#Type Tlaloc
type TlalocEngine
  viewPath::ASCIIString # path to views
  TemplatePath::ASCIIString # path to templates
  ResourcePath::ASCIIString # path to resources
  #Constructor
  function TlalocEngine(path::ASCIIString="")
    if path != ""
      conf = ConfParse(path)
      parse_conf!(conf)
      viewPath = retrieve(conf, "default", "viewPath")
      TemplatePath = retrieve(conf, "default", "TemplatePath")
      ResourcePath = retrieve(conf, "default", "ResourcePath")
    end
    new(viewPath, TemplatePath, ResourcePath)
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
  difference = 0 # We need this because eachMatch collects all the match and then treats them, which means the data concerning indexes starting from the second match needs to be adjusted
  for match in eachmatch(r"\$\{([a-zA-Z0-9_ ]+)\}",response)

    for keyword in keywords
      reg_string =  "$(keyword)"
      reg = Regex(reg_string)
      if ismatch(reg,match.match)
        if keyword == "extends"
          # Soon
        end
      end
    end

    if haskey(page.args,(match.match)[3:end-1])
      var = (page.args)[(match.match)[3:end-1]]
      response = string(response[1:(match.offset)-1 + difference],var,response[((match.offset)+difference+(length(match.match))):end] )
      difference = difference + length(var) - length(match.match)
    end
  end

  return response
end


# Gets final content
function render(page::Page)
  return parseView(page)
end

end
