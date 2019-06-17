# singproxy: Singularity and Proxy tools

This utilities give the possibility to run web application on a high performance computing cluster
in a simple and secure way.




## Quick start

You can create a new datahub, galaxy and filebrowser application with

```
alias genapproxy=/nfs3_ib/ip24/home.local/barrette.share/singproxy-2019-06-13/genapproxy
app_path=~/projects/proj01/mysuperproject  ### Choose real user path here ###
genapproxy create --app=datahub --path=$app_path 
genapproxy create --app=galaxy --path=$app_path 
genapproxy create --app=filebroser --path=$app_path 
```


## How it's works

[Singproxy Schema](/doc/howitsworks.jpg)
Format: ![Alt Text](url)
