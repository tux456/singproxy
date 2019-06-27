############################################################################
# Demo 
############################################################################

function _demo() {
  export CCPROXY_ECHO_END="quiet"

  if [ -z "$CCPROXY_DEMO_PATH" ];then
    CCPROXY_DEMO_PATH=$HOME/genapproxy_demo
    mkdir -p $CCPROXY_DEMO_PATH;chmod 700 $CCPROXY_DEMO_PATH
  fi

  if [ -z "$CCPROXY_DEMO_USER" ];then
    CCPROXY_DEMO_USER=2
  fi

  tmp_pass=$(genpass)
  tmp_id=$(genpass)
  # Create Galaxy
  $0 create --app=galaxy --user=admin --password=$tmp_pass --id=$tmp_id --path=$CCPROXY_DEMO_PATH
  echo "You should not play here!!!" >$CCPROXY_DEMO_PATH/.galaxy/readme.txt
  # Create FileBrowser
  $0 create --app=filebrowser --user=admin --password=$tmp_pass --id=$tmp_id --path=$CCPROXY_DEMO_PATH
  # Create DataHub
  mkdir -p $CCPROXY_DEMO_PATH/datahub
  $0 create --app=datahub --path=$CCPROXY_DEMO_PATH/datahub --id=$tmp_id
  echo "Files uploaded here will be visible in the public datahub app" >$CCPROXY_DEMO_PATH/datahub/readme.txt
  echo  "$USER $tmp_pass  (admin)" >$CCPROXY_DEMO_PATH/user.txt
  $0 stop --app=filebrowser --path=$CCPROXY_DEMO_PATH

  for i in $(seq 1 $CCPROXY_DEMO_USER);do
    tmp_pass=$(genpass)
    $0 useradd --user=user$i --password=$tmp_pass --app=galaxy --path=$CCPROXY_DEMO_PATH
    $0 useradd --user=user$i --password=$tmp_pass --scope=/ftp/user$i --app=filebrowser --path=$CCPROXY_DEMO_PATH
    echo "Files uploaded here will be visible for \"user$i\" in Galaxy upload tools" >$CCPROXY_DEMO_PATH/ftp/user$i/readme.txt
    echo "user$i $tmp_pass" >>$CCPROXY_DEMO_PATH/user.txt
  done

  $0 start --app=filebrowser --path=$CCPROXY_DEMO_PATH


  echo
  echo "***********************"
  echo " Installation done!"
  echo "***********************"
  echo
  echo "************************************************************"
  echo " Your applications data are in the folllowing directory: "
  echo "************************************************************"
  echo "$CCPROXY_DEMO_PATH"
  echo
  echo "************************************************************"
  echo " You can reach app them with the following URLs: "
  echo "************************************************************"
  for i in galaxy filebrowser datahub; do
    echo -n "$i: "
    cat ~/.ccproxy/app/*$i$tmp_id*/url
  done |column -t
  echo
  echo "************************************************************"
  echo " The user credantials are:"
  echo " [login] [password]"
  echo "************************************************************"
  cat $CCPROXY_DEMO_PATH/user.txt
  echo
}


function _demo_destroy() {
  export CCPROXY_ECHO_END="quiet"

  if [ -z "$CCPROXY_DEMO_PATH" ];then
    CCPROXY_DEMO_PATH=$HOME/genapproxy_demo
    mkdir -p $CCPROXY_DEMO_PATH;chmod 700 $CCPROXY_DEMO_PATH
  fi


  $0 destroy --app=galaxy --path=$CCPROXY_DEMO_PATH
  $0 destroy --app=filebrowser --path=$CCPROXY_DEMO_PATH
  $0 destroy --app=datahub --path=$CCPROXY_DEMO_PATH/datahub
  rm -rf $CCPROXY_DEMO_PATH
}

