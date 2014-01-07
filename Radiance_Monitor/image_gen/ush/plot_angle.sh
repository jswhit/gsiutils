#! /bin/ksh

#------------------------------------------------------------------
#
#  plot_angle.sh
#
#------------------------------------------------------------------

set -ax
export list=$listvar

echo
echo PATH=$PATH
echo

SATYPE2=$1
PVAR=$2
PTYPE=$3

export SUB_AVG=${SUB_AVG:-1}
export PLOT_ALL_REGIONS=${PLOT_ALL_REGIONS:-1}

plot_angle_count=plot_angle_count.${RAD_AREA}.gs
plot_angle_sep=plot_angle_sep.${RAD_AREA}.gs


#------------------------------------------------------------------
# Create $tmpdir.

word_count=`echo $PTYPE | wc -w`
echo word_count = $word_count

if [[ $word_count -le 1 ]]; then
   tmpdir=${PLOT_WORK_DIR}/plot_angle_${SUFFIX}_${SATYPE2}.$PDATE.${PVAR}.${PTYPE}
else
   tmpdir=${PLOT_WORK_DIR}/plot_angle_${SUFFIX}_${SATYPE2}.$PDATE.${PVAR}
fi
rm -rf $tmpdir
mkdir -p $tmpdir
cd $tmpdir



#------------------------------------------------------------------
#   Set dates

bdate=${START_DATE}
edate=$PDATE
bdate0=`echo $bdate|cut -c1-8`
edate0=`echo $edate|cut -c1-8`



#--------------------------------------------------------------------
# Copy control files to $tmpdir

imgdef=`echo ${#IMGNDIR}`
if [[ $imgdef -gt 0 ]]; then
  ctldir=$IMGNDIR/angle
else
  ctldir=$TANKDIR/angle
fi

echo ctldir = $ctldir

for type in ${SATYPE2}; do
  $NCP $ctldir/${type}.ctl* ./
done
${UNCOMPRESS} *.ctl.${Z}


#--------------------------------------------------------------------
# Loop over satellite types.  Copy data files, create plots and 
# place on the web server. 
#
# Data file location may either be in angle, bcoef, bcor, and time 
# subdirectories under $TANKDIR, or in the Operational organization
# of radmon.YYYYMMDD directories under $TANKDIR. 

for type in ${SATYPE2}; do

   cdate=$bdate
   while [[ $cdate -le $edate ]] ; do
      day=`echo $cdate | cut -c1-8 `

      if [[ -d ${TANKDIR}/radmon.${day} ]]; then
         test_file=${TANKDIR}/radmon.${day}/angle.${type}.${cdate}.ieee_d
         if [[ -s $test_file ]]; then
            $NCP ${test_file} ./${type}.${cdate}.ieee_d
         elif [[ -s ${test_file}.${Z} ]]; then
            $NCP ${test_file}.${Z} ./${type}.${cdate}.ieee_d.${Z}
         fi
      fi
      if [[ ! -s ${type}.${cdate}.ieee_d && ! -s ${type}.${cdate}.ieee_d.${Z} ]]; then
         $NCP $TANKDIR/angle/${type}.${cdate}.ieee_d* ./
      fi
     
      adate=`$NDATE +6 $cdate`
      cdate=$adate

   done
   ${UNCOMPRESS} $tmpdir/*.ieee_d.${Z}

   for var in ${PTYPE}; do
      echo $var
      if [ "$var" =  'count' ]; then

cat << EOF > ${type}_${var}.gs
'open ${type}.ctl'
'run ${GSCRIPTS}/${plot_angle_count} ${type} ${var} ${PLOT_ALL_REGIONS} ${SUB_AVG} x1100 y850'
'quit'
EOF

      elif [ "$var" =  'penalty' ]; then
cat << EOF > ${type}_${var}.gs
'open ${type}.ctl'
'run ${GSCRIPTS}/${plot_angle_count} ${type} ${var} ${PLOT_ALL_REGIONS} ${SUB_AVG} x1100 y850'
'quit'
EOF
      else

cat << EOF > ${type}_${var}.gs
'open ${type}.ctl'
'run ${GSCRIPTS}/${plot_angle_sep} ${type} ${var} ${PLOT_ALL_REGIONS} ${SUB_AVG} x1100 y850'
'quit'
EOF
      fi

      $GRADS -bpc "run ${tmpdir}/${type}_${var}.gs"
   done 

#   rm -f ${type}*.ieee_d
#   rm -f ${type}.ctl

done

#--------------------------------------------------------------------
# Copy image files to $IMGNDIR to set up for mirror to web server.  
# Delete images and data files.

if [[ ! -d ${IMGNDIR}/angle ]]; then
   mkdir -p ${IMGNDIR}/angle
fi
find . -name '*.png' -exec cp -pf {} ${IMGNDIR}/angle/ \;




#--------------------------------------------------------------------
# Clean $tmpdir. 

#cd $tmpdir
#cd ../
#rm -rf $tmpdir


#--------------------------------------------------------------------
# If this is the last angle plot job to finish then rm PLOT_WORK_DIR.
# 
#echo ${LOADLQ}

#count=`ls ${LOADLQ}/*plot*_${SUFFIX}* | wc -l`
#complete=`grep "COMPLETED" ${LOADLQ}/*plot*_${SUFFIX}* | wc -l`

#running=`expr $count - $complete`

#if [[ $running -eq 1 ]]; then
#   cd ${PLOT_WORK_DIR}
#   cd ../
#   rm -rf ${PLOT_WORK_DIR}
#fi

exit
