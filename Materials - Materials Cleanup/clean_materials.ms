/*
This part of the script will clean materials.
That means it will take the materials that was collected in the struct Collect_Materials and make sure all objects, both with single materials and multimaterials, use the same materials.
(same material name = same material)
Otherwise it could be that some objects has materials with identical name and attributes, but not the same instance. This will prevent the objects from merging properly
*/

(--START script
	struct Clean_Materials
	(
		allObjects,
		allMaterials,
		allMaterials_names,
		undefinedMatName,
		
		---------------------------------------------------------------------------------------------------------------------
		--Give objects with no material, undefined material from collection instead:
		fn No_Materials =
		(
			for theObject in allObjects where theObject.material == undefined do
			(
				new_mat = allMaterials[(findItem allMaterials_names undefinedMatName)]
				theObject.material = new_mat
			)
		),
		
		---------------------------------------------------------------------------------------------------------------------
		--Make sure the objects single materials are the same instances:
		fn Single_Materials =
		(
			--Loop through objects with single materials:
			for theObject in allObjects where theObject.material != undefined and classOf theObject.material != multiMaterial do
			(
				obj_org_mat = theObject.material --Original object material
				index = (findItem allMaterials_names obj_org_mat.name) --Index of the same material name in allMaterials_names
				new_mat = allMaterials[index] --The new material, found at the same index as the material name
				theObject.material = new_mat --Reassign the new material to the object
			)--END loop through objects
			
		),--END fn Single_Materials
		
		---------------------------------------------------------------------------------------------------------------------
		fn Multi_Materials =
		(
			--Loop through objects with multimaterials:
			for theObject in allObjects where classOf theObject.material == multiMaterial do
			(
				obj_org_mat = theObject.material --Original object material
				matList = obj_org_mat.materialList --Material list
				
				--Use materialList to loop through slots:
				for currentSlot in 1 to matList.count do --Loop through slots
				(
					--If the current slot contains a material:
					if matList[currentSlot] != undefined and (findItem allMaterials_names matList[currentSlot].name) != 0 do 
					(
						index = findItem allMaterials_names matList[currentSlot].name --Index of the same material name in allMaterials_names
						new_mat = allMaterials[index] --The new material, found at the same index as the material name
						matList[currentSlot] = new_mat --Reassign the new material to the object
					)
				)--END loop through material slots in multiMaterial
				
			)--END loop through objects
			
		),--END fn Multi_Materials 
		
		---------------------------------------------------------------------------------------------------------------------
		fn Rename_MultiMat_Namelist =
		(
			--Loop through objects with multimaterials:
			for theObject in allObjects where classOf theObject.material == multiMaterial do
			(
				obj_org_mat = theObject.material --Original object material
				matList = obj_org_mat.materialList --Material list
				
				for i in 1 to matList.count do 
				(
					matName = matList[i].name
					if matName != undefined do obj_org_mat.names[i] = matName
				)
				
			)--END loop through objects
			
			
		)--END fn Rename_MultiMat_Namelist
		
		---------------------------------------------------------------------------------------------------------------------
	)--END struct Clean_Materials
	
	
)--END script