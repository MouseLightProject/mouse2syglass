function folder_names = list_folder_names(folder_name)
    s = dir(folder_name) ;
    entity_names = {s.name} ;
    is_folder = [s.isdir] ;
    raw_folder_names = entity_names(is_folder) ;
    folder_names = setdiff(raw_folder_names, {'.' '..'}) ;  % delete stupid . and .. entries
end
