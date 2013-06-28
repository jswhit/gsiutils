#!/bin/sh

#--------------------------------------------------------------------
#  MkCtl_glbl.sh
#
#    This script generates the control files for a given suffix 
#    (source), using the JGDAS_VRFYRAD.sms.prod job.  The resulting
#    control files are stored in $TANKDIR.
#    
#    This script is designed to be run manually, and should only be
#    necessary if the user had previously overriden the default 
#    settings and switched off the control file generation done by
#    the VrfyRad_*.sh scripts.
#
#--------------------------------------------------------------------

function usage {
  echo "Usage:  MkCtl_glbl.sh suffix"
  echo "            File name for MkCtl_glbl.sh may be full or relative path"
  echo "            Suffix is the indentifier for this data source, and should"
  echo "             correspond to an entry in the ../../parm/data_map file."
}

set -ax
echo start MkCtl_glbl.sh

nargs=$#
if [[ $nargs -ne 1 ]]; then
   usage
   exit 1
fi

this_file=`basename $0`
this_dir=`dirname $0`

export SUFFIX=$1
jobname=make_ctl_${SUFFIX}

echo SUFFIX = $SUFFIX
echo RUN_ENVIR = $RUN_ENVIR

#--------------------------------------------------------------------
# Set environment variables
#--------------------------------------------------------------------

top_parm=${this_dir}/../../parm

if [[ -s ${top_parm}/RadMon_config ]]; then
   . ${top_parm}/RadMon_config
else
   echo "Unable to source RadMon_config file in ${top_parm}"
   exit 2
fi

if [[ -s ${top_parm}/RadMon_user_settings ]]; then
   . ${top_parm}/RadMon_user_settings
else
   echo "Unable to source RadMon_user_settings file in ${top_parm}"
   exit 2
fi

. ${RADMON_DATA_EXTRACT}/parm/data_extract_config

#--------------------------------------------------------------------
# Get the area (glb/rgn) for this suffix
#--------------------------------------------------------------------
area=${RAD_AREA}
echo $area

if [[ $area = glb ]]; then
   export RAD_AREA=glb
   . ${PARMverf_rad}/glbl_conf
elif [[ $area = rgn ]]; then
   export RAD_AREA=rgn
   . ${PARMverf_rad}/rgnl_conf
else
  echo "Suffix $SUFFIX not found in ../../data_map file"
  exit 3 
fi

mkdir -p $TANKDIR
mkdir -p $LOGSverf_rad

export MAKE_CTL=1
export MAKE_DATA=0
export RUN_ENVIR=dev

#---------------------------------------------------------------
# Get date of cycle to process.  Start with the last processed
# date in the data_map file and work backwards until we find a
# valid radstat file or hit the limit on $ctr. 
#---------------------------------------------------------------
PDATE=`${SCRIPTS}/find_last_cycle.pl ${TANKDIR}`
export DATDIR=$RADSTAT_LOCATION
   
ctr=0
need_radstat=1
while [[ $need_radstat -eq 1 && $ctr -lt 10 ]]; do

   sdate=`echo $PDATE|cut -c1-8`
   export CYA=`echo $PDATE|cut -c9-10`
   testdir=${DATDIR}/gdas.$sdate

   #---------------------------------------------------------------
   # Locate required files or reset PDATE and try again.
   #---------------------------------------------------------------
   if [[ -s $testdir/gdas1.t${CYA}z.radstat ]]; then

      export biascr=${testdir}/gdas1.t${CYA}z.abias
      export satang=${testdir}/gdas1.t${CYA}z.satang
      export radstat=${testdir}/gdas1.t${CYA}z.radstat
      need_radstat=0
   elif [[ -s $testdir/radstat.gdas.${PDATE} ]]; then
      export biascr=$DATDIR/biascr.gdas.${PDATE}  
      export satang=$DATDIR/satang.gdas.${PDATE}
      export radstat=$DATDIR/radstat.gdas.${PDATE}
      need_radstat=0
   else
      export PDATE=`$NDATE -06 $PDATE`
      ctr=$(( $ctr + 1 ))
   fi
done

export PDY=`echo $PDATE|cut -c1-8`
export CYC=`echo $PDATE|cut -c9-10`

#--------------------------------------------------------------------
#  Process if radstat file exists.
#--------------------------------------------------------------------
data_available=0
if [[ -s ${radstat} ]]; then
   data_available=1

   export MP_SHARED_MEMORY=yes
   export MEMORY_AFFINITY=MCM

   export envir=prod
   export RUN_ENVIR=dev
   
   export cyc=$CYC
   export job=gdas_mkctl_${PDY}${cyc}
   export SENDSMS=NO
   export DATA_IN=$STMP/$LOGNAME
   export DATA=$STMP/$LOGNAME/radmon
   export jlogfile=$STMP/$LOGNAME/jlogfile
   export TANKverf=${TANKDIR}
   export LOGDIR=$PTMP/$LOGNAME/logs/radopr

   export VERBOSE=YES
   export satype_file=${TANKverf}/info/SATYPE.txt

   export listvar=MP_SHARED_MEMORY,MEMORY_AFFINITY,envir,RUN_ENVIR,PDY,cyc,job,SENDSMS,DATA_IN,DATA,jlogfile,HOMEgfs,TANKverf,MAIL_TO,MAIL_CC,VERBOSE,radstat,satang,biascr,USE_ANL,satype_file,base_file,MAKE_DATA,MAKE_CTL,listvar

   #------------------------------------------------------------------
   #   Submit data processing jobs.
   #------------------------------------------------------------------
   if [[ $MY_MACHINE = "ccs" ]]; then
      $SUB -a $ACCOUNT -e $listvar -j ${jobname} -q dev -g ${USER_CLASS} -t 0:05:00 -o $LOGDIR/make_ctl.${PDY}.${cyc}.log  $HOMEgfs/jobs/JGDAS_VRFYRAD.sms.prod
   elif [[ $MY_MACHINE = "zeus" ]]; then
      $SUB -A $ACCOUNT -l walltime=0:05:00 -v $listvar -j oe -o $LOGDIR/make_ctl.${PDY}.${cyc}.log $HOMEgfs/jobs/JGDAS_VRFYRAD.sms.prod
   fi


fi

#--------------------------------------------------------------------
# Clean up and exit
#--------------------------------------------------------------------

exit_value=0
if [[ ${data_available} -ne 1 ]]; then
   exit_value=5
   echo No data available for ${SUFFIX}
fi

echo end MkCtl_glbl.sh
exit ${exit_value}

