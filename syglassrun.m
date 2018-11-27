function syglassrun(samplepath,outfolder,rerun)
% inputs:
%   samplepath: name of the sample folder
%   outfolder:  target folder to create syglass files
%   rerun:      binary flag to recreate output of ls file. This will save
%               time if you want to use the result of "ls" from a previous
%               session
% example run:
%     sample = '2018-07-02-raw_new';
%     samplepath = fullfile('/nrs/mouselight/SAMPLES/',sample);
%     outfolder = fullfile(samplepath,'syglass-ch0');
%     rerun = 0;
%     syglassrun(samplepath,outfolder,rerun)

if nargin<1
    sample = '2018-08-15';
    samplepath = fullfile('/nrs/mouselight/SAMPLES/',sample);
    outfolder = fullfile(samplepath,'syglass-ch0');
    rerun = 0;
else
    [samplefolder,sample] = fileparts(samplepath);
    if nargin<3
        rerun = 1;
    end
end

if rerun;unix(sprintf('rm -rdf ./tmpfiles'));mkdir('./tmpfiles');end
if ~exist(fullfile('./tmpfiles',sample),'dir'); mkdir('./tmpfiles',sample);end

pythonpath = '/groups/mousebrainmicro/home/base/anaconda3/envs/syglass/bin/python';
scriptpath = '/groups/mousebrainmicro/mousebrainmicro/Software/syGlassConverter/singleThreadedCacher.py';

addpath(genpath('./common'))
opt = configparser(fullfile(samplepath,'/transform.txt'));
maxlevel = opt.nl-1;
clear opt
%%
for level=0:maxlevel
    mysh = sprintf('./syglassrun-%d-ch0.sh',level);
    args.level=level;
    args.ext = '0.tif';
    opt.seqtemp = fullfile('./tmpfiles',sample,sprintf('filelist-%d.txt',level));
    opt.inputfolder = samplepath;
    if exist(opt.seqtemp, 'file') == 2
        % load file directly
    else
        args.fid = fopen(opt.seqtemp,'w');
        recdir(opt.inputfolder,args)
    end
    fid=fopen(opt.seqtemp,'r');
    myfiles = textscan(fid,'%s');myfiles = myfiles{1};fclose(fid);
    
    fid = fopen(mysh,'w');
    for ii=1:length(myfiles)
        infold = [fileparts(myfiles{ii}),'/'];
        relativepath = infold(length(samplepath)+1:end);
        outfold = [fullfile(outfolder,relativepath)];
        
        if length(relativepath)>2&strcmp(relativepath(1:3),'ktx') % skip any ktx files
            continue
        end
        
        if ~exist(outfold,'dir')
            mkdir(outfold)
            unix(sprintf('chmod g+rwx %s',outfold));
        end
        myarg = sprintf('bsub -n1 -We 1 -J t-%d-%05d -o /dev/null ''%s %s %s %s''\n',level,ii,pythonpath,scriptpath,infold,outfold);
        fwrite(fid,myarg);
    end
    fclose(fid);
    unix(sprintf('chmod g+rwx %s',mysh));
end

