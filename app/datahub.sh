
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
   singularity instance start -B $app_confdir/:/etc/nginx/conf.d -B $app_confdir/:/var/log/nginx -B $app_confdir:/var/run -B $app_confdir/:/var/cache/nginx/ -B $app_path:/data docker://nginx $app_id
   singularity exec instance://$app_id service nginx start
}

