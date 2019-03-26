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


setenv subjid `cat /autofs/space/lilli_004/users/DARPA-MSIT/Analyses_I-C/I-C_parameters/10-12-18_subjslist.txt` 

setenv SUBJECTS_DIR /autofs/space/lilli_001/users/DARPA-Recons;
setenv ANALYSIS_DIR /autofs/space/lilli_004/users/DARPA-MSIT;
setenv MSIT_DIR /autofs/space/lilli_001/users/DARPA-Scripts/tutorials/darpa_pipelines_EH/darpa_msit_scripts;

setenv sig_file cache.th30.pos.sig.cluster.mgh

setenv fsd msit_001
setenv indiv_analysis_dir msit_I-C.analysis
setenv contrast I-C

setenv hemi rh

#setenv group_analysis msit_I-C.group-analysis
setenv group_analysis msit_I-C.group-analysis.pts

##----------------------------------##
## Loop through labels and subjects
##----------------------------------##

foreach subject ($subjid)
#foreach subject (hc001)

echo "*********************************"
echo " Loop through labels"
echo "*********************************"
#setenv labels `cat labels_$hemi.txt`
#labels = cat `labels_$hemi.txt`

## For rh ONLY, HCs
#foreach label (dlPFC)

## For both lh rh, HCs
#foreach label (dACC)

## for rh ONLY, PTs
foreach label (InfParietal SupParietal)

echo "*********************************"

cd $ANALYSIS_DIR/${subject}/msit_001/${indiv_analysis_dir}.${hemi}/${contrast};

mri_segstats \
--i ces.nii.gz \
--ctab $FREESURFER_HOME/FreeSurferColorLUT.txt \
--avgwf ${subject}_${hemi}_avgwf_${label}.dat \
--seg $ANALYSIS_DIR/Analyses_I-C/${group_analysis}.01.$hemi/con.txt/fsaverage_temp.${hemi}_${label}_mask_2fwhm_binary.mgh \
--excludeid 0

# Following command returns one file per subject, per region, w/ 1 number (subject's beta extraction for that region)

cp ${subject}_${hemi}_avgwf_${label}.dat ${ANALYSIS_DIR}/${group_analysis}.${hemi};

cd $MSIT_DIR;

# End labels loop
end

# End subjects loop
end

