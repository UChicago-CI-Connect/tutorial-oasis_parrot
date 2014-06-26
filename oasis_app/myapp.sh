#!/bin/bash
source /cvmfs/oasis.opensciencegrid.org/osg/palms/setup
palmsdosetup R
Rscript ./oasis_app/test.R
echo "Finishing script at: "
echo `date`
