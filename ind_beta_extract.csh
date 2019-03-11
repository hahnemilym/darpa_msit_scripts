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

setenv SUBJECTS_DIR /autofs/space/lilli_001/users/DARPA-Recons;
setenv ANALYSIS_DIR /autofs/space/lilli_004/users/DARPA-MSIT;

set pval = '05'
set group = 'hc'
set hemi = 'lh'
set sig_file 'cache.th30.pos.sig.cluster.mgh'

set group_analysis = 'msit_I-C.group-analysis'

set hemi = ('lh','rh')
set fsd= 'msit_001'
set indiv_analysis_dir = 'msit_I-C.analysis'
set contrast = 'I-C'

##----------------------------------##
## Loop through labels and subjects
##----------------------------------##

foreach subject ($subjid)

foreach label ($labels)

cd $MSIT_DIR/${subject}/${indiv_analysis_dir}.${hemi}/${contrast};

mri_segstats \
--i ces.nii.gz \
--ctab $FREESURFER_HOME/FreeSurferColorLUT.txt \
--avgwf ${subject}_${hemi}_avgwf_${label}.dat \
--seg $ANALYSIS_DIR/Analyses_I-C/$sig_file.$pval.$hemi/con.txt/${label}_${hemi}_${fwhm}.fwhm_binary.mgh \
--excludeid 0 

# Following command returns one file per subject, per region, w/ 1 number (subject's beta extraction for that region)

cp ${subj}_${hemi}_avgwf_${label}.dat ${ANALYSIS_DIR}/${group_analysis}.{$hemi};

cd ${MSIT_DIR};

# End labels loop
end

# End subjects loop
end

