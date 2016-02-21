using Base.Test
using Tlaloc

#=

# Testing constructor
engine = TlalocEngine(string(dirname(Base.source_path()),"\\test_conf.ini"))
@test typeof(engine) == TlalocEngine
@test engine.viewPath == "thisIsTheViewPath"
@test engine.TemplatePath == "thisIsTheTemplatePath"
@test engine.ResourcePath == "thisIsTheResource"

=#

@test 1==1
