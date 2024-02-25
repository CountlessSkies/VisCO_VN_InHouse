(--START script
	
	
	
	
	struct Duplicate_MaterialNames
	/*
	If the user does not select all scene objects, it might happen that a submaterial with a particular name ("yellow" for example) on a selected object
	gets promoted to a single material with the same name. It might be that an unselected object has a single material with that name, which means you get
	duplicate material names in the scene, which 3dsmax does not like. This struct will give the unselected object the same material as the selected.
	
	OBS OBS:
	This struct does NOT get materials and material names from the collect materials arrays. Instead it will collect it from selected objects into its own arrays.
	The reason is that it can check what materials made it to the selected objects in the end, after the script has done its work.
	*/
	(
		--Struct members from the outside:
		allObjects,
		
		--Materials and material names collections. These are NOT arrays from the outside, but are created in this struct:
		all_materials = #(),
		all_material_names = #(),
		multiMat_names = #(),
		
		
		fn Collect_SelectedMaterials =
		/*
		This function collects materials and material names from allObjects, which is the selected objects.
		It puts the materials and names in arrays
		*/
		(
			for obj in allObjects do
			(
				append all_materials obj.material
				append all_material_names obj.material.name
			)
		), --END fn Collect_SelectedMaterials
		
		
		fn Remove_Duplicates_SingleMat =
		(	
			for obj in objects where obj.material != undefined and (findItem allObjects obj) == 0 and classOf obj.material != Multimaterial do
			(
				obj_matName = (trimLeft (trimRight (toLower (obj.material.name))))
				index = (findItem all_material_names obj_matName)
				if index != 0 do obj.material = all_materials[index]
				
			)--END loop through objects
			
		),--END fn Remove_Duplicates_SingleMat
		
		
		
		fn Remove_Duplicates_MultiMat =
		(	
			for obj in objects where obj.material != undefined and (findItem allObjects obj) == 0 and classOf obj.material == Multimaterial do
			(
				obj_matName = (trimLeft (trimRight (toLower (obj.material.name))))
				index = (findItem all_material_names obj_matName)
					
				if index != 0 do
				(
					------------------------------------------
					--create unique name for the material:
					
					local multiMat_name
					create_new_name = true
					X = 1
					while create_new_name do
					(
						multiMat_name = ("multimaterial_" + X as string)
						create_new_name = false
						for other_name in multiMat_names where other_name == multiMat_name do create_new_name = true
						for other_name in all_material_names where other_name == multiMat_name do create_new_name = true
						X += 1
					)
					append multiMat_names multiMat_name
					------------------------------------------
					
					obj.material.name = multiMat_name
					
				)--END if index != 0 
				
			)--END loop through objects
			
		)--END fn Remove_Duplicates_MultiMat
		
		
		
		
	)--END Struct Duplicate_MaterialNames
	
	
	
	
)--END Script