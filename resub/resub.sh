#!/bin/bash

app_dir=$1
log_file=$app_dir/galaxy/etc/galaxy/job_destination.log


qsub_command=sbatch
singularity_exec="singularity exec -B /nfs3_ib/ip24-ib/home.local/barrette.share/template-export/galaxy-central:/export/galaxy-central -B $app_dir/galaxy/database/:/export/galaxy-central/database/ /cvmfs/soft.galaxy/v2/singularity/docker19.01/galadock.img"
#singularity_exec="singularity exec instance://galaxy12"
qsub_account="--account=def-$USER"


function extract_param {
  param=$1
  grep "job_id=$job_id\ " $log_file |sed "s|^.*$param=\(.*\) .*=.*|\1|g" |cut -d \  -f1
}

function generate_qsub {
#  job_id=$1
  echo -n "$qsub_command "
  echo -n "$qsub_account "
  echo -n "--job-name=galaxy-$job_id --time=$(extract_param walltime):00:00 --cpus-per-task=$(extract_param "ppn") --ram=$(extract_param pmem)M "
  echo -n "--output=$app_dir/galaxy/database/$batch_file.out --error=$app_dir/galaxy/database/$batch_file.err "
  echo -n "$singularity_exec "
}




qsub="sbatch --account=def-$USER singularity exec -B $app_dir/galaxy/database/:/export/galaxy-central/database/ /cvmfs/soft.galaxy/v2/singularity/docker19.01/galadock.img"

cd $app_dir/galaxy/database/

while [ 1 ];do
  for i in $(ls job_working_directory/*/*/galaxy_*.sh-resub 2>/dev/null);do
      batch_file=${i::-6}
      job_id=$(basename $batch_file |sed "s|galaxy_\(.*\).sh|\1|g")
      if [ "$(extract_param destination)" == "local" ];then
      #  echo "$(date) $singularity_exec /export/galaxy-central/database/$batch_file" 
        echo "$(date) $singularity_exec /export/galaxy-central/database/$batch_file"  >>$(dirname $batch_file)/resub.log
        $singularity_exec /export/galaxy-central/database/$batch_file 2>$app_dir/galaxy/database/$batch_file.err 1>$app_dir/galaxy/database/$batch_file.out
      else
        qsub="$(generate_qsub)"
      #  echo $qsub /export/galaxy-central/database/$batch_file
        echo $qsub /export/galaxy-central/database/$batch_file >>$(dirname $batch_file)/resub.log
        $qsub /export/galaxy-central/database/$batch_file
      fi
      rm -f $i;sync
      ls -la $(dirname $batch_file)
  done
  sleep 3
done
