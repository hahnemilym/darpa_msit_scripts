#! /bin/csh -f

##----------------------------------##
## Configure parameters
##----------------------------------##

setenv subjid `cat subjidall.txt` 

setenv SUBJECTS_DIR /autofs/space/lilli_004/users/DARPA-MSIT;

set hemi = ('lh','rh')
set region = 'dACC'
set fsd= 'msit_001'
set indiv_analysis_dir = 'beta_dir'
set contrast = 'I-C'
set fsaverage = 'fsaverage1'

##----------------------------------##
## Loop through labels and subjects
##----------------------------------##

foreach h ($hemi)

setenv labels `cat labels_$hemi.txt`
labels = cat `labels_$h.txt` 

foreach l ($labels)

##----------------------------------##
## Convert label to *.mgh file
##----------------------------------##
		
mri_label2label \
--s $fsaverage1 \
--regmethod surface \
--hemi $h \
--srclabel $l \
--trglabel $SUBJECTS_DIR/${fsaverage}/label/junk.label \
--outmask $SUBJECTS_DIR/${fsaverage}/label/$l.mgh

##----------------------------------##
## Smooth label (necessary, albeit 
## 2mm negligible in FS space)
##----------------------------------##
mris_fwhm \
--i $SUBJECTS_DIR/${fsaverage}/label/$l.mgh \
--fwhm 2 \
--smooth-only \
--o $SUBJECTS_DIR/${fsaverage}/label/$l.smooth.mgh \
--s fsaverage1 \
--hemi $h

##----------------------------------##
## Binarize label mask (not automatic)
##----------------------------------##
mri_binarize \
--i $SUBJECTS_DIR/${fsaverage}/label/$l.smooth.mgh \
--o $SUBJECTS_DIR/${fsaverage}/label/$l.smooth.b.mgh \
--min 10e-10

##----------------------------------##
## Extract betas
## - output from --avgwf flag file 
## contains all all subjects' beta 
## values in order of subjidall.txt
##----------------------------------##
mri_segstats \
--i second_level/${region}.surf.$h/${region}_surf/ces.nii.gz \
--ctab $FREESURFER_HOME/FreeSurferColorLUT.txt \
--avgwf ${h}_avgwf_$l.dat \
--seg $SUBJECTS_DIR/${fsaverage}/label/$l.smooth.b.mgh \
--excludeid 0

## End hemi loop
end 

## End labels loop
end

