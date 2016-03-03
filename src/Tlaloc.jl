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
  response = recursiveKeywordProcessing(response,page)
  return response
end

function recursiveKeywordProcessing(content,page)

  while ismatch(r"\$\{([a-zA-Z0-9_ .\"]+)\}",content) # Searching for every match ${something} in the content
    amatch = match(r"\$\{([a-zA-Z0-9_ .\"]+)\}",content) #Giving it a value

    hasKeyword = false # No keywords are here at first, we'll need that later on to check if there's neither a keyword nor a variable, which means nothing good, in the match

    for keyword in keywords #Looping through the keywords to check if they are present in the match

      # Creating a regex search for that keyword
      reg_string =  "$(keyword)"
      reg = Regex(reg_string)

      if ismatch(reg,amatch.match) # Checking if there's a keyword

        if keyword == "extends" && ismatch(Regex("extends \"([a-zA-Z0-9_. ]+)\""),amatch.match) # Checking if there's an extends keyword with the appropriate form
          hasKeyword = true
          statement = match(Regex("\"([a-zA-Z0-9_. ]+)\""),amatch.match)

          # Checking the file exists
          if !isfile(page.tlaloc.templatePath * (statement.match)[2:end-1])
            error("The file you are trying to add does not exist")
          end

          # Fetching the template and adding it to the content
          tmpContent = open(readall,page.tlaloc.templatePath * (statement.match)[2:end-1])
          content = string(content[1:(amatch.offset)-1],tmpContent,content[((amatch.offset)+(length(amatch.match))):end] )
        end

      elseif keyword == "for" && ismatch(r"\${for ([a-zA-Z0-9_. ]+) in ([a-zA-Z0-9_. ]+)}",content) && ismatch(r"\${forend}",content) # If it's a for loop with the appropriate form
        hasKeyword = true

        beginning = match(r"\${for ([a-zA-Z0-9_. ]+) in ([a-zA-Z0-9_. ]+)}",content)
        beginIndex = beginning.offset+length(beginning.match)
        ending = match(r"\${forend}",content)
        endIndex = ending.offset - 1

        content = string(content[1:beginning.offset],recursiveKeywordProcessing(content[beginIndex:endIndex],page),content[endIndex+2:end])
      end

    end

    if haskey(page.args,(amatch.match)[3:end-1]) #If it's a argument passed down by the controller, add it
      var = (page.args)[(amatch.match)[3:end-1]]
      content = string(content[1:(amatch.offset)-1 ],var,content[((amatch.offset)+(length(amatch.match))):end] )
    elseif !hasKeyword
      content = string(content[1:(amatch.offset)-1 ],"",content[((amatch.offset)+(length(amatch.match))):end] )
    end


  end # Ends While

  return content

end # Ends function

# Gets final content
function render(page::Page)
  return parseView(page)
end

end
