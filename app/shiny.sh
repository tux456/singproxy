
############################################################################
# R-Shiny
############################################################################

function shiny_create() {
mkdir -p $app_path/.shiny/{lib,log,home} $app_path/ftp
ln -s /home/shiny/R $app_path/.shiny/home/
echo TABAR


cat >$app_path/.shiny/shiny-server.conf <<fin666
# Instruct Shiny Server to run applications as the user "shiny"
run_as $USER;


# Hello
# Define a server that listens on port 3838
server {
  listen 3838;

  # Define a location at the base URL
  location / {

    # Host the directory of Shiny Apps stored in this directory
    site_dir /home/florian/SCAP/R;

    # Log all Shiny output to files in this directory
    #log_dir /home/florian/SCAP_logs;
    log_dir /var/log/shiny-server;

    # When a user visits the base URL rather than a particular application,
    # an index of the applications available in this directory will be shown.
    directory_index on;
  }
}

fin666
}


function shiny_start() {
   SHINY_PORT=$(remote_freeport)
   sed "s/listen .*/listen $SHINY_PORT;/" -i $app_path/.shiny/shiny-server.conf
#   sed "s|/srv/shiny-server|/srv/shiny-server/sample-apps/scCluster_genap2|g" -i /etc/shiny-server//shiny-server.conf

   if [ -e "$GENAP_SHINY_IMAGE" ];then 
     SHINY_IMAGE=$GENAP_SHINY_IMAGE
   else
     SHINY_IMAGE=docker://rocker/shiny
   fi


#   mkdir -p $app_path/.shiny/site-library

#   singularity instance start -B $app_confdir/shiny-server.conf:/etc/shiny-server/shiny-server.conf -B $app_path/.shiny/log:/var/log/shiny-server -B $app_path/.shiny/lib:/srv/shiny-server/florian -B $app_path/.shiny/site-library:/usr/local/lib/R/site-library -B $app_path/ftp:/ftp $SHINY_IMAGE $app_id
   singularity instance start -H $app_path/.shiny/home -B $TMP_CONTAINER:/tmp -B $app_path/.shiny/shiny-server.conf:/etc/shiny-server/shiny-server.conf -B  $app_path/.shiny/lib:/var/lib/shiny-server -B $app_path/.shiny/log:/var/log/shiny-server -B $app_path/ftp:/ftp -B /nfs3_ib/ip24/home.local/barrette.share/template-singproxy/shiny/rootfs.florian/home/florian:/home/florian $SHINY_IMAGE $app_id
#   singularity exec instance://$app_id bash -c 'sed "s|/srv/shiny-server|/srv/shiny-server/sample-apps/scCluster_genap2|g" -i /etc/shiny-server/shiny-server.conf'
   singularity exec instance://$app_id bash -c "nohup shiny-server >/var/log/shiny-server/nohup.out &"
#   singularity exec instance://$app_id bash -c "cat /etc/shiny-server//shiny-server.conf"

   export REMOTE_FREE_PORT=$SHINY_PORT
}


function shiny_stop() {
  echo Stopping shiny...
}
