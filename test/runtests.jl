using Base.Test
using Tlaloc

# Testing constructor
engine = TlalocEngine(string(dirname(Base.source_path()),"/test_conf.ini"))
@test typeof(engine) == TlalocEngine
@test engine.viewPath == "thisIsTheViewPath"
@test engine.templatePath == "thisIsTheTemplatePath"
@test engine.resourcePath == "thisIsTheResource"

#Testing Page constructor
aPage = Page(engine,"apage.html",Dict())
@test typeof(aPage) == Page
@test aPage.view == "apage.html"

#Trying to add args
addArg(aPage,"name","aValue")
@test haskey(aPage.args,"name")
@test (aPage.args)["name"] == "aValue"

#Testing view
aPage.tlaloc.viewPath = string(dirname(Base.source_path()),"/")
aPage.tlaloc.templatePath = string(dirname(Base.source_path()),"/")
@test render(aPage) == "\${extends} \${something} Hello aValue, great to meet you!\n"
