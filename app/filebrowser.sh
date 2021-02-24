############################################################################
# FILEBROWSER
############################################################################


function filebrowser_create {
  filebrowser_log=$app_confdir/filebrowser.log
  if [ -f "$GENAP_FILEBROWSER_FILE" ];then
    cp $GENAP_FILEBROWSER_FILE $app_confdir
  else
    filegz=linux-amd64-filebrowser.tar.gz
    file_source="https://github.com/filebrowser/filebrowser/releases/download/"
    #file_release="v2.0.4"
    file_release="$(curl -L -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest | grep -o '"tag_name": ".*"' | sed 's/"//g' | sed 's/tag_name: //g')"
    (cd $app_confdir;curl -L -s --output $filegz $file_source/$file_release/$filegz; tar --warning=no-timestamp zxf $filegz filebrowser;rm $filegz)
  fi
 
  singularity -q instance start -B $app_confdir/:/conf -B $app_path:/data docker://alpine $app_id
  #singularity -q instance start -B $app_confdir/:/conf -B $app_path:/data /net/ip24/home.local/barrette.share/filebrowser/alpine_latest.sif $app_id
  if [ -n "$m_password" ];then
    filebrowser_pass="$m_password"
  else
    filebrowser_pass=$(genpass)
  fi
  fb="singularity -q exec instance://$app_id  /conf/filebrowser -d /conf/database.db "
  $fb config init --scope=/data>>$filebrowser_log
  unset filebrowser_auth
  if [ -n "$GENAP_FILEBROWSER_REMOTE_USER" ];then filebrowser_auth="--auth.method=proxy --auth.header=$GENAP_FILEBROWSER_REMOTE_USER";fi
  if [ "$GENAP_FILEBROWSER_REMOTE_USER" == "noauth" ];then filebrowser_auth="--auth.method=noauth";fi
  if [ -d "$CCPROXY_CUSTOM_DIR" ];then
    cp -a $CCPROXY_CUSTOM_DIR/img $app_confdir/img
    $fb config set --branding.name "$CCPROXY_CUSTOM_NAME" --branding.files /conf --branding.disableExternal $filebrowser_auth >>$filebrowser_log
  fi
  if [ -z "$GENAP_FILEBROWSER_CREATE_OPTION" ];then GENAP_FILEBROWSER_CREATE_OPTION="--perm.admin";fi
  $fb users add $USER $filebrowser_pass $GENAP_FILEBROWSER_CREATE_OPTION >>$filebrowser_log
  if [ -n "$GENAP_FILEBROWSER_RULES" ];then $fb rules $GENAP_FILEBROWSER_RULES >>$filebrowser_log;fi
  singularity -q instance stop $app_id >/dev/null
  echo "ADMIN USER CREATED: login: $USER  passwd: $filebrowser_pass"

}


function filebrowser_start() {

# Patch temporaire MB 2020-10-29
if [ ! -z "$GENAP_FILEBROWSER_AUTOZAP" ];then
  rm -f $app_confdir/filebrowser $app_confdir/database.db
  cp -f $GENAP_FILEBROWSER_FILE $app_confdir/filebrowser
  cp -f $GENAP_FILEBROWSER_DB $app_confdir/database.db
fi


   filebrowser_log=$app_confdir/filebrowser.log
   singularity -q instance start -B $HOME_CONTAINER:/home -B $TMP_CONTAINER:/tmp -B $app_confdir/:/conf -B $app_path:/data  docker://alpine $app_id
#   singularity -q instance start -B $HOME_CONTAINER:/home -B $TMP_CONTAINER:/tmp -B $app_confdir/:/conf -B $app_path:/data  /net/ip24/home.local/barrette.share/filebrowser/alpine_latest.sif $app_id

   #app_port="$(remote_freeport)"
   singularity -q exec instance://$app_id rm -f /conf/app.sock
   singularity -q exec instance://$app_id /conf/filebrowser -d /conf/database.db -l /conf/filebrowser.log --socket /conf/app.sock >>$filebrowser_log 2>&1 &
}

function filebrowser_exec() {
  if [ "$(cat $app_confdir/status 2>/dev/null)" == "STARTED" ];then
    echo "App started, please stop before running this command"
    exit 0
  fi

  filebrowser_log=$app_confdir/filebrowser.log
  singularity -q instance start -B $app_confdir/:/conf -B $app_path:/data docker://alpine $app_id
#  singularity -q instance start -B $app_confdir/:/conf -B $app_path:/data /net/ip24/home.local/barrette.share/filebrowser/alpine_latest.sif $app_id
  fb="singularity -q exec -B $app_confdir/:/conf -B $app_path:/data instance://$app_id  /conf/filebrowser -d /conf/database.db "
  $fb $* # >>$filebrowser_log
  singularity -q instance stop $app_id >/dev/null
}


function filebrowser_rulesadd(){
  find_id
  filebrowser_exec rules add -u "$m_user" -r "$m_rules"
}


function filebrowser_useradd() {
  find_id
  unset scope_option
  if [ -n "$m_scope" ];then
    mkdir -p $app_path/$m_scope
    scope_option="--scope=/data/$m_scope"
  fi
  
  filebrowser_exec users add $m_user $m_password $scope_option
}

function filebrowser_userupdate() {
  find_id
  unset scope_option passwd_option
  if [ -n "$m_scope" ];then
    mkdir -p $app_path/$m_scope
    scope_option="--scope=/data/$m_scope"
  fi
  if [ -n "$m_password" ];then
    password_option="--password=$m_password"
  fi

  filebrowser_exec users update $m_user $scope_option $password_option
}


