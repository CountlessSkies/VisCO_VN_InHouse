/*
Error check functions will return either true or false.
A false return will be used in the interface to halt the script.
*/

(--START script

	struct Error_Check
	(
		saveState,
		savePath,
		originals_set,
		search_set,
		
		chkBox_same_name,
		chkBox_same_meshClass,
		chkBox_same_materialName,
		chkBox_same_position,
		chkBox_same_modifier,
		chkBox_same_size,
		chkBox_same_verticesCount,
		chkBox_same_faceCount,
		chkBox_same_smoothingGroups,
		chkBox_same_faceNormals,
		chkBox_same_verticesPositions,
		
		
		---------------------------------------------------------------------------------------------------------------------------
		--Check if the save path is valid:
		fn SavePath_Valid =
		(
			valid_savePath = true --variable that indicates wether the save path is valid or not (true is valid)
			
			if (saveState == 2 or saveState == 3) and ((dotnetclass "System.IO.Directory").exists (getFilenamePath(savePath))) == False do valid_savePath = false
			
			--Message the user if the save path is not valid:
			if valid_savePath == false do MessageBox "Not a valid save path"
			
			--Return either true or false as a value in valid_savePath:
			return valid_savePath
		),--END SavePath_Valid
		
		---------------------------------------------------------------------------------------------------------------------------
		--Check that the user has filled originals set and search set:
		fn Objects_Collected =
		(
			collections_filled = true
			
			if originals_set.count == 0 or search_set.count == 0 do collections_filled = false
				
			if collections_filled == false do MessageBox "Originals and\or search set does not contain any objects"
				
			return collections_filled
		),
		
		
		---------------------------------------------------------------------------------------------------------------------------
		--Check that all objects in originals_set and search_set exist: (the user might delete something before pressing execute)
		fn Check_Objects_Exist = 
		(
			all_objects_exist = true
			
			for arr in #(originals_set, search_set) do for obj in arr where (isDeleted obj) do all_objects_exist = false
			
			--Message the user if the save path is not valid:
			if all_objects_exist == false do MessageBox "Objects in originals set or search set has been deleted. Please update the sets"
			
			return all_objects_exist
		),
		
		---------------------------------------------------------------------------------------------------------------------------
		--Check that at least one search parameter is checked: (Otherwise all objects will be marked as a copy)
		fn Min_One_SearchParam =
		(
			checked = false
			
			if chkBox_same_name do checked = true
			if chkBox_same_meshClass do checked = true
			if chkBox_same_materialName do checked = true
			if chkBox_same_position do checked = true
			if chkBox_same_modifier do checked = true
			if chkBox_same_size do checked = true
			if chkBox_same_verticesCount do checked = true
			if chkBox_same_faceCount do checked = true
			if chkBox_same_smoothingGroups do checked = true
			if chkBox_same_faceNormals do checked = true
			if chkBox_same_verticesPositions do checked = true
				
			if checked == false do MessageBox "Choose at least one search parameter"
				
			return checked
		)
			
		---------------------------------------------------------------------------------------------------------------------------
		
		
	)--END struct Error_Check
	
	
	
	
	
)--END script