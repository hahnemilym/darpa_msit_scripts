#! /bin/csh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Configure environment
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Local Directory
setenv DIR /autofs/space/lilli_

# Subjects Directory
setenv SUBJECTS_DIR ${DIR}001/users/DARPA-Recons

# Project Directory
setenv MSIT_DIR ${DIR}004/users/DARPA-MSIT

# Parameters Directory
setenv PARAMS_DIR $MSIT_DIR/bsm_parameters/

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Define parameters
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

set FWHM = 6 
set TR = 1.75
set slices = 63
set slice_pattern =  ${DIR}_001/users/DARPA-Scripts/tutorials/darpa_pipelines_EH/darpa_msit_scripts/slice_timing.txt
# previously 'seq+z'. Here, interleaved and odd.. possibly 'alt+z2' ?

set num_stimts = 28 # number of regressors (e.g. wm, csf, motion)
set polort = A 
# A = automatically choose polynomial detrending value based on 
# the time duration D of the longest run: pnum = 1 + int(D/150)

set study = msit
set task = (${study}_bsm)

set do_anat = 'yes'
set do_epi = 'no'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Initialize subject(s) environment
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#set subjects = ($PARAMS_DIR/subjects_8-13-18.txt)
#foreach SUBJECT ( `cat $subjects` )

set subjs = (test_001)

foreach subj (${subjs})

cd $MSIT_DIR/${subj}/${task}
set activeSubjectdirectory = `pwd`

#rm -r anat;
#rm -r func;
#mkdir anat;
#mkdir func;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Anatomical preprocessing
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

if ( ${do_anat} == 'yes' ) then
	
	cd $activeSubjectdirectory/anat

	echo "****************************************************************"
	echo " skull striping for ${subj}"
	echo "****************************************************************"	

	#rm ${study}.${subj}.anat.sksp+orig*
	
	3dSkullStrip \
	-input ${study}.${subj}.anat.nii \
	-prefix ${study}.${subj}.anat.sksp \
	-orig_vol \
	-niter 300

endif

#end loop: subjs
end

cd ${DIR}001/users/DARPA-Scripts/tutorials/darpa_pipelines_EH/darpa_msit_scripts

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

