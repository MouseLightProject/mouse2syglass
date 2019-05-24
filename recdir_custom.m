function recdir_custom(file_list_file_name, inputfolder, file_name_pattern, target_level)
    level = 0;
    args_fid = fopen(file_list_file_name, 'wt') ;
    recdir_custom_helper(args_fid, inputfolder, file_name_pattern, target_level, level) ;
    fclose(args_fid) ;
end


function recdir_custom_helper(args_fid, inputfolder, file_name_pattern, target_level, level)
    %%
    % args.level = opt.level;
    % args.ext = opt.ext;
    % if exist(opt.seqtemp, 'file') == 2
    %     % load file directly
    % else
    %     args.fid = fopen(opt.seqtemp,'w');
    %     recdir(opt.inputfolder,args)
    % end
    % fid=fopen(opt.seqtemp,'r');
    % myfiles = textscan(fid,'%s');
    % myfiles = myfiles{1};
    % fclose(fid)

    % get sequence

    if level == target_level ,
        % Don't recurse, look for files on this level
        % search file
        % get files with argument
        matching_file_names = simple_dir(fullfile(inputfolder, file_name_pattern));
        % append to file
        for ii = 1:length(matching_file_names) ,
            fprintf(args_fid,'%s\n',fullfile(inputfolder,matching_file_names{ii}));
        end
    else
        % Recurse deeper, since we're not at the target level yet
        single_character_folder_names = list_single_character_folder_names(inputfolder) ;        
        for idx = 1:length(single_character_folder_names) ,
            single_character_folder_name = single_character_folder_names{idx} ;
            single_character_folder_path = fullfile(inputfolder, single_character_folder_name) ;
            recdir_custom_helper(args_fid, single_character_folder_path, file_name_pattern, target_level, level+1) ;
        end
        if level == 1 ,
            fprintf('Finished level %d for target level %d: %s\n', level, target_level, inputfolder) ;
        end
    end
end
