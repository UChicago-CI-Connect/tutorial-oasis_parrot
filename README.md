Software access using OASIS and Parrot
======================================

Overview
--------
This module will introduce users to the tools needed to access software installed on OASIS using Parrot and SkeletonKey.  Parrot is a tool that allows your application to access OASIS on sites that don't have it installed.  Although an increasing number of sites support OASIS on their compute nodes, there are sites that don't.  This module will show users how to run opportunistic jobs that use OASIS on those other sites.
Preliminaries
-------------
Before going through the examples, login to login01.osgconnect.net and get a copy of the tutorial files:
```
$ ssh login01.osgconnect.net
$ tutorial oasis_parrot
$ cd osg-oasis_parrot
```
Remote software access
----------------------
#### Simplify software access with SkeletonKey

Due to the complexities involved in setting up Parrot to provide access to OASIS, users should use SkeletonKey to simplify the process involved.  SkeletonKey is a tool that
##### Creating the application tarball

Since we'll be running an application from OASIS, we'll create an application tarball to do some initial setup and then run the actual application

Create a directory for the script:
```
% mkdir -p oasis_app
% cd oasis_app
```
Create a shell script, ~/osg-oasis_parrot/oasis_app/myapp.sh, with the following lines.  One thing to note: using OASIS through Parrot works the same way as using it on sites that have it available normally. The script myapp.sh:
```
#!/bin/bash
source /cvmfs/oasis.opensciencegrid.org/osg/palms/setup
palmsdosetup R
Rscript ./oasis_app/test.R
echo "Finishing script at: "
echo `date`
```
Create a R script ~/oasis_parrot/app/test.R with the following lines:
```R
hilbert<-function(n) 1/(outer(seq(n) ,seq(n) ,"+")-1)
print("hilbert n=500")
print(system.time(eigen(hilbert(500))))
print("hilbert n=1000")
print(system.time(eigen(hilbert(1000))))
print("sort n=6")
print(system.time(sort(rnorm(10^6))))
print("sort n=7")
print(system.time(sort(rnorm(10^7))))
# loess
loess.me<-function(n) {
print(paste("loess n=",as.character(n) ,sep=""))
for (i in 1:5) {
 x<-rnorm(10^n); y<-rnorm(10^n); z<-rnorm(10^n)
 print(system.time(loess(z~x+y)))
 }
}
loess.me(3)
loess.me(4)
```
Next, make sure the myapp.sh script is executable and create a tarball:
```
$ chmod 755 ~/osg-oasis_parrot/oasis_app/myapp.sh
$ cd ~/osg-oasis_parrot/
$ tar cvzf oasis_app.tar.gz oasis_app
```
Then copy the tarball to your public directory
```
$ cp oasis_app.tar.gz ~/data/public/
$ chmod 644 ~/data/public/oasis_app.tar.gz
```
#### Creating a job wrapper

You'll need to do the following on the machine where you installed SkeletonKey.
Open a file called ~/oasis_parrot/oasis.ini and replace username with your username:
```
[Application]
location = http://stash.osgconnect.net/+username/oasis_app.tar.gz
script = ./oasis_app/myapp.sh
```
Run SkeletonKey on oasis.ini:
```
$ skeleton_key -c oasis.ini
```
This generates a wrapper called run_job.py that you'll be using. Run the job wrapper to verify that it's working correctly
```
$ python run_job.py
```
#### Using the job wrapper
##### Submitting jobs to OSG connect

The following part of the tutorial is optional and will cover using a generated job wrapper in a HTCondor submit file. Create a file called ~/osg-oasis_parrot/oasis.submit with the following contents:
```
universe = vanilla
notification=never
executable = run_job.py
output = logs/oasis.$(Process).out
error = logs/oasis.$(Process).err
log = logs/oasis.log
ShouldTransferFiles = YES
when_to_transfer_output = ON_EXIT
Requirements = HAS_CVMFS_oasis_opensciencegrid_org =?= TRUE
 
queue 50
```
Finally submit the job to HTCondor and verify that the jobs ran successfully.
```
$ condor_submit oasis.submit
$ cat logs/oasis.0.out
[1] "hilbert n=500"
   user  system elapsed
  0.509   0.015   0.554
[1] "hilbert n=1000"
   user  system elapsed
  4.244   0.035   4.279
[1] "sort n=6"
   user  system elapsed
  0.456   0.003   0.460
[1] "sort n=7"
   user  system elapsed
  5.788   0.070   5.859
[1] "loess n=3"
   user  system elapsed
  0.091   0.000   0.091
   user  system elapsed
  0.085   0.000   0.085
   user  system elapsed
  0.085   0.000   0.085
   user  system elapsed
  0.085   0.000   0.085
   user  system elapsed
  0.086   0.000   0.086
[1] "loess n=4"
   user  system elapsed
  8.260   0.004   8.266
   user  system elapsed
  8.312   0.000   8.313
   user  system elapsed
  8.364   0.000   8.366
   user  system elapsed
  8.222   0.000   8.224
   user  system elapsed
  8.328   0.000   8.329
Finishing script at:
Tue Aug 27 11:40:12 CDT 2013
```
