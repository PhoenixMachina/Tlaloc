# Tlaloc

[![Build Status](https://travis-ci.org/PhoenixMachina/Tlaloc.svg?branch=master)](https://travis-ci.org/PhoenixMachina/Tlaloc)
[![Licence MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![codecov.io](https://codecov.io/github/PhoenixMachina/Tlaloc/coverage.svg?branch=master)](https://codecov.io/github/PhoenixMachina/Tlaloc?branch=master)

A Julia Template Engine

How to add it to your project :

You first need to clone the repo and its dependecy, like this :
```
Pkg.clone("https://github.com/PhoenixMachina/ConfParser.jl")
Pkg.clone("https://github.com/PhoenixMachina/Tlaloc")
```

In your code, you need to have wherever you want to use it :
```
using TlalocTemplate
```

You need to create a tlaloc object and set the path to your config file :
```
tlaloc = TlalocEngine("path/to/conf.ini")
```

Inside your conf.ini, you need to have :
```
viewPath=pathWithYourViews
TemplatePath=pathWithYourTemplates
ResourcePath=pathWithYourResources
```
By resources, we mean like css, javascript, all that stuff. Doesn't matter if they're in a subfolder.

You now need to create a "Page" object. The constructor has three parameters, a tlaloc object, a string with the name of the view and a dictionnary with variables you want to add in the view.
```
mypage = Page(tlaloc, "login.html", Dict())
```

Note that you'll be able to add arguments later, using
```
addArg(mypage,name,value)
```

Here's a look at what your view file could look like :
```
Hey to you my friend ${username}! What's up?
```
