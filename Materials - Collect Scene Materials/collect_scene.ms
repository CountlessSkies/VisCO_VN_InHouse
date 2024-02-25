/*
This part of the script collects objects and their respective faceIDs, material names and colors.
The arrays are aligned. For example item nr 9 in faceID_arr is a sub-array that contains ID큦. This is the ID큦 that belongs to obj nr 9 in allObjects

1. Sort allObjects. This must be done as the very first thing
2. Fill org_obj_arr with objects
3. Collect face ID큦.
4. Collect material names. Undefined means no material
5. collect the materials corresponding ID, which comes from the ID slot in multimaterials. 0 means not a multimaterial while undefined means no material
6. Collect unique material instances
7. Merge material names if thy contain a string from the LUT that indicate that they should be merged
8. Materials collected in org_materials_arr that have the same name are merged.
   Note that the previous step of merging material names according to the LUT  affects this step, as now potentially many material names are similar
*/



struct Scene_Collect
(
	org_obj_arr = #(),          --Objects array
	org_matNames_arr = #(),  --Material names array. Contains one sub-array for each object. Each sub-array contains material names associated with object in same index
	org_matIDs_arr = #(),      --Material ID array. Contains one sub-array for each object. Each sub-array contains material ID큦 associated with a corresponding material name 
	org_materials_arr = #(), --All materials array. Contains all materials collected from objects
	
	fn populate_arrays allObjects mergeLUT_arr =
	(
		--------------------------------------------------------------------------------------------------------------------
		--Initialize the size of arrays: (Only initialize the sizes if there are objects collected in the first place)
		if allObjects.count > 0 do
		(
			org_obj_arr[allObjects.count] = 0
			org_matNames_arr[allObjects.count] = 0
			org_matIDs_arr[allObjects.count] = 0
		)
		
		--------------------------------------------------------------------------------------------------------------------
		--Sort objects. Objects with highest materials count should be first:
		fn sort_arr obj1 obj2 =
		(
			--Points for each object, depending on how many materials it has:
			points_obj1 = 0
			points_obj2 = 0
			
			--Add one point per material on the object:
			if obj1.material != undefined and classOf obj1.material != multimaterial do points_obj1 += 1
			if classOf obj1.material == multimaterial do for i in obj1.material.materialList where i != undefined do points_obj1 += 1
				
			if obj2.material != undefined and classOf obj2.material != multimaterial do points_obj2 += 1
			if classOf obj2.material == multimaterial do for i in obj2.material.materialList where i != undefined do points_obj2 += 1
			
			--Return value. Objects with most materials should come first:
			points_obj2 - points_obj1
		)
		
		qsort allObjects sort_arr
		
		--------------------------------------------------------------------------------------------------------------------
		--Loop through objects:
		For theObject_index in 1 to allObjects.count do
		(
			--A variable that contains the current object:
			theObject = allObjects[theObject_index]
			
			--Fill org_obj_arr with objects:
			org_obj_arr[theObject_index] = theObject
			
			--The material, which can be either a single material or a multimaterial (multiSub):
			theMat = theObject.material
			
			--------------------------------------------------------------------------------------------------------------------
			--Trim and remove capital letters in material name:
			
			--If the material is not a Multimaterial:
			if theMat != undefined and classOf theMat != Multimaterial do theMat.name = (trimLeft (trimRight (toLower (theMat.name))))
			
			--If the material is a multimaterial:
			if classOf theMat == Multimaterial do
			(
				--To make it loop through slots, not use the highest ID, use materialList:
				matList = theMat.materialList
				
				--Loop through slots:
				for currentSlot in 1 to matList.count do
				(
					--If the current slot contains a material:
					if matList[currentSlot] != undefined do matList[currentSlot].name = (trimLeft (trimRight (toLower (matList[currentSlot].name))))
				)
			)
			
			--------------------------------------------------------------------------------------------------------------------
			--Collect material names and their corresponding ID:
			
			--Sub-arrays that are to be filled:
			matName_subArr = #()
			matID_subArr = #()
			
			
			--If the material is a single material, not multimaterial:
			if classOf theMat != Multimaterial then 
			(
				if theMat != undefined then
				(
					matName_subArr = #(theMat.name)
					matID_subArr = #(0)
				)
				else
				(
					matName_subArr = #(undefined)
					matID_subArr = #(undefined)
				)
			)
			--If the material is a multimaterial:
			else
			(
				--To make it loop through slots, not use the highest ID, use materialList:
				matList = theMat.materialList
				
				--Initialize array sizes:
				matName_subArr[matList.count] = 0
				matID_subArr[matList.count] = 0
				
				--Loop through slots:
				for currentSlot in 1 to matList.count do
				(
					--If the current slot contains a material:
					if matList[currentSlot] != undefined then matName_subArr[currentSlot] = matList[currentSlot].name
					--If the current slot is empty (no material):
					else matName_subArr[currentSlot] = undefined
					--corresponding material ID is set the same way in either case:
					matID_subArr[currentSlot] =  theMat.materialIDList[currentSlot]
				)
			)
			
			--Append subArrays to top arrays:
			org_matNames_arr[theObject_index] = matName_subArr
			org_matIDs_arr[theObject_index] = matID_subArr
			
			--------------------------------------------------------------------------------------------------------------------
			--Collect material instances:
			
			--If the material is a single material, not multimaterial:
			if classOf theMat != Multimaterial then
			(
				if theMat != undefined do append org_materials_arr theMat
			)
			--If the material is a multimaterial:
			else
			(
				--Use materialList to loop through slots:
				matList = theMat.materialList
				for currentSlot in 1 to matList.count do --Loop through slots
				(
					--If the current slot contains a material:
					if matList[currentSlot] != undefined do append org_materials_arr matList[currentSlot]
				)
			)
			
			--------------------------------------------------------------------------------------------------------------------
			
		) --END per object loop	
		
		--------------------------------------------------------------------------------------------------------------------
		--MERGE MATERIAL NAMES:
		
		/*
		The script has an array of strings.
		Materials with names that contain these strings shall merge to single materials.
		Every string\item (delimited in the interface) shall be a separate material
		The names that contain this string will be reduced to this string only, while the rest of the name is removed.
		This way it will make sure that all these materials is merged into one later down the line in the script.
		*/
		
		--Go through material names that belongs to objects and change them:
		for subArr in org_matNames_arr do for nameIndex in 1 to subArr.count do
		(
			if subArr[nameIndex] != undefined do
			(
				for theString in mergeLUT_arr do
				(
					if (findString subArr[nameIndex] theString) != undefined do
					(
						subArr[nameIndex] = theString
					)
				)
			)
		)
		
		
		--Go through materials collected in the scene and change their names:
		for nameIndex in 1 to org_materials_arr.count do
		(
			for theString in mergeLUT_arr do
			(
				if org_materials_arr[nameIndex] != undefined do
				(
					if (findString org_materials_arr[nameIndex].name theString) != undefined do
					(
						org_materials_arr[nameIndex].name = theString
					)
				)
			)
		)
		
		--------------------------------------------------------------------------------------------------------------------
		--Materials with same name in org_materials_arr are merged:
		names_array = #()
		for theMatIndex in org_materials_arr.count to 1 by -1 where org_materials_arr[theMatIndex] != undefined do
		(
			theMat = org_materials_arr[theMatIndex]
			theName = (trimLeft (trimRight (toLower (theMat.name))))
			
			if (findItem names_array theName) then deleteItem org_materials_arr theMatIndex else append names_array theName
		)
		
		--------------------------------------------------------------------------------------------------------------------
		
	) --END populate_arrays function
	
	
	
)--END struct Scene_Collect