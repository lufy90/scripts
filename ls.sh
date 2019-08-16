#!/bin/bash
# get the difference of 2 files or directories.


differ()
{
  local file_1=$1
  local file_2=$2
  local tmp=/tmp/tree

  if [ -d $file_1 ] && [ -d $file_2 ]; then
    tree $file_1 > ${tmp}_1
    tree $file_2 > ${tmp}_2
    local t=`diff /tmp/tree_1 /tmp/tree_2`
    if [[ t != 0 ]]; then
      echo "$file_1 and $file_2 have different directory structure."
    fi
  fi
}

file_lister()
{
# list all files(not directory) 
  local f_name=$1
  if [ -d $f_name ]; then
    for i in `ls $f_name`
      do
        file_lister $f_name/$i
      done
  else
#   echo $f_name
    md5sum $f_name
  fi
}




main()
{
  file_lister $1  

}


main $1
