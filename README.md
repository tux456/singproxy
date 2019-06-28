# singproxy: Singularity and Proxy tools

This utilities give the possibility to run web application on a high performance computing cluster
in a simple and secure way.




## Quick start

You can create a new datahub, galaxy and filebrowser application with

```
alias genapproxy=/cvmfs/soft.galaxy/v2/singproxy/genapproxy
app_path=~$HOME/projects/proj01/mysuperproject  ### Choose real user path here ###

genapproxy create --app=galaxy --path=$app_path 
genapproxy create --app=filebrowser --path=$app_path 
```


## How it's works

![](doc/howitsworks.jpg)


##

After you create one application, you can also stop, start, restart and destroy it.  Example:

```
genapproxy stop --app=galaxy --path=$app_path
genapproxy start --app=galaxy --path=$app_path
genapproxy destroy --app=galaxy --path=$app_path
```

To get the status of the currently installed applications:
```
genapproxy status
```


By default, the "galaxy" and "filebrowser" application have a local authentication.

```

```

