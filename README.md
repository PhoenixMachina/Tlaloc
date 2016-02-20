# Tlaloc
A Julia Template Engine

How to add it to your project :

You first need to clone the repo, like this :
```
Pkg.clone("https://github.com/PhoenixMachina/Tlaloc")
```

In your code, you need to have wherever you want to use it :
```
using TlalocTemplate
```

You need to create a tlaloc object and set the path to your views folder :
```
tlaloc = Tlaloc("path/to/views")
```

You now need to create a "Page" object. The constructor has three parameters, a tlaloc object, a string with the url of the view and a dictionnary with variables you want to add in the view.
```
mypage = Page(tlaloc, "C:/julia/views/login.html", Dict())
```

Note that you'll be able to add arguments later, using
```
addArg(mypage,name,value)
```

Here's a look at what your view file could look like :
```
${ extends "header.html" }
Hey to you my friend ${username}! What's up?
${ extends "footer.html" }
```
