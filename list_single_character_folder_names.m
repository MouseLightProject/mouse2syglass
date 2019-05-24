function result = list_single_character_folder_names(folder_name)
    folder_names = list_folder_names(folder_name) ;
    is_folder_name_of_length_one = cellfun(@is_of_length_one, folder_names) ;    
    result = folder_names(is_folder_name_of_length_one) ;
end

function result = is_of_length_one(str)
    result = ( length(str) == 1 ) ;
end
