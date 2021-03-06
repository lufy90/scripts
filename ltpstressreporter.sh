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
SARCPU=sar-u*
SARMEM=sar-r*
SARSWAP=sar-S*
SARQUEUE=sar-q*
STRESSDETAIL=ltpstress*[1-3]
GENLOAD_SCRIPT=genload.sh
RESULTDIR=$1
RS="PASS FAIL CONF"
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
    sar_u_idle=$(tail -n 1 $SARCPU | awk '{print $NF}' 2>/dev/null)
  else
    sar_u_idle=$(sar -u -f $SARLOG | tail -n 1 | awk '{print $NF}' 2>/dev/null)
  fi
  sar_u=$(echo "100 - $sar_u_idle" | bc)

  if [ -f $SARMEM ]; then
    sar_m=$(tail -n 1 $SARMEM | awk '{print $4}' 2>/dev/null)
  else
    sar_m=$(sar -r -f $SARLOG | tail -n 1 | awk '{print $4}' 2>/dev/null)
  fi

  if [ -f $SARSWAP ]; then
    sar_s=$(tail -n 1 $SARSWAP | awk '{print $4}' 2>/dev/null)
  else
    sar_s=$(sar -S -f $SARLOG | tail -n 1 | awk '{print $4}' 2>/dev/null)
  fi

  if [ -f $SARQUEUE ]; then
    sar_q1=$(tail -n 1 $SARQUEUE | awk '{print $4}' 2>/dev/null)
    sar_q5=$(tail -n 1 $SARQUEUE | awk '{print $5}' 2>/dev/null)
    sar_q15=$(tail -n 1 $SARQUEUE | awk '{print $6}' 2>/dev/null)
  else
    sar_q1=$(sar -q -f $SARLOG | tail -n 1 | awk '{print $4}' 2>/dev/null)
    sar_q5=$(sar -q -f $SARLOG | tail -n 1 | awk '{print $5}' 2>/dev/null)
    sar_q15=$(sar -q -f $SARLOG | tail -n 1 | awk '{print $6}' 2>/dev/null)
  fi

}


summary()
{

#  local results_dir=${RESULTDIR}
 
  cd $results_dir 
  get_data
  local sep="--------------------------------------------------------"
  local sep2="========================================================="
 
  echo -e "\e[1mSummary Report of LTP Stress Test\e[0m"
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
  echo "FAIL Count:" $failedcount
  echo "CONF Count:" $confedcount
  echo
  echo "System Load During Test:"
  echo "CPU(%):" $sar_u
  echo "Memory(%):" $sar_m
  echo "SWAP(%):" $sar_s
  echo -e "Queue:\tldavg-1\tldavg-5\tldavg-15\n\t$sar_q1\t$sar_q5\t$sar_q15"
  echo

  echo "FAIL Cases(${failednum} in total):"
  grep FAIL $STRESSLOG | awk '{print $1}'| sort | uniq  
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

statistics(){
echo -ne "No.\tCase Name\tType\tPass Times\tFAIL Times\tCONF Times\n"
local i=1
local c=
local RS="FAIL CONF"

for rs in $RS
do
    for c in `grep $rs $STRESSLOG | awk '{print $1}' | sort | uniq`
    do
    local tpass=$(grep "^$c" $STRESSLOG | grep "PASS" | wc -l)
    local tfail=$(grep "^$c" $STRESSLOG | grep "FAIL" | wc -l)
    local tconf=$(grep "^$c" $STRESSLOG | grep "CONF" | wc -l)
    echo -ne "${i}\t${c}\t${rs}\t${tpass}\t${tfail}\t${tconf}\n"
    i=$((i+1))
    done
done
}


report
statistics
