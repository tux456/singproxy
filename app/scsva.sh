
############################################################################
# R-Shiny
############################################################################

function scsva_create() {
mkdir -p $app_path/.scsva/{lib,log,home} $app_path/ftp
}


GENAP_SCSVA_IMAGE=/home/wueflo00/scSVA/scsva_latest.sif

function scsva_start() {
   SHINY_PORT=$(remote_freeport)

   if [ -e "$GENAP_SCSVA_IMAGE" ];then 
     SHINY_IMAGE=$GENAP_SCSVA_IMAGE
   else
     SHINY_IMAGE=docker://docker/shiny
   fi


   singularity instance start -H $app_path/.scva/home -B $TMP_CONTAINER:/tmp  -B  $app_path/.scsva/lib:/var/lib/shiny-server -B $app_path/.scsva/log:/var/log/shiny-server -B $app_path/ftp:/ftp $SHINY_IMAGE $app_id
   nohup singularity exec instance://$app_id R -e "shiny::runApp('/usr/local/lib/R/site-library/scSVA/scSVA', port=$SHINY_PORT, launch.browser = TRUE)"> $app_path/.scsva/log/scsva.log & 
   export REMOTE_FREE_PORT=$SHINY_PORT
}


function scsva_stop() {
  echo Stopping scsva...
}
