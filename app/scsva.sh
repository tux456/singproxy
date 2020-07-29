
############################################################################
# R-Shiny
############################################################################

function scsva_create() {
mkdir -p $app_path/.scsva/{lib,log,home} $app_path/ftp
}


#GENAP_SCSVA_IMAGE=/home/wueflo00/scSVA/scsva_latest.sif
GENAP_SCSVA_ROOTFS=/nfs3_ib/ip24/home.local/barrette.share/template-singproxy/scsva/rootfs

function scsva_start() {
   SHINY_PORT=$(remote_freeport)

#   singularity instance start -H $app_path/.scva/home -B $TMP_CONTAINER:/tmp  -B  $app_path/.scsva/lib:/var/lib/shiny-server -B $app_path/.scsva/log:/var/log/shiny-server -B $app_path/ftp:/ftp $SHINY_IMAGE $app_id
   singularity instance start -H $app_path/.scva/home -B $TMP_CONTAINER:/tmp  -B  $app_path/.scsva/lib:/var/lib/shiny-server -B $app_path/.scsva/log:/var/log/shiny-server -B $app_path/ftp/share:/ftp $GENAP_SCSVA_ROOTFS $app_id
   nohup singularity exec instance://$app_id R -e "shiny::runApp('/usr/local/lib/R/site-library/scSVA/scSVA', port=$SHINY_PORT, launch.browser = TRUE)"> $app_path/.scsva/log/scsva.log & 
   export REMOTE_FREE_PORT=$SHINY_PORT
}


function scsva_stop() {
  echo Stopping scsva...
}
