
############################################################################
# SCAP 
############################################################################

function scap_create() {
echo Create SCAP ...
}


function scap_start() {

   SHINY_PORT=$(remote_freeport)

mkdir -p $TMP_CONTAINER/scap/{lib,log,etc,home}



   if [ -e "$GENAP_SHINY_IMAGE" ];then 
     SHINY_IMAGE=$GENAP_SHINY_IMAGE
   else
     SHINY_IMAGE=docker://rocker/shiny
   fi
   SHINY_IMAGE=/net/ip24/home.local/genap.share/template-singproxy-test/scap
   SHINY_IMAGE=/net/ip24/home.local/genap.share/template-singproxy-test/scap/scap.simg



export REMOTE_FREE_PORT=$SHINY_PORT
(echo  "cd /SCAP;R -e "'"'" shiny::runApp('"'/SCAP/R'"', host = '"'0.0.0.0'"', port = $SHINY_PORT ) "'"'" "  |singularity run  --containall  -B $TMP_CONTAINER/:/tmp -B $TMP_CONTAINER/scap/log:/var/log/shiny-server -B $app_path/ftp:/ftp $SHINY_IMAGE bash;killall -9 sleep ssh) &

#overlay=$TMP_CONTAINER/scap/overlay.img
#dd if=/dev/zero of=$overlay bs=1M count=500 &&  mkfs.ext3 -F $overlay
#singularity instance start --containall -B $TMP_CONTAINER/:/tmp -B $TMP_CONTAINER/scap/log:/var/log/shiny-server -B $app_path/ftp:/ftp $SHINY_IMAGE  $app_id
#(echo  "cd /SCAP;R -e "'"'" shiny::runApp('"'/SCAP/R'"', host = '"'0.0.0.0'"', port = $SHINY_PORT ) "'"'" "  |singularity exec instance://$app_id nohup bash;killall -9 sleep) &

#while [ 1 ];do if ! pidof R;then killall -9 sleep;fi;sleep 5;done&

}


function scap_stop() {
  echo Stopping scap...
}
