#!/bin/bash
source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/5.6.2/init/bash
module load R
Rscript ./oasis_app/test.R
echo "Finishing script at: "
echo `date`
