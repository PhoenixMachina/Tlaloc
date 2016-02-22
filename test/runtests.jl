using Base.Test
using Tlaloc

# Testing constructor
engine = TlalocEngine(string(dirname(Base.source_path()),"/test_conf.ini"))
@test typeof(engine) == TlalocEngine
@test engine.viewPath == "thisIsTheViewPath"
@test engine.TemplatePath == "thisIsTheTemplatePath"
@test engine.ResourcePath == "thisIsTheResource"

#Testing Page constructor
aPage = Page(engine,"apage.html",Dict())
@test typeof(aPage) == Page
@test aPage.view == "apage.html"

#Trying to add args
addArg(aPage,"anArgument","aValue")
@test haskey(aPage,"anArgument")
@test (aPage.args)["anArgument"] == "aValue"
