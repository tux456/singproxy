# Make the singluarity image
```
singularity build galadock.simg docker://bgruening/galaxy-stable
```

# Make the export directory
```
mkdir export
docker run -v $PWD/export/:/export/ bgruening/galaxy-stable
```

# Generate export.tar tool_deps.tar etc.tar
```
mv export/tool_deps ..
tar cf export.tar export    # ftp galaxy-central postgresql shed_tools var
tar cf tool_deps.tar tool_deps  # tar x   /home.local/barrette.share/template-galaxy-docker-mike/
docker exec -i 4506eaaaf0da bash -c 'cd /;tar c /export ' >export.tar
docker exec -i 4506eaaaf0da bash -c 'cd /;tar c /etc ' >etc.tar
docker run -i bgruening/galaxy-stable bash -c 'cd /;tar c /etc' >etc.tar
scp *.tar myserver:/home.local/barrette.share/template-galaxy-docker-mike/
```



# Add the .conf
```
GENAP_GALAXY_SOURCE=/home.local/barrette.share/template-galaxy-docker-mike
GENAP_GALAXY_IMAGE=$GENAP_GALAXY_SOURCE/galadock.simg
```
