/*
The struct "Find Identicals" contains functions that will sort objects into main_objects (designated orignals) and copies of main objects.

*/

(--START script
	
	
	--Get Find_Identicals struct from find_identicals.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "tests.ms" --Combines directory and filename to create a path
	file_tests = fileIn path_script
	
	
	

	struct Find_Identicals
	(
		--The two sets of objects that the user selected in the interface: (They can contain the same objects)
		originals_set,
		search_set,
		
		
		main_objects = #(),
		copies_lists = #(),
		/*
		main_objects are the designated originals, while copies_lists contains a list per main object with all its copies
		Every main object should have a list of copies at the same index location in the copies array, even if the list is empty (no copies)
		*/
		
		
		fn Sort_Objects \ --
		chkBox_same_name chkBox_same_meshClass chkBox_same_materialName chkBox_same_position chkBox_same_modifier \
		chkBox_same_size chkBox_same_verticesCount chkBox_same_faceCount chkBox_same_smoothingGroups chkBox_same_faceNormals chkBox_same_verticesPositions \
		spn_tolerance =
		(
			my_file_tests = file_tests()
			--All tests are stored in a separate struct called tests
			
			
			for original_obj in originals_set do
			(
				--Original_obj is marked as a copy if its found in copies_lists. It will only be put in main_objects array if original_obj_is_a_copy is false:
				original_obj_is_a_copy = false
				for copies in copies_lists where (findItem copies original_obj) != 0 do original_obj_is_a_copy = true
				
				
				if original_obj_is_a_copy == false do
				(
					append main_objects original_obj
					copies = #() --An array that will contain all copies of original_obj. It should be at the same index position as original_obj in main_objects
					append copies_lists copies
					
					for potential_copy in search_set do
					(
						is_copy = true
						 --Indicates wether the potential copy is a copy
						
						if is_copy and potential_copy == original_obj do is_copy = false
						--If the object is the original object, it should not be marked as a copy
						
						
						if is_copy and (findItem main_objects potential_copy) != 0 do is_copy = false
						--If the object is in the main_objects list, it has already been checked against all the other objects
						
						
						if is_copy do for copies_list in copies_lists where (findItem copies_list potential_copy) != 0 do is_copy = false
						--If the object is marked as a copy from before, dont do it again
						
						
						--Go through all the enabled tests to see if the potential copy is really identical or not:
						if is_copy and chkBox_same_name and (my_file_tests.Same_Name original_obj potential_copy) != true do is_copy = false
						if is_copy and chkBox_same_meshClass and (my_file_tests.Same_Mesh_Class original_obj potential_copy) != true do is_copy = false
						if is_copy and chkBox_same_materialName and (my_file_tests.Same_MaterialName original_obj potential_copy) != true do is_copy = false
						if is_copy and chkBox_same_position and (my_file_tests.Same_Pos original_obj potential_copy spn_tolerance) != true do is_copy = false
						if is_copy and chkBox_same_modifier and (my_file_tests.Same_Modifier original_obj potential_copy) != true do is_copy = false
						if is_copy and chkBox_same_size and (my_file_tests.Same_Size original_obj potential_copy spn_tolerance) != true do is_copy = false
						if is_copy and chkBox_same_verticesCount and (my_file_tests.Same_verticesCount original_obj potential_copy) != true do is_copy = false
						if is_copy and chkBox_same_faceCount and (my_file_tests.Same_faceCount original_obj potential_copy) != true do is_copy = false
						if is_copy and chkBox_same_verticesPositions and (my_file_tests.Same_VerticesPositions original_obj potential_copy spn_tolerance) != true do is_copy = false
						if is_copy and chkBox_same_smoothingGroups and (my_file_tests.Same_SmoothingGroups original_obj potential_copy) != true do is_copy = false
						if is_copy and chkBox_same_faceNormals and (my_file_tests.Same_FaceNormals original_obj potential_copy) != true do is_copy = false
						
						
						if is_copy do append copies potential_copy
						--If the object is marked as a copy after all tests, its appended to the original objects list of copies
					)
				)
			)
		)
		
		
		
		
		
		
		
		
		
	)--END struct Find_Identicals
	
	
	
	
	
)--END script