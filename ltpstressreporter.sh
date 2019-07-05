#!/bin/bash
# ltpstressreporter.sh
# 20190703 by Lufei
# for simply getting a summary of ltpstress test.
# Version: 0.0


## User specifying
TEST_EXE=test.sh
SYSINFO=*info
STRESSLOG=stress.log*
SARLOG=sar.out*
SARCPU=sar-u.out
SARMEM=sar-r.out
SARSWAP=sar-S.out
SARQUEUE=sar-q.out
STRESSDETAIL=ltpstress*[1-3]
GENLOAD_SCRIPT=genload.sh
RESULTDIR=$1

get_data()
{
  ## Auto Calculating
  test_date1=$(grep "Test Start Time: " $STRESSLOG | awk -F ": " '{print $2}'| head -n 1 2>/dev/null)
  test_date2=$(grep "Test Start Time: " $STRESSLOG | awk -F ": " '{print $2}'| head -n 2 | tail -n 1 2>/dev/null)
  test_date3=$(grep "Test Start Time: " $STRESSLOG | awk -F ": " '{print $2}'| tail -n 1 2>/dev/null)
  if [ "$test_date1" == "$test_date2" ] && [ "$test_date1" == "$test_date3" ]; then
    test_date=$test_date1
  else
    test_date=$(grep "Test Start Time: " $STRESSLOG | awk -F ": " '{print $2}'  2>/dev/null)
  fi
  
  failedcount=$(grep FAIL $STRESSLOG | wc -l 2>/dev/null)
  passedcount=$(grep PASS $STRESSLOG | wc -l 2>/dev/null)
  confedcount=$(grep CONF $STRESSLOG | wc -l 2>/dev/null)
  totalcount=$(($failedcount+$passedcount+$confedcount))

  failednum=$(grep FAIL $STRESSLOG | awk '{print $1}' | sort | uniq | wc -l 2>/dev/null)
  confednum=$(grep CONF $STRESSLOG | awk '{print $1}' | sort | uniq | wc -l 2>/dev/null)
  passednum=$(grep PASS $STRESSLOG | awk '{print $1}' | sort | uniq | wc -l 2>/dev/null)
  if [ -f $SARCPU ]; then
    sar_u_idle=$(grep Average $SARCPU | awk '{print $NF}' 2>/dev/null)
  else
    sar_u_idle=$(sar -u -f $SARLOG | grep Average | awk '{print $NF}' 2>/dev/null)
  fi
  sar_u=$(echo "100 - $sar_u_idle" | bc)

  if [ -f $SARMEM ]; then
    sar_m=$(grep Average $SARMEM | awk '{print $4}' 2>/dev/null)
  else
    sar_m=$(sar -r -f $SARLOG | grep Average | awk '{print $4}' 2>/dev/null)
  fi

  if [ -f $SARSWAP ]; then
    sar_s=$(grep Average $SARSWAP | awk '{print $4}' 2>/dev/null)
  else
    sar_s=$(sar -S -f $SARLOG | grep Average | awk '{print $4}' 2>/dev/null)
  fi

  if [ -f $SARQUEUE ]; then
    sar_q1=$(grep Average $SARQUEUE | awk '{print $4}' 2>/dev/null)
    sar_q5=$(grep Average $SARQUEUE | awk '{print $5}' 2>/dev/null)
    sar_q15=$(grep Average $SARQUEUE | awk '{print $6}' 2>/dev/null)
  else
    sar_q1=$(sar -q -f $SARLOG | grep Average | awk '{print $4}' 2>/dev/null)
    sar_q5=$(sar -q -f $SARLOG | grep Average | awk '{print $5}' 2>/dev/null)
    sar_q15=$(sar -q -f $SARLOG | grep Average | awk '{print $6}' 2>/dev/null)
  fi

}


summary()
{

#  local results_dir=${RESULTDIR}
 
  cd $results_dir 
  get_data
  local sep="--------------------------------------------------------"
  local sep2="========================================================="
 
  echo "Summary Report of LTP Stress Test"
#  echo $sep2
  echo Test Information
  echo  "$sep"
  echo "OS:" $(cat ${SYSINFO}/isoft-release 2>/dev/null)
  echo "Machine:" $(cat ${SYSINFO}/hostname 2>/dev/null)
  echo "Ltp Version:" $(cat Version 2>/dev/null)
  echo "Test Date:" $test_date
  echo "Test Commands:" $(grep ltpstress.sh $TEST_EXE 2>/dev/null)
  echo "Manually Load:" $(cat $GENLOAD_SCRIPT 2>/dev/null )
  echo -e "$sep\n"

  echo "Result Summary"
  echo  $sep
  echo "Cases in Total:" $totalcount
  echo "FAIL Cases:" $failedcount
  echo "CONF Cases:" $confedcount
  echo
  echo "System Load During Test:"
  echo "CPU(%):" $sar_u
  echo "Memory(%):" $sar_m
  echo "SWAP(%):" $sar_s
  echo -e "Queue:\tldavg-1\tldavg-5\tldavg-15\n\t$sar_q1\t$sar_q5\t$sar_q15"
  echo

  echo "FAIL Cases(${failednum} in total):"
  grep FAIL $STRESSLOG | sort | uniq | awk '{print $1}'
  
  echo 
  echo "CONF Cases(${confednum} in total):"
  grep CONF $STRESSLOG | sort | uniq | awk '{print $1}'
  echo -e "$sep\n"
#  echo $sep2

}

detail()
{
:
}

usage()
{
  echo "Usage: $0 <results dir>"
}
report()
{
  local results_dir=$RESULTDIR
  if [ ! -d $results_dir ] || [ -z $results_dir ]; then
    echo "Not a directory: $results_dir"
    usage 
    exit 2
  fi
  summary
}

report
