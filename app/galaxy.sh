############################################################################
# Galaxy
############################################################################

function galaxy_useradd() {
  find_id
  galaxy_api=$(echo -e $(grep master_api_key $app_path/.galaxy/etc/galaxy/galaxy.yml |cut -d\: -f 2))
  curl -s --unix-socket $TMP_GALAXY/export/var/run/nginx.sock -X POST -d "username=$m_user&email=$m_user@g.ca&password=$m_password" "http://localhost/api/users?key=$galaxy_api"
}

function galaxy_pingapi() {
  galaxy_api=$(echo -e $(grep master_api_key $app_path/.galaxy/etc/galaxy/galaxy.yml |cut -d\: -f 2))
  while [ 1 ];do
    curl -s --unix-socket $TMP_GALAXY/export/var/run/nginx.sock "http://localhost/api/users?key=$galaxy_api" |grep model_class >/dev/null && break
    sleep 10
    echo Trying again ...
  done
}

function galaxy_userupdate() {
  echo "Please update as admin in galaxy interface"
  #find_id
  #galaxy_api=$(echo -e $(grep master_api_key $app_path/.galaxy/etc/galaxy/galaxy.yml |cut -d\: -f 2))
  #curl -s --unix-socket $TMP_GALAXY/export/var/run/nginx.sock -X GET -d "email=$m_user@g.ca" "http://localhost/api/users/?key=$galaxy_api"
  #curl -s --unix-socket $TMP_GALAXY/export/var/run/nginx.sock -X PUT -d "username=$m_user&email=$m_user@g.ca&password=$m_password" "http://localhost/api/users/ba03619785539f8c?key=$galaxy_api"
}


function galaxy_create {
  mkdir -p $app_path/.galaxy   # will put export here
##############################
# etc dans app_path/galaxy/  
##############################
#  tar zxf $galaxy_source/etc.tar.gz -C $app_path/.galaxy/
  tar xf $GENAP_GALAXY_SOURCE/etc.tar -C $app_path/.galaxy/
  cd $app_path/.galaxy/
  mkdir -p etc ../ftp database/postgresql-backup/  # postgresql-backup database galaxy-central/database

  # etc/nginx/nginx.conf
  sed -i 's|listen 80;|listen unix:/var/run/nginx.sock;|g'  etc/nginx/nginx.conf
  sed -i '/^http {.*/a\    underscores_in_headers on;' etc/nginx/nginx.conf
  sed -i 's/\$remote_user/$http_remote_user/g' etc/nginx/conf.d/uwsgi.conf
  sed -i 's|uwsgi_pass 127.0.0.1:4001;|uwsgi_pass unix:///var/run/uwsgi.sock;|g' etc/nginx/conf.d/uwsgi.conf

  # DNS
  echo "nameserver 8.8.8.8" >etc/resolv.conf

  # postgresql
  sed -i 's|port = 5432|#port = 5432|g'  etc/postgresql/9.3/main/postgresql.conf
  sed -i "s|data_directory = \(.*\)|data_directory = '/export/postgresql/9.3/main/'|" etc/postgresql/9.3/main/postgresql.conf
  sed -i 's/peer/trust/g' etc/postgresql/9.3/main/pg_hba.conf
  sed -i 's/^user /\#user/g' etc/supervisor/conf.d/galaxy.conf
  sed -i 's|.*/bin/postmaster.*|& -c "listen_addresses="|' etc/supervisor/conf.d/galaxy.conf
  sed -i 's|/home/galaxy/logs|/var/log/galaxy|g' etc/supervisor/conf.d/galaxy.conf
  sed -i 's/^autostart\(.*\)/autostart       = false/g' etc/supervisor/conf.d/galaxy.conf
  sed -i 's/^\[inet_http_server\]/\#[inet_http_server]/g' etc/supervisor/conf.d/galaxy.conf

  # galaxy supervriso
  sed -i 's/^port=0.0.0.0:9002/\#port=0.0.0.0:9002/g' etc/supervisor/conf.d/galaxy.conf
  sed -i 's/--socket 127.0.0.1:4001//g' etc/supervisor/conf.d/galaxy.conf
  sed -i 's/--stats 127.0.0.1:9191//g' etc/supervisor/conf.d/galaxy.conf
  sed -i 's/^programs = galaxy_web, handler, galaxy_nodejs_proxy/programs = galaxy_web, handler/g' etc/supervisor/conf.d/galaxy.conf

  # galaxy conf system ENV
  for i in $(set |grep ^GALAXY_CONFIG_ |cut -d\= -f1);do
  galaxyconf_var=$(echo $i|sed 's/^GALAXY_CONFIG_\(.*\)/\1/' | tr '[:upper:]' '[:lower:]')
  galaxyconf_val=${!i}
    sed "s|^  \#$galaxyconf_var\(.*\)|  $galaxyconf_var\: $galaxyconf_val|" -i etc/galaxy/galaxy.yml 
  done

  #galaxy conf manual
  sed -i "s|  #job_config_file:\(.*\)|  job_config_file:  /export/galaxy-central/config/job_config_docker.xml|g" etc/galaxy/galaxy.yml
#  sed -i "s|  #job_resource_params_file:\(.*\)|  job_resource_params_file:  /export/galaxy-central/config/job_resource_params_conf_docker.xml|g" etc/galaxy/galaxy.yml
  sed -i 's|  http: 127.0.0.1:8080|  socket: /var/run/uwsgi.sock|g' etc/galaxy/galaxy.yml
  sed -i "s|  #master_api_key:\(.*\)|  master_api_key: `genpass 20`|g" etc/galaxy/galaxy.yml
  sed -i 's|  #ftp_upload_dir:\(.*\)|  ftp_upload_dir: /ftp|g' etc/galaxy/galaxy.yml
  sed -i 's|  #ftp_upload_dir_identifier:\(.*\)|  ftp_upload_dir_identifier: username|g' etc/galaxy/galaxy.yml
  sed -i "s|  #admin_users:\(.*\)|  admin_users: $USER@g.ca|g" etc/galaxy/galaxy.yml
  if [ -n "$GENAP_GALAXY_REMOTE_USER" ];then
    sed -i "s|  #require_login:\(.*\)|  require_login: false|g" etc/galaxy/galaxy.yml
    sed -i "s|  #allow_user_creation:\(.*\)|  allow_user_creation: true|g" etc/galaxy/galaxy.yml
    sed -i "s|  #use_remote_user:\(.*\)|  use_remote_user: true|g" etc/galaxy/galaxy.yml
    sed -i "s|  #remote_user_maildomain:\(.*\)|  remote_user_maildomain: g.ca|g" etc/galaxy/galaxy.yml
  else
    sed -i "s|  #require_login:\(.*\)|  require_login: true|g" etc/galaxy/galaxy.yml
    sed -i "s|  #allow_user_creation:\(.*\)|  allow_user_creation: false|g" etc/galaxy/galaxy.yml
  fi
  sed -i "s|  #brand:\(.*\)|  brand: $CC_CLUSTER/$USER/$app_id|g" etc/galaxy/galaxy.yml
  sed -i 's|  #database_connection:\(.*\)|  database_connection: 'postgresql:///galaxy?user=galaxy\&host=/var/run/postgresql'|g' etc/galaxy/galaxy.yml
 
}

function galaxy_start() {
##############################
# export dans $TMP_GALAXY 
##############################
  rm -rf $TMP_GALAXY/export
  if [ ! -d $TMP_GALAXY/export ];then 
    mkdir -p $TMP_GALAXY/export;chmod 700 $TMP_GALAXY
#    galaxy_source=/cvmfs/soft.galaxy/v2/singularity/docker19.01
#    tar zxf $galaxy_source/export_small.tar.gz -C $TMP_GALAXY
    tar xf $GENAP_GALAXY_SOURCE/export2.tar -C $TMP_GALAXY
    cd $TMP_GALAXY/export
    mkdir -p var/run/postgresql var/sock var/log/supervisor var/log/nginx var/log/galaxy var/lib/nginx #var/lib/munge var/run/munge
  fi

  #### TEMPORARY PATCH FOR DAVID ##############
  mkdir -p $app_path/.galaxy/rules
  rsync -a $GALAXY_RESUB_SOURCE/rules/ $app_path/.galaxy/rules
  cp -a $GALAXY_RESUB_SOURCE/*.xml $TMP_GALAXY/export/galaxy-central/config/
#  touch  $app_path/.galaxy/etc/resub
  #############################################
 

  cd $app_path/.galaxy
#  singularity -q instance start -B /home -B $TMP_GALAXY/export:/export -B /nfs3_ib:/nfs3_ib -B /nfs3_ib/ip24-ib/home.local/barrette.share/template-galaxy-21-jonathan/DEFAULT_JOB_FILE_TEMPLATE.sh:/galaxy-central/lib/galaxy/jobs/runners/util/job_script/DEFAULT_JOB_FILE_TEMPLATE.sh -B /nfs3_ib/ip24-ib/home.local/barrette.share/template-galaxy-21-jonathan/DEFAULT_JOB_FILE_TEMPLATE.sh:/export/galaxy-central/lib/galaxy/jobs/runners/util/job_script/DEFAULT_JOB_FILE_TEMPLATE.sh -B $TMP_GALAXY/export/var/log:/var/log  -B $TMP_GALAXY/export/var/lib/nginx/:/var/lib/nginx/ -B $app_path/.galaxy/etc:/etc -B $GENAP_CVMFS_SOFT_GALAXY_SOURCE:/cvmfs/soft.galaxy:ro  -B $TMP_GALAXY/export/var/run/:/run  -B $app_path/.galaxy/rules:/galaxy-central/lib/galaxy/jobs/rules -B $app_path/.galaxy/database/:/export/galaxy-central/database/ -B $app_path/ftp:/ftp -B $app_path/.galaxy/database/:/galaxy-central/database/ -B /bin/true:/usr/bin/scontrol /cvmfs/soft.galaxy/v2/singularity/docker19.01/galadock.img $app_id
#singularity -q instance start -B /home -B $TMP_GALAXY/export:/export -B /nfs3_ib:/nfs3_ib -B /nfs3_ib/ip24-ib/home.local/barrette.share/template-galaxy-21-jonathan/DEFAULT_JOB_FILE_TEMPLATE.sh:/galaxy-central/lib/galaxy/jobs/runners/util/job_script/DEFAULT_JOB_FILE_TEMPLATE.sh -B /nfs3_ib/ip24-ib/home.local/barrette.share/template-galaxy-21-jonathan/DEFAULT_JOB_FILE_TEMPLATE.sh:/export/galaxy-central/lib/galaxy/jobs/runners/util/job_script/DEFAULT_JOB_FILE_TEMPLATE.sh -B $TMP_GALAXY/export/var/log:/var/log  -B $TMP_GALAXY/export/var/lib/nginx/:/var/lib/nginx/ -B $app_path/.galaxy/etc:/etc -B $GENAP_CVMFS_SOFT_GALAXY_SOURCE:/cvmfs/soft.galaxy:ro  -B $TMP_GALAXY/export/var/run/:/run  -B $app_path/.galaxy/rules:/galaxy-central/lib/galaxy/jobs/rules -B $app_path/.galaxy/database/:/export/galaxy-central/database/ -B $app_path/ftp:/ftp -B $app_path/.galaxy/database/:/galaxy-central/database/ -B /bin/true:/usr/bin/scontrol $GENAP_GALAXY_SOURCE/galadock.simg $app_id

singularity -q instance start -B $HOME_CONTAINER:/home -B $TMP_CONTAINER:/tmp  -B $TMP_GALAXY/export:/export -B $TMP_GALAXY/export/var/log:/var/log  -B $TMP_GALAXY/export/var/lib/nginx/:/var/lib/nginx/ -B $app_path/.galaxy/etc:/etc -B $GENAP_CVMFS_SOFT_GALAXY_SOURCE:/cvmfs/soft.galaxy:ro  $GENAP_GALAXY_EXTRA_MOUNT -B $TMP_GALAXY/export/var/run/:/run  -B $app_path/.galaxy/rules:/galaxy-central/lib/galaxy/jobs/rules -B $app_path/.galaxy/database/:/export/galaxy-central/database/ -B $app_path/ftp:/ftp -B $app_path/.galaxy/database/:/galaxy-central/database/ $GENAP_GALAXY_SOURCE/galadock.simg $app_id
sleep 5

  sg="singularity exec instance://$app_id"
  $sg /usr/bin/python /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
  if [ -f export/var/run/nginx.sock ];then rm export/var/run/nginx.sock;fi
  $sg supervisorctl start nginx
  pgsql_tar="$(ls -St -d $app_path/.galaxy/database/postgresql-backup/pgsql-*.tar.gz 2>/dev/null |head -1)"
  if [ -f "$pgsql_tar" ];then
    rm -rf $TMP_GALAXY/export/postgresql/9.3/main
    tar zxf  $pgsql_tar -C $TMP_GALAXY/
    echo "restore $pgsql_tar ..."
    #singularity exec instance://$app_id bash -c "psql -U galaxy -q -h /var/run/postgresql/ -f /galaxy-central/database/postgresql-backup/pgsql-dump.last >/dev/null"
  fi
  $sg supervisorctl start postgresql
  sleep 5
  $sg nohup bash -c 'while [ 1 ];do mv /galaxy-central/database/postgresql-backup/pgsql-while.tar.gz /galaxy-central/database/postgresql-backup/pgsql-while2.tar.gz;tar zcf /galaxy-central/database/postgresql-backup/pgsql-while.tar.gz /export/postgresql/9.3/main;sleep 600;done >/var/log/galaxy/pg_bak.log' 2>&1 &
  $sg supervisorctl start galaxy:
  ln -sf $TMP_GALAXY/export/var/run/nginx.sock $app_confdir/app.sock
  run_background bash $(dirname $0)/resub/resub.sh $app_path

  echo "Wait for Galaxy API (may take a while)..."
  galaxy_pingapi;sleep 5

 # add admin user 
 if [ ! -f $app_path/.galaxy/admin.txt ];then
    echo "Add admin user..."
    m_user=$USER
    if [ -z "$m_password" ];then
      m_password=$(genpass) # 8
    fi
    galaxy_useradd >/dev/null
    echo "Galaxy admin user added: $m_user  pass: $m_password"
    touch $app_path/.galaxy/admin.txt
 fi

}

function galaxy_stop() {
  sg="$ssh_starter $(which singularity) exec instance://$app_id"
  $sg supervisorctl stop galaxy:
  $sg supervisorctl stop postgresql
  $sg tar zcf /galaxy-central/database/postgresql-backup/pgsql-stop.tar.gz /export/postgresql/9.3/main
}

function galaxy_stop_epilog() {
  sleep 15
  $ssh_starter rm -rf $TMP_GALAXY
}


function galaxy_destroy() {
  echo "rm -rf $app_path/.galaxy ..."
  rm -rf $app_path/.galaxy
}
