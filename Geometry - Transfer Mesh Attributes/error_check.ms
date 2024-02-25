/*
Error check functions will return either true or false.
A false return will be used in the interface to halt the script.
*/

(--START script

	struct Error_Check
	(
		from_objects,
		to_objects,
		saveState,
		savePath,
		opType,
		
		
		
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
		
		
		
		--Check that no objects within the same set has identical names:
		fn No_Identical_Names =
		(
			no_names_identical = true--variable that indicates wether there are identical named objects in the same set or not.
			
			multiple_names = #() --Contains names that occur more than one time
			
			for the_collection in #(from_objects, to_objects) do
			(
				for obj_1 in the_collection do
				(
					for obj_2 in the_collection where obj_1 != obj_2 and obj_1.name == obj_2.name do 
					(
						appendIfUnique multiple_names obj_1.name
						no_names_identical = false
					)
				)
			)
			
			--Message the user:
			for the_name in multiple_names do print (the_name + " occurs several times within the same transfer collection")
			if no_names_identical == false do MessageBox "Objects with identical names exists within a transfer collection. See listener (F11) for more info"
			
			--Return either true or false as a value in no_names_identical:
			return no_names_identical
		),--END No_Identical_Names
		
		
		
		--Check that no object is in both object sets (from_objects and to_objects):
		fn Overlapping_ObjSets =
		(
			no_overlaps = true --If an object is in both from_objects and to_objects, this variable will be set to false
			
			--Check that no object in from_objects exists in to_objects:
			for from_object in from_objects do if (findItem to_objects from_object) != 0 do 
			(
				print (from_object.name + " exists in both object sets")
				no_overlaps = false
			)
			
			--Message the user if the save path is not valid:
			if no_overlaps == false do MessageBox "Objects exist in both transfer sets. See listener (F11) for more info"
			
			--Return either true or false as a value in no_overlaps:
			return no_overlaps
		),--END Overlapping_ObjSets
		
		
		
		--Check that all object names are in both from_objects and to_objects:
		fn All_Names_In_Sets =
		(
			all_names_has_a_twin = true
			
			from_objects_names = #()
			to_objects_names = #()
			
			for from_object in from_objects do append from_objects_names from_object.name
			for to_object in to_objects do append to_objects_names to_object.name
				
			for the_name in from_objects_names do
			(
				if (findItem to_objects_names the_name) == 0 do 
				(
					print (the_name + " in Transfer From does not exist in Transfer To")
					all_names_has_a_twin = false
				)
			)
			
			for the_name in to_objects_names do
			(
				if (findItem from_objects_names the_name) == 0 do
				(
					print (the_name + " in Transfer To does not exist in Transfer From")
					all_names_has_a_twin = false
				)
			)
			
			--Message the user if not all names are in both sets:
			if all_names_has_a_twin == false do MessageBox "Not all object names are in both Transfer From and Transfer To. See listener (F11) for more details"
			
			--Return either true or false as a value in all_names_has_a_twin:
			return all_names_has_a_twin
		),--END All_Names_In_Sets
		
		
		
		
		--Check if its the same number of objects in both from_objects and to_objects:
		fn Count_Objects =
		(
			same_count = true --Variable that indicates wether both from_objects and to_objects has the same object count
			
			if from_objects.count != to_objects.count do same_count = false
				
			if same_count  == false do MessageBox "Transfer from and Transfer to does not contain the same number of objects"
				
			return same_count
		),--END Count_Objects
		
		
		
		
		--Check that objects with same name is of the same mesh type (poly or mesh)
		fn Same_Mesh_Class =
		(
			mesh_class_same = true --Variable that indicates wether objects with same name has the same base mesh class
			
			if opType == 1 or opType == 2 do
			(
				--Check if similar named objects in from_objects has the same base mesh class as the objects in to_objects:
				for from_object in from_objects do
				(
					from_object_base = from_object.baseObject
					from_object_class = classOf from_object_base
					
					for to_object in to_objects where from_object.name == to_object.name do
					(
						to_object_base = to_object.baseObject
						to_object_class = classOf to_object_base
						
						if from_object_class != to_object_class do
						(
							print (from_object.name + " in Transfer From is not of the same mesh class as the same object name in Transfer To")
							mesh_class_same = false
						)
					)
				)
			)--END if opType == 1 or opType == 2 do
			
			
			
			--Message the user if the base mesh classes are not the same:
			if mesh_class_same == false do MessageBox "Mesh classes are not identical. See listener (F11) for more details"
				
			return mesh_class_same
		),--END Same_Mesh_Class
		
		
		
		
		--Check that objects with same name has the same face count:
		fn Same_Face_Count =
		(
			face_count_same = true --Variable that indicates wether objects with same name has the same number of faces
			
			if opType == 1 or opType == 2 do
			(
				for from_object in from_objects do
				(
					--Get stats for from_object:
					from_object_base = from_object.baseObject
					from_object_class = classOf from_object_base
					from_object_faceCount = 0
					if from_object_class == Editable_Poly do from_object_faceCount = polyOp.getNumFaces from_object_base
					if from_object_class == Editable_Mesh do from_object_faceCount = meshOp.getNumFaces from_object_base
					
					
					for to_object in to_objects where from_object.name == to_object.name do
					(
						--Get stats for to_object:
						to_object_base = to_object.baseObject
						to_object_class = classOf to_object_base
						to_object_faceCount = 0
						if to_object_class == Editable_Poly do to_object_faceCount = polyOp.getNumFaces to_object_base
						if to_object_class == Editable_Mesh do to_object_faceCount = meshOp.getNumFaces to_object_base
						
						--Check if face count is similar in both from_object and to_object:
						if from_object_faceCount != to_object_faceCount do
						(
							print ("objects with the name " + from_object.name + " does not have identical face count")
							face_count_same = false
						)
						
					)--END loop through to_objects
				)--END loop through from_objects
			)--END if opType == 1 or opType == 2 do
			
			--Message the user if objects with identical names does not have identical face count:
			if face_count_same == false do MessageBox "Some objects with same name does not have identical face count. See listener (F11) for more details"
			
			--Return value:
			return face_count_same
		)--END Same_Face_Count
		
		
		
		
		
	)--END struct Error_Check
	
	
	
	
	
)--END script