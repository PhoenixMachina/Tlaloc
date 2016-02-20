module TlalocTemplate

export Tlaloc, Page,render,addArg

keywords = ["extends","for","endfor","addResource"] #Not all implemented yet

#Type Tlaloc
type Tlaloc
  path::ASCIIString # path to view
  #Constructor
  function Tlaloc(path::ASCIIString)
    if path[end] != '/'
      path = "$path/"
    end
    new(path)
  end
end

#Type Page
type Page
  tlaloc::Tlaloc # Instance of Tlaloc
  view::ASCIIString # Contains body
  args::Dict # Arguments sent by Julia that need to be added into the body
  #Constructor
  function Page(tlaloc::Tlaloc, view::ASCIIString, args::Dict)
    new(tlaloc,view,args)
  end
end

# Adds arguments to page
function addArg(page::Page, name::ASCIIString, value::ASCIIString)
  push!(page.args,(name=>value))
end

# This function parses the view by adding the defined variables into the HTML
function parseView(page::Page)
  response = open(readall, page.tlaloc.path * page.view)
  difference = 0 # We need this because eachMatch collects all the match and then treats them, which means the data concerning indexes starting from the second match needs to be adjusted
  for match in eachmatch(r"\$\{([a-zA-Z0-9_ ]+)\}",response)

    for keyword in keywords
      reg_string =  "$(keyword)"
      reg = Regex(reg_string)
      if ismatch(reg,match.match)
        println("Found keyword !")
      end
    end

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
function render(page::Page)
  return parseView(page)
end

end
