module Tlaloc

export Page, display,addArg,setViewDir,setTemplateDir

#Type Page
type Page
  template::ASCIIString # Template used for page (contains header & footer)
  view::ASCIIString # Contains body
  args::Dict # Arguments sent by Julia that need to be added into the body

  #Constructor
  function Page(template::ASCIIString,view::ASCIIString,args::Dict)
    new(view,args)
  end

end

#Tools associated with the Page type
function setViewDir(viewDir::ASCIIString)
  global viewDir = viewDir
end

function setTemplateDir(templateDir::ASCIIString)
  global templateDir = templateDir
end

# Adds arguments to page
function addArg(page::Page,name::ASCIIString,value::ASCIIString)
  push!(page.args,(name=>value))
end

# This function parses the view by adding the defined variables into the HTML
function parseView(page::Page)
  content = getContent(page)
  response = content
  difference = 0 # We need this because eachMatch collects all the match and then treats them, which means the data concerning indexes starting from the second match needs to be adjsted
  for match in eachmatch(r"\$\{([a-zA-Z0-9_]+)\}",content)
    if isdefined(symbol((match.match)[3:end-1]))
      var = @eval ($(symbol((match.match)[3:end-1])))
      response = string(response[1:(match.offset)-1 + difference],var,response[((match.offset)+difference+(length(match.match))):end] )
      difference = difference + length(var) - length(match.match)
    elseif haskey(page.args,(match.match)[3:end-1])
      var = (page.args)[(match.match)[3:end-1]]
      response = string(response[1:(match.offset)-1 + difference],var,response[((match.offset)+difference+(length(match.match))):end] )
      difference = difference + length(var) - length(match.match)
    end
  end

  return response
end


# Gets final content
function display(page::Page)
  return parseView(page)
end

end
