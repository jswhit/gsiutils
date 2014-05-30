#!/bin/sh
set -xa

export list=$listvar
#--------------------------------------------------
#
#  time_vert.sh
#
#--------------------------------------------------


## set up the directory

export tmpdir=${STMP}/time${SUFFIX}_plot

export nregion=10
export savedir=$TANKDIR/time_vert
export fixfile=global_convinfo.txt
export execfile=conv_time.x
export CYA=`echo $PDATE | cut -c9-10`


gdate=`$NDATE -720 $PDATE`
 hour=`echo $PDATE | cut -c9-10`
 dday=`echo $PDATE | cut -c7-8`

mkdir -p $savedir

#----------------------------------------------------
#  FIX NEEDED:  
#     This needs to catch anything from gdate and older
#
rm -f $savedir/*.${gdate}

rm -rf $tmpdir
mkdir -p $tmpdir
cd $tmpdir
rm -rf *
mkdir $PDATE
cd $PDATE
cp $SCRIPTS/make_timesers_ctl.sh ./make_timesers_ctl.sh
cp $SCRIPTS/julian.sh ./julian.sh

for cycle in ges  anl;do

   rm -f conv_diag
   cp $DATDIR/diag_conv_${cycle}.${PDATE} conv_diag
   cat << EOF > input
&input
  filein='conv_diag', nregion=${nregion},
  region(1)='GL', rlonmin(1)=-180.0,rlonmax(1)=180.0,rlatmin(1)=-90.0,rlatmax(1)= 90.0,
  region(2)='NH',rlonmin(2)=-180.0,rlonmax(2)=180.0,rlatmin(2)= 20.0,rlatmax(2)= 90.0,
  region(3)='SH',rlonmin(3)=-180.0,rlonmax(3)=180.0,rlatmin(3)=-90.0,rlatmax(3)=-20.0,
  region(4)='TR' rlonmin(4)=-180.0,rlonmax(4)=180.0,rlatmin(4)=-20.0,rlatmax(4)= 20.0,
  region(5)='USA' , rlonmin(5)=-125.0,rlonmax(5)=-65.0,rlatmin(5)=25.0,rlatmax(5)=50.0,
  region(6)='CAN', rlonmin(6)=-125.0,rlonmax(6)=-65.0,rlatmin(6)= 50.0,rlatmax(6)= 90.0,
  region(7)='N&CA',rlonmin(7)=-165.0,rlonmax(7)=-60.0,rlatmin(7)= 0.0,rlatmax(7)=90.0,
  region(8)='S&CA',rlonmin(8)=-165.0,rlonmax(8)=-30.0,rlatmin(8)=-90.0, rlatmax(8)=0.0,
  region(9)='EU',  rlonmin(9)=-10.0, rlonmax(9)=25.0, rlatmin(9)=35.0,rlatmax(9)=70.0,
  region(10)='AS',  rlonmin(10)=65.0,  rlonmax(10)=145.0,rlatmin(10)=5.0,rlatmax(10)=45.0,
/
EOF

   cp $EXEDIR/$execfile ./$execfile
   cp ${FIXDIR}/${fixfile} ./convinfo
   ./$execfile <input  > stdout  2>&1

   mv stdout ${cycle}_stdout

   for type in ps t q uv u v; do

      for file2 in ${type}*stas; do
         mv $file2 ${cycle}_${file2}
         mv ${cycle}_${file2} $savedir/${cycle}_${file2}.${PDATE}
      done

      /bin/sh  make_timesers_ctl.sh ${gdate} ${PDATE} $savedir $cycle $type

   done
done

#export listvar=PDATE,NDATE,DATDIR,TANKDIR,IMGNDIR,LLQ,WEBDIR,EXEDIR,FIXDIR,LOGDIR,SCRIPTS,GSCRIPTS,STNMAP,GRADS,USER,SUB,SUFFIX,NPREDR,NCP,PLOT,PREFIX,ACCOUNT,STMP,MY_MACHINE,nreal_ps,nreal_q,nreal_t,nreal_uv,savedir,tmpdir,WS,WSUSER,listvar

##for type in ps q t uv u v; do

##   if [ "${type}"  = 'ps' ];then


#
#  make time plots
#
# PROBLEM:  no data out, not clear why

jobname="cmon_plot_t_ps_${SUFFIX}"
logfile="${LOGDIR}/plot_conv_time_ps_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_time_ps.sh"
rm -f $logfile

if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o ${logfile} -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile

fi

#
# PROBLEM:  no data out, not clear why
#
jobname="cmon_plot_t_q_${SUFFIX}"
logfile="${LOGDIR}/plot_time_q_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_time.sh q"
rm -f $logfile
if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o $logfile -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile
fi

jobname="cmon_plot_t_t_${SUFFIX}"
logfile="${LOGDIR}/plot_conv_time_t_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_time.sh t"
rm -f $logfile
if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o $logfile -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile
fi


jobname="cmon_plot_t_uv_${SUFFIX}"
logfile="${LOGDIR}/plot_time_uv_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_time.sh uv"
rm -f $logfile
if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o $logfile -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile
fi


jobname="cmon_plot_t_u_${SUFFIX}"
logfile="${LOGDIR}/plot_time_u_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_time.sh u"
rm -f $logfile
if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o $logfile -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile
fi


jobname="cmon_plot_t_v_${SUFFIX}"
logfile="${LOGDIR}/plot_time_v_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_time.sh v"
rm -f $logfile
if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o $logfile -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile
fi


##
##  make vertical plots
##
jobname="cmon_plot_v_q_${SUFFIX}"
logfile="${LOGDIR}/plot_v_q_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_vert.sh q"
rm -f $logfile
if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o $logfile -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile
fi

jobname="cmon_plot_v_t_${SUFFIX}"
logfile="${LOGDIR}/plot_v_t_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_vert.sh t"
rm -f $logfile
if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o $logfile -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile
fi


jobname="cmon_plot_v_uv_${SUFFIX}"
logfile="${LOGDIR}/plot_v_uv_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_vert.sh uv"
rm -f $logfile
if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o $logfile -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile
fi


jobname="cmon_plot_v_u_${SUFFIX}"
logfile="${LOGDIR}/plot_v_u_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_vert.sh u"
rm -f $logfile
if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o $logfile -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile
fi

jobname="cmon_plot_v_v_${SUFFIX}"
logfile="${LOGDIR}/plot_v_v_${SUFFIX}.log"
pltfile="${SCRIPTS}/plot_vert.sh v"
rm -f $logfile
if [[ $MY_MACHINE == "wcoss" ]]; then
   $SUB -q $JOB_QUEUE -P $PROJECT -o $logfile -R affinity[core] -M 100 -W 0:50 -J $jobname $pltfile
fi

##fi
##done

exit
