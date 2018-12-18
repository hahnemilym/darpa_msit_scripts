#! /bin/csh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# I. Set up environment
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
source /usr/local/freesurfer/nmr-stable60-env

# Local Directory
setenv DIR /autofs/space/lilli_

# Subjects Directory
setenv SUBJECTS_DIR ${DIR}001/users/DARPA-Recons

# Analysis Directory
setenv ANALYSES_DIR ${DIR}001/users/DARPA-Scripts/tutorials/darpa_msit_ecr_pipeline/scripts

# Project Directory
setenv MSIT_DIR ${DIR}004/users/DARPA-MSIT

# Parameters Directory
setenv PARAMS_DIR $MSIT_DIR/bsm_parameters/

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# II. Define parameters.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
set FWHM = 6 
set TR = 1.75
set fsd = msit_001
set subdir = 001
set subjs = test_001

set stim_txt_file = ______ # locate MSIT .par file and compare w/ AFNI stim files
set num_stimts = ______ # 3
set polort = ______ # A
set study = MSIT

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# III. INDIVIDUAL ANALYSES
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#set subjects = ($PARAMS_DIR/subjects_8-13-18.txt)

#foreach SUBJECT ( `cat $subjects` )
foreach SUBJECT ($subjs)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

cd $MSIT_DIR
set activeSubjectdirectory = $SUBJECT/${fsd}/${subdir}/
cd $activeSubjectdirectory
		

echo -------------------------------------------------------------------------------
echo 3dDeconvolve FCT task
echo -------------------------------------------------------------------------------

# Remove existing analyses (before proceeding)
rm ${activeSubjectdirectory}/analyze/${subdir}.LSS.xmat.1D
rm ${activeSubjectdirectory}/analyze/${subdir}.LSS.${SUBJECT}.nii
	
## Remove existing outputs of previous analyses (before proceeding)
rm censor_file

## 1dtranspose
1dtranspose ${activeSubjectdirectory}/run1/${study}.${SUBJECT}.${subdir}.run1.censor.1D > ./run1_t
1dtranspose run1_t > censor_file

## 1dMarry
1dMarry ./analyze/${SUBJECT}.rating_times.txt ./analyze/${SUBJECT}.rating_length.txt > ./analyze/${SUBJECT}.rating_time_x_length.txt

## 3dDeconvolve
3dDeconvolve \
-force_TR $TR \
-input ${activeSubjectdirectory}/run1/${study}.${SUBJECT}.${subdir}.run1.scaled.resid_UAMS_size.nii
-nfirst 0 \
-censor ${activeSubjectdirectory}/censor_file \
-polort $polort \
-num_stimts $num_stimts \
-stim_times_IM 1 ${activeSubjectdirectory}/analyze/${SUBJECT}.${stim_txt_file} "BLOCK(1,1)" \
-stim_label 1 stim_times_IM_label \
-x1D ${activeSubjectdirectory}/analyze/${subdir}.LSS.xmat.1D \
-allzero_OK \
-nobucket \
-x1D_stop

## Remove existing outputs of previous analyses (before proceeding)
rm concat_runs*

## 3dTcat
3dTcat -prefix concat_runs ${activeSubjectdirectory}/run1/${study}.${SUBJECT}.${subdir}.run1.scaled.resid_UAMS_size.nii 
				#${activeSubjectdirectory}/run2/DOP.${SUBJECT}.${subdir}.run2.scaled.resid_UAMS_size.nii
## 3dLSS
3dLSS \
-input concat_runs+tlrc \
-matrix ${activeSubjectdirectory}/analyze/${subdir}.LSS.xmat.1D \
-prefix ${activeSubjectdirectory}/analyze/${subdir}.LSS.${SUBJECT}.nii

## Remove existing outputs of previous analyses (before proceeding)
rm ${activeSubjectdirectory}/analyze/${subdir}.LSS.${SUBJECT}_despike.nii

## Despike
3dDespike \
-prefix ${activeSubjectdirectory}/analyze/${subdir}.LSS.${SUBJECT}_despike.nii \
${activeSubjectdirectory}/analyze/${subdir}.LSS.${SUBJECT}.nii


cd ${activeSubjectdirectory}

## Probably unnecessary cmd
#chmod -R -f ug+rw .

## End subject loop
end

