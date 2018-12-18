#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# II. Set up environment
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
# I. Define parameters.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
set FWHM = 6 
set TR = 1.75
set FD = (1.0)
set fsd = msit_001
set subdir = 001
#set subjects = ($PARAMS_DIR/subjects_8-13-18.txt)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# III. INDIVIDUAL ANALYSES
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

cd $MSIT_DIR

#foreach SUBJECT ( `cat $subjects` )

foreach SUBJECT (hc001)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# IV. Create paradigm file
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


cp $MSIT_DIR/bsm_parameters/msit_bsm.par \
$MSIT_DIR/$SUBJECT/$fsd/$subdir/msit_bsm.par


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# V. Configure analyses 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

foreach cortices ( lh rh )

mkanalysis-sess \
-fsd $fsd \
-surface fsaverage $cortices \
-fwhm $FWHM \
-event-related \
-paradigm msit_bsm.par \
-nconditions 194 \
-spmhrf 0 \
-TR $TR \
-refeventdur 1.75 \
-nskip 4 \
-hpf 0.02 \
-analysis bsm.analyses.$cortices \
-per-run \
-nuisreg I-C.mc.par -1 \
#-tpexclude I-C.censor.$FD.par \
-force

end


foreach subcortices ( mni305 )

mkanalysis-sess \
-fsd $fsd \
-$subcortices 2 \
-fwhm $FWHM \
-event-related \
-paradigm msit_bsm.par \
-nconditions 194 \
-spmhrf 0 \
-TR $TR \
-refeventdur 1.75 \
-nskip 4 \
-hpf 0.02  \
-analysis bsm.analyses.$subcortices \
-per-run \
-nuisreg I-C.mc.par -1 \
#-tpexclude I-C.censor.$FD.par \
-force

end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# VI. Specify contrasts 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#foreach cortices (lh rh mni305)

#mkcontrast-sess \
#-analysis msit_bsm.analysis/msit_bsm.analysis.$cortices \
#-contrast I-C \
#-a 2 \
#-c 1 \
#-overwrite

#end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# VII. Run analysis
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

foreach cortices (lh rh mni305)

selxavg3-sess \
-s $SUBJECT \
-analysis bsm.analyses.$cortices \
-no-con-ok

end

# end subjects loop
end


cd $ANALYSES_DIR

