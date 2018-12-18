#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# I. Define parameters
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

set SUBJLIST = (10-12-18_subjslist_hc.txt)
set pvals = (05 01 001)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# II. Set up environment
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
source /usr/local/freesurfer/nmr-stable60-env

# Subjects Directory
setenv SUBJECTS_DIR /autofs/space/lilli_001/users/DARPA-Recons

# Project Directory
setenv MSIT_DIR /autofs/space/lilli_004/users/DARPA-MSIT

foreach PVALTHRES ($pvals)

# Directory Structure
setenv PARAMS_DIR I-C_parameters
setenv INDIV_DIR msit_I-C.analysis
setenv GROUP_DIR msit_I-C.group-analysis.$PVALTHRES

cd $MSIT_DIR

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# III. Concatenate Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


foreach CORTICES (lh rh mni305)	

isxconcat-sess \
-sf $PARAMS_DIR/$SUBJLIST \
-analysis $INDIV_DIR.$CORTICES \
-contrast I-C \
-o $GROUP_DIR.$CORTICES

end


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# IV. Group Analysis - WLS 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

## Cortical

foreach CORTICES (lh rh)

mri_glmfit \
--glmdir $GROUP_DIR.$CORTICES \
--y $GROUP_DIR.$CORTICES/$INDIV_DIR.$CORTICES/I-C/ces.nii.gz \
--wls $GROUP_DIR.$CORTICES/$INDIV_DIR.$CORTICES/I-C/cesvar.nii.gz \
--surface fsaverage $CORTICES \
--fsgd $PARAMS_DIR/msit.hc.fsgd \
--C $PARAMS_DIR/con.txt

end


## Subcortical

foreach SUBCORTICES (mni305)

mri_glmfit \
--glmdir $GROUP_DIR.$SUBCORTICES \
--y $GROUP_DIR.$SUBCORTICES/$INDIV_DIR.$SUBCORTICES/I-C/ces.nii.gz \
--wls $GROUP_DIR.$SUBCORTICES/$INDIV_DIR.$SUBCORTICES/I-C/cesvar.nii.gz \
--fsgd $PARAMS_DIR/msit.hc.fsgd \
--C $PARAMS_DIR/con.txt

end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# V. Multiple Comparisons Correction
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	

foreach CORTICES (lh rh)
 
mri_glmfit-sim \
--glmdir $GROUP_DIR.$CORTICES \
--cache 3 pos \
--cwpvalthresh .$PVALTHRES \
--3spaces

end


mri_glmfit-sim \
--glmdir $GROUP_DIR.mni305 \
--grf 3 pos \
--cwpvalthresh .$PVALTHRES \
--3spaces

end


cd /space/lilli/1/users/DARPA-Scripts/tutorials/darpa_msit_ecr_pipeline/scripts

