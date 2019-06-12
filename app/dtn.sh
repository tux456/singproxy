############################################################################
# DTN
############################################################################


function dtn_create {
  dtn_log=$app_confdir/filebrowser.log
  if [ -f "$GENAP_FILEBROWSER_FILE" ];then
    cp $GENAP_FILEBROWSER_FILE $app_confdir
  else
    filegz=linux-amd64-filebrowser.tar.gz
    file_source="https://github.com/filebrowser/filebrowser/releases/download/"
    #file_release="v2.0.4"
    file_release="$(curl -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest | grep -o '"tag_name": ".*"' | sed 's/"//g' | sed 's/tag_name: //g')"
    (cd $app_confdir;wget -q $file_source/$file_release/$filegz; tar zxf $filegz filebrowser;rm $filegz)
  fi
 
  singularity -q instance start -B $app_confdir/:/conf -B $app_path:/data docker://alpine $app_id
  dtn_pass=$(genpass)
  fb="singularity -q exec instance://$app_id  /conf/filebrowser -d /conf/database.db "
  $fb config init --scope=/data>>$dtn_log
  unset dtn_auth
  if [ -n "$GENAP_DTN_REMOTE_USER" ];then dtn_auth="--auth.method=proxy --auth.header=$GENAP_DTN_REMOTE_USER";fi
  if [ -d "$CCPROXY_CUSTOM_DIR" ];then
    cp -a $CCPROXY_CUSTOM_DIR/img $app_confdir/img
    $fb config set --branding.name "$CCPROXY_CUSTOM_NAME" --branding.files /conf --branding.disableExternal $dtn_auth >>$dtn_log
  fi
  $fb users add $USER $dtn_pass --perm.admin >>$dtn_log
  singularity -q instance stop $app_id >/dev/null
  echo "ADMIN USER CREATED: login: $USER  passwd: $dtn_pass"

}


function dtn_start() {
   dtn_log=$app_confdir/filebrowser.log
   singularity -q instance start -B $app_confdir/:/conf -B $app_path:/data  docker://alpine $app_id
   #app_port="$(remote_freeport)"
   singularity -q exec instance://$app_id rm -f /conf/app.sock
   singularity -q exec instance://$app_id /conf/filebrowser -d /conf/database.db -l /conf/filebrowser.log --socket /conf/app.sock >>$dtn_log 2>&1 &
}

function dtn_exec() {
  if [ "$(cat $app_confdir/status 2>/dev/null)" == "STARTED" ];then
    echo "App started, please stop before running this command"
    exit 0
  fi

  dtn_log=$app_confdir/filebrowser.log
  singularity -q instance start -B $app_confdir/:/conf -B $app_path:/data docker://alpine $app_id
  fb="singularity -q exec -B $app_confdir/:/conf -B $app_path:/data instance://$app_id  /conf/filebrowser -d /conf/database.db "
  $fb $* # >>$dtn_log
  singularity -q instance stop $app_id >/dev/null
}


function dtn_rulesadd(){
  find_id
  dtn_exec rules add -u "$m_user" -r "$m_rules"
}


function dtn_useradd() {
  find_id
  unset scope_option
  if [ -n "$m_scope" ];then
    mkdir -p $app_path/$m_scope
    scope_option="--scope=/data/$m_scope"
  fi
  
  dtn_exec users add $m_user $m_password $scope_option
}

function dtn_userupdate() {
  find_id
  unset scope_option passwd_option
  if [ -n "$m_scope" ];then
    mkdir -p $app_path/$m_scope
    scope_option="--scope=/data/$m_scope"
  fi
  if [ -n "$m_password" ];then
    password_option="--password=$m_password"
  fi

  dtn_exec users update $m_user $scope_option $password_option
}


