
############################################################################
# Datahub
############################################################################

function datahub_create {
cat >$app_confdir/nginx.conf <<fin666
server {
    listen unix:/etc/nginx/conf.d/app.sock;
    client_max_body_size 20g;
    types_hash_max_size 2048;
    server_name _;
   location / {
        root    /data/;
        autoindex on;
    }
}
fin666
}


function datahub_start() {

   if [ -f "$GENAP_DATAHUB_IMAGE" ];then
     DATAHUB_IMAGE=$GENAP_DATAHUB_IMAGE
   else
     DATAHUB_IMAGE=docker://nginx
   fi
   mkdir -p $app_confdir/{var/log/nginx,var/run,var/cache/nginx}
   #singularity instance start -B $app_confdir/:/etc/nginx/conf.d -B $app_confdir/var:/var/log/nginx -B $app_confdir/run:/var/run -B $app_confdir/cache:/var/cache/nginx/ -B $app_path:/data $DATAHUB_IMAGE $app_id
   singularity instance start -B $app_confdir/:/etc/nginx/conf.d -B $app_confdir/var:/var/ -B $app_path:/data $DATAHUB_IMAGE $app_id
   singularity exec instance://$app_id rm -f /etc/nginx/conf.d/app.sock
   singularity exec instance://$app_id service nginx start
}

