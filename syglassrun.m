function syglassrun(sample_path, output_folder, do_rerun, do_use_cluster)
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

    % if nargin<1
    %     sample = '2018-08-15';
    %     samplepath = fullfile('/nrs/mouselight/SAMPLES/',sample);
    %     outfolder = fullfile(samplepath,'syglass-ch0');
    %     rerun = 0;
    % else
    
    if ~exist('do_rerun', 'var') || isempty(do_rerun) ,
        do_rerun = true ;
    end
    if ~exist('do_use_cluster', 'var') || isempty(do_use_cluster) ,
        do_use_cluster = true ;
    end        

    [~, sample_name] = fileparts(sample_path) ;
    if do_rerun ,
        unix(sprintf('rm -rdf ./tmpfiles'));
        mkdir('./tmpfiles');
    end
    if ~exist(fullfile('./tmpfiles',sample_name),'dir'),
        mkdir('./tmpfiles',sample_name);
    end

    this_file_path = mfilename('fullpath') ;
    this_folder_path = fileparts(this_file_path) ;    
    python_path = fullfile(this_folder_path, 'anaconda3/envs/syglass/bin/python2') ;
    script_path = fullfile(this_folder_path, 'singleThreadedCacher.py') ;

    %addpath(genpath('./common'))
    opt = configparser(fullfile(sample_path,'/transform.txt'));
    maxlevel = opt.nl-1 ;
    %maxlevel = 3 ;
    maxlevel
    %clear opt
    for level=0:maxlevel
        mysh = sprintf('./syglassrun-%d-ch0.sh',level);
        file_list_file_name = fullfile('./tmpfiles', sample_name, sprintf('filelist-%d.txt',level));
        inputfolder = sample_path;
        if ~exist(file_list_file_name, 'file') ,
            recdir_custom(file_list_file_name, inputfolder, '*.0.tif', level) ;
        end
        file_list_fid=fopen(file_list_file_name,'r');
        myfiles = textscan(file_list_fid,'%s');
        myfiles = myfiles{1};
        fclose(file_list_fid);

        bash_script_fid = fopen(mysh,'w');
        for ii=1:length(myfiles)
            infold = [fileparts(myfiles{ii}),'/'];
            relativepath = infold(length(sample_path)+1:end);
            outfold = fullfile(output_folder,relativepath) ;

            if length(relativepath)>2 && strcmp(relativepath(1:3),'ktx') % skip any ktx files
                continue
            end

            if ~exist(outfold,'dir')
                mkdir(outfold)
                unix(sprintf('chmod g+rwx %s',outfold));
            end
            myarg = sprintf('bsub -P mouselight -n1 -We 1 -J t-%d-%05d -o /dev/null ''%s %s %s %s''\n',level,ii,python_path,script_path,infold,outfold);
            fwrite(bash_script_fid,myarg);
        end
        fclose(bash_script_fid);
        unix(sprintf('chmod g+rwx %s',mysh));
    end
end
