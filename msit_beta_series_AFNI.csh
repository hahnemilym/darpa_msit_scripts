#! /bin/csh


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
## TO-DO
## Change all activesubjdir instances to DATA_DIR
## Was 1dtranspose censor file input created from make_motion_regressors.m ?
## Does ${study}.${SUBJECT}.func.scaled.resid_size.nii exist from functional output ?
## Compare MSIT par file w/ AFNI stim files
## Check new arc preproc script for how to generate STC file and integrate into func preproc 1,2
## Debug subj who crashed on 3dAutomask
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# I. Set up environment
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

source /usr/local/freesurfer/nmr-stable60-env

# Local Directory
setenv MSIT_DIR /Users/emilyhahn/projects/msit/

# Subjects Directory
setenv SUBJECTS_DIR ${MSIT_DIR}/subjs

# Parameters Directory
setenv PARAMS_DIR ${MSIT_DIR}/bsm_params

# Analysis Directory
setenv ANALYSIS_DIR ${MSIT_DIR}/scripts

# SUBJECT_LIST Directory
setenv SUBJECT_LIST ${PARAMS_DIR}/subjects_list_01-11-19.txt

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# II. Define parameters.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
set FWHM = 6
set TR = 1.75
set polort = A
# A = set polynomial order (detrending param) automatically

set stim_txt_file = ${PARAMS_DIR}/msit_bsm_stim.par # 193 stim times
set num_stimts = 1
# E.G. num_stimts = 3; includes shock, rating, CS_presentation.
# Change this param and to = 2 if comparing C, I conditions seprately. Also stim_times_IM and stim_label

set study = msit
set task = (${study}_bsm)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# III. INDIVIDUAL ANALYSES
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#set subjects = ($SUBJECT_LIST)
#foreach SUBJECT ( `cat $subjects` )

set subjects = test_002
foreach SUBJECT ($subjects)

setenv DATA_DIR = ${SUBJECTS_DIR}/${SUBJECT}/${task}
cd $DATA_DIR

echo "*******************************************************************************"
echo " AFNI | Beta Series Method Analysis "
echo "*******************************************************************************"

#rm ${activeSubjectdirectory}/analyze/LSS.xmat.1D
#rm ${activeSubjectdirectory}/analyze/LSS.${SUBJECT}.nii

echo "*******************************************************************************"
echo " AFNI | 1dtranspose "
echo "*******************************************************************************"

#rm censor_file

1dtranspose ${activeSubjectdirectory}/func/${study}.${SUBJECT}.func.censor.1D > ./func_t
1dtranspose func_t > censor_file

echo "*******************************************************************************"
echo " AFNI | 3dDeconvolve task "
echo "*******************************************************************************"

3dDeconvolve \
-force_TR $TR \
-input ${activeSubjectdirectory}/func/${study}.${SUBJECT}.func.scaled.resid_size.nii
-nfirst 0 \
-censor ${activeSubjectdirectory}/censor_file \
-polort $polort \
-num_stimts $num_stimts \
-stim_times_IM 1 ${activeSubjectdirectory}/analyze/${SUBJECT}.${stim_txt_file} "BLOCK(1,1)" \
-stim_label 1 stim_times_IM_label \
-x1D ${activeSubjectdirectory}/analyze/LSS.xmat.1D \
-allzero_OK \
-nobucket \
-x1D_stop

echo "*******************************************************************************"
echo " AFNI | 3dLSS "
echo "*******************************************************************************"

3dLSS \
-input ${activeSubjectdirectory}/func/${study}.${SUBJECT}.func.scaled.resid_size.nii \
-matrix ${activeSubjectdirectory}/analyze/LSS.xmat.1D \
-prefix ${activeSubjectdirectory}/analyze/LSS.${SUBJECT}.nii

echo "*******************************************************************************"
echo " AFNI | 3dDespike "
echo "*******************************************************************************"

#rm ${activeSubjectdirectory}/analyze/LSS.${SUBJECT}_despike.nii

3dDespike \
-prefix ${activeSubjectdirectory}/analyze/LSS.${SUBJECT}_despike.nii \
${activeSubjectdirectory}/analyze/LSS.${SUBJECT}.nii

echo "*******************************************************************************"
echo " AFNI | Beta Series Method COMPLETE: " ${SUBJECT}
echo "*******************************************************************************"

cd ${ANALYSIS_DIR}

## End subject loop
end
