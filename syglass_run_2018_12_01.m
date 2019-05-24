function syglass_run_2018_12_01()    
    sample = '2018-12-01';
    samplepath = fullfile('/nrs/mouselight/SAMPLES/',sample);
    outfolder = fullfile(samplepath,'syglass-ch0');
    rerun = 0;
    syglassrun(samplepath,outfolder,rerun) ;
end
