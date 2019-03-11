#! /bin/csh -f

##----------------------------------##
## Configure parameters
##----------------------------------##

setenv SUBJECTS_DIR /autofs/space/lilli_001/users/DARPA-Recons;
setenv ANALYSIS_DIR /autofs/space/lilli_004/users/DARPA-MSIT;
setenv SCRIPTS_DIR /autofs/space/lilli_001/users/DARPA-Scripts/tutorials/darpa_pipelines_EH/darpa_msit_scripts;
setenv A_DIR $ANALYSIS_DIR/Analyses_I-C/${group_analysis}.05.$hemi/con.txt

setenv group 'hc'
setenv sig_file 'cache.th30.pos.sig.cluster.mgh'

setenv group_analysis 'msit_I-C.group-analysis'

setenv hemisphere 'lh'
setenv fsd 'msit_001'
setenv contrast 'I-C'

##----------------------------------##
## Cluster specification (OPTIONAL)
##----------------------------------##

#mri_surfcluster \
#--in $group_analysis.05.$space \
#--hemi lh \
#--surf fsaverage \
#--thmin 1.5 \
#--thmax 10 \

echo "*********************************"
echo "Loop through hemispheres"
echo "*********************************"

foreach hemi ($hemisphere)

echo "*********************************"
echo "Set labels list"
echo "*********************************"

#setenv labels `cat labels_$hemi.txt`
#labels = cat `labels_$hemi.txt`

setenv subject fsaverage_temp

setenv labels_list dACC

echo "*********************************"
echo "Loop through labels"
echo "*********************************"

foreach label ($labels_list)

echo "*********************************"
echo "Convert label to *.mgh file"
echo "*********************************"
		
mri_label2label \
--s fsaverage \
--regmethod surface \
--hemi $hemi \
--srclabel $A_DIR/${label}_${hemi}.label \
--trglabel $A_DIR/${subject}.${label}_${hemi}.label \
--outmask $A_DIR/${subject}.${label}_${hemi}_mask.mgh

echo "*********************************"
echo "Smooth label (necessary, albeit"
echo "2mm negligible in FS space)"
echo "*********************************"

mris_fwhm \
--i $A_DIR/${subject}.${label}_${hemi}_mask.mgh \
--fwhm 2 \
--smooth-only \
--o $A_DIR/${subject}.${label}_${hemi}_mask_2fwhm.mgh \
--s fsaverage \
--hemi $hemi

echo "*********************************"
echo "Binarize label mask (not automatic)"
echo "*********************************"

mri_binarize \
--i $A_DIR/${subject}.${label}_${hemi}_mask_2fwhm.mgh \
--o $A_DIR/${subject}.${label}_${hemi}_mask_2fwhm_binary.mgh \
--min 10e-10

echo "*********************************"
echo "Extract betas"
echo "Output from --avgwf output contains"
echo "all subjects' beta values (in order" 
echo "of subjidall.txt)"
echo "*********************************"

mri_segstats \
--i $A_DIR/${sig_file} \
--ctab $FREESURFER_HOME/FreeSurferColorLUT.txt \
--avgwf $A_DIR/${hemi}_avgwf_$label.dat \
--seg $A_DIR/${subject}.${label}_${hemi}_mask_2fwhm_binary.mgh \
--excludeid 0

#tksurfer fsaverage lh inflated -annot cache.th30.pos.sig.ocn.annot -overlay cache.th30.pos.sig.ocn.mgh

cd $SCRIPTS_DIR

## End hemi loop
end 

## End labels loop
end

