function syglass_run_2018_07_02_again()    
    sample = '2018-07-02-raw_new';
    samplepath = fullfile('/nrs/mouselight/SAMPLES/',sample);
    outfolder = fullfile(samplepath,'syglass-ch0-again');
    rerun = 0;
    syglassrun(samplepath,outfolder,rerun) ;
end
