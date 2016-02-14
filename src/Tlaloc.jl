module Tlaloc

export Page,render,addArg,setViewDir,setTemplateDir

global viewDir
global templateDir

keywords = ["extends"] #We'll later add for, endfor, etc...

#Type Page
type Page
  view::ASCIIString # Contains body
  args::Dict # Arguments sent by Julia that need to be added into the body
  #Constructor
  function Page(view::ASCIIString,args::Dict)
    new(view,args)
  end
end

#Tools associated with the Page type
function setViewDir(viewDir::ASCIIString)
  viewDir = viewDir
end

function setTemplateDir(templateDir::ASCIIString)
  templateDir = templateDir
end

# Adds arguments to page
function addArg(page::Page,name::ASCIIString,value::ASCIIString)
  push!(page.args,(name=>value))
end

# This function parses the view by adding the defined variables into the HTML
function parseView(page::Page)
  content = getContent(page)
  response = content
  difference = 0 # We need this because eachMatch collects all the match and then treats them, which means the data concerning indexes starting from the second match needs to be adjusted
  for match in eachmatch(r"\$\{([a-zA-Z0-9_]+)\}",content)
    hasKeyword = false
    if ismatch(r" ",match.match)
      # If there's a space, they probably are keywords, so we'll try to find them
      for keyword in keywords
        if keyword == (match.match)[1:(match(r" ",match.match).offset)]
          hasKeyword = true
          break
        end
      end
    end
    if hasKeyword
      #Then we'll treat it
    elseif isdefined(symbol((match.match)[3:end-1]))
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
function render(page::Page)
  return parseView(page)
end

end
