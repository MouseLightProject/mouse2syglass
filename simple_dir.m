function file_names = simple_dir(folder_name)
    % Does what I wish dir() did: just return a cell array of the directory
    % entries, without all the other stuff.
    s = dir(folder_name) ;
    file_names = {s.name} ;
end
