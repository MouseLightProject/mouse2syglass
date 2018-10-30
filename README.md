# mouse2syglass
Converts mouselight octree format to syglass tif. python script and python path is hard coded in https://github.com/erhanbas/mouse2syglass/blob/e93734fe55e6104465d8f6faf152086c5809516e/syglassrun.m#L30

i.e.:  
pythonpath = '/groups/mousebrainmicro/home/base/anaconda3/envs/syglass/bin/python';  
scriptpath = '/groups/mousebrainmicro/mousebrainmicro/Software/syGlassConverter/singleThreadedCacher.py';


### usage:
```
syglassrun(samplepath,outfolder,rerun)
samplepath: name of the sample folder
outfolder:  target folder to create syglass files
rerun:      binary flag to recreate output of ls file. This will save
            time if you want to use the result of "ls" from a previous
            session
```              
### example run:
    sample = '2018-07-02-raw_new';
    samplepath = fullfile('/nrs/mouselight/SAMPLES/',sample);
    outfolder = fullfile(samplepath,'syglass-ch0');
    rerun = 0;
    syglassrun(samplepath,outfolder,rerun)
