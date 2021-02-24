
############################################################################
# SCAP 
############################################################################

function scap_create() {
#mkdir -p $app_path/.shiny/{lib,log,home} $app_path/ftp
#ln -s /home/shiny/R $app_path/.shiny/home/
echo Create SCAP ...
}


function scap_start() {
   SHINY_PORT=$(remote_freeport)

mkdir -p $TMP_CONTAINER/scap/{lib,log,etc,home}

#ln -s /home/shiny/R $TMP_CONTAINER/scap/home/

#echo '.libPaths("/SCAP/SCAP/renv/library/R-3.6/x86_64-pc-linux-gnu")' > $TMP_CONTAINER/scap/home/.Rprofile



cat >$TMP_CONTAINER/scap/etc/shiny-server.conf <<fin666
# Instruct Shiny Server to run applications as the user "shiny"
run_as $USER;


# Hello
# Define a server that listens on port 3838
server {
  listen $SHINY_PORT;

  # Define a location at the base URL
  location / {

    # Host the directory of Shiny Apps stored in this directory
    site_dir /SCAP/SCAP/R;

    # Log all Shiny output to files in this directory
    #log_dir /home/florian/SCAP_logs;
    log_dir /var/log/shiny-server;

    # When a user visits the base URL rather than a particular application,
    # an index of the applications available in this directory will be shown.
    directory_index on;
  }
}

fin666

   if [ -e "$GENAP_SHINY_IMAGE" ];then 
     SHINY_IMAGE=$GENAP_SHINY_IMAGE
   else
     SHINY_IMAGE=docker://rocker/shiny
   fi

#    singularity instance start -H $app_path/.shiny/home -B $TMP_CONTAINER:/tmp -B $TMP_CONTAINER/shiny-server.conf:/etc/shiny-server/shiny-server.conf -B  $app_path/.shiny/lib:/var/lib/shiny-server -B $app_path/.shiny/log:/var/log/shiny-server -B $app_path/ftp:/ftp -B $GENAP_SHINY_IMAGE/home/florian:/home/florian $SHINY_IMAGE $app_id
#    singularity instance start -H $app_path/.shiny/home -B $TMP_CONTAINER:/tmp -B $TMP_CONTAINER/scap/etc/shiny-server.conf:/etc/shiny-server/shiny-server.conf -B  $TMP_CONTAINER/scap/lib:/var/lib/shiny-server -B $TMP_CONTAINER/scap/log:/var/log/shiny-server -B $app_path/ftp:/ftp -B $GENAP_SHINY_IMAGE/home/florian:/home/florian -B /nfs3_ib/ip24/home.local/genap.share/template-singproxy-test/scap/SCAP/:/SCAP $SHINY_IMAGE $app_id
#    singularity instance start  -H $app_path/.shiny/home -B $GENAP_SHINY_IMAGE/home/florian:/home/florian -B  $GENAP_SHINY_IMAGE/home/shiny:/home/shiny -B  $TMP_CONTAINER/scap/lib:/var/lib/shiny-server -B $TMP_CONTAINER:/tmp -B $TMP_CONTAINER/scap/etc/shiny-server.conf:/etc/shiny-server/shiny-server.conf  -B $TMP_CONTAINER/scap/log:/var/log/shiny-server -B $app_path/ftp:/ftp  -B /nfs3_ib/ip24/home.local/genap.share/template-singproxy-test/scap/SCAP/:/SCAP $SHINY_IMAGE $app_id
 
   cd /; singularity instance start --no-home -H $TMP_CONTAINER/scap/home  -B  $TMP_CONTAINER/scap/lib:/var/lib/shiny-server -B $TMP_CONTAINER:/tmp -B $TMP_CONTAINER/scap/etc/shiny-server.conf:/etc/shiny-server/shiny-server.conf  -B $TMP_CONTAINER/scap/log:/var/log/shiny-server -B $app_path/ftp:/ftp  -B /nfs3_ib/ip24/home.local/genap.share/template-singproxy-test/scap/SCAP/:/SCAP $SHINY_IMAGE $app_id

  singularity exec instance://$app_id bash -c "echo '.libPaths(\"/SCAP/SCAP/renv/library/R-3.6/x86_64-pc-linux-gnu\")' > ~/.Rprofile ; shiny-server" > $app_path/.logs/scap.log &


   export REMOTE_FREE_PORT=$SHINY_PORT
}


function scap_stop() {
  echo Stopping scap...
}
