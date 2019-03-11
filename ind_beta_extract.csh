#! /bin/csh -f

##----------------------------------##
## PRIOR to running this script:
## - rerun_betas.csh MUST be run 
## (specifically b/c smooth and binarized 
## region mask needs to be generated)
##----------------------------------##

##----------------------------------##
## AFTER running this script: 
## - run 'Beta_spreadsheet.ipynb'
## - This jupyter notebook reads each 
## of the files generated from this 
## script and adds to an xls sheet 
##----------------------------------##

##----------------------------------##
## Configure parameters
##----------------------------------##

setenv subjid `cat subjidall.txt`
setenv labels `cat labels_$hemi.txt` 

setenv SUBJECTS_DIR /autofs/space/lilli_004/users/DARPA-MSIT

set hemi = 'lh'
set region = 'dACC'
set fsd= 'msit_001'
set indiv_analysis_dir = 'beta_dir'
set contrast = 'I-C'
set fsaverage = 'fsaverage1'

##----------------------------------##
## Loop through labels and subjects
##----------------------------------##

foreach label ($labels)

foreach subj ($subjid)

mkdir $indiv_analysis_dir;

cd $MSIT_DIR/${subject}/${indiv_analysis_dir}.${hemi}/${contrast};

mri_segstats \
--i ces.nii.gz \
--ctab $FREESURFER_HOME/FreeSurferColorLUT.txt \
--avgwf ${hemi}_avgwf_$label.dat \
--seg $SUBJECTS_DIR/$fsaverage/labels/${label}.smooth.b.mgh \
--excludeid 0 

# Following command returns one file per subject, per region, w/ 1 number (subject's beta extraction for that region)

cp ${hemi}_avgwf_${label}.dat ../../../../${indiv_analysis_dir}/${subj}_${hemi}_avgwf_${label}.dat;

cd ${MSIT_DIR};

# End labels loop
end

# End subjects loop
end

