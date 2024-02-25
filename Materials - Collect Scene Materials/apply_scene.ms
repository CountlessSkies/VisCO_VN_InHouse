/*
This part of the script applies all the reaorganized data to the scene

It does the following:

-loops through objects:
-objects without materials are saved as undefined in the first index of org_matIDs_arr[org_obj_index]
-Objects with only a single material are saved as 0 in the first index of org_matIDs_arr[org_obj_index]
-Objects with multimaterial are saved as a integer higher than 0 in the first index of org_matIDs_arr[org_obj_index]
-In either case it finds the material name in org_matNames_arr, finds the same name in  new_matNames_arr, and uses this to set the new faceID

-Afterwards it makes thematerial in the correct slot and assigns objects to the material
*/


struct Scene_Apply
(
	fn faceID_op org_obj_arr org_matIDs_arr org_matNames_arr new_obj_arr new_matNames_arr new_materials_arr allObjects =
	(--START run function:
		
		for theSlot_index in 1 to new_obj_arr.count do
		(
			--Loop through objects:
			for theObject in new_obj_arr[theSlot_index] do
			(
				----------------------------------------------------------------------
				--Find object in old array so you can find its material name:
				org_obj_index = findItem org_obj_arr theObject
				
				----------------------------------------------------------------------
				--Object properties:
				theObjectBase = theObject.baseObject
				theClass = classOf theObjectBase
				
				--Object mesh properties
				faceCount = 0
				getIDinterface = undefined
				setIDinterface = undefined
				theObjectBaseMesh = undefined
				
				--Set object mesh properties:
				if theClass == Editable_Poly do
				(
					faceCount = polyOp.getNumFaces theObjectBase
					getIDinterface = polyop.getFaceMatID
					setIDinterface = polyOp.setFaceMatID
					theObjectBaseMesh = theObjectBase
				)
				
				if theClass == Editable_Mesh do
				(
					faceCount = meshOp.getNumFaces theObjectBase
					getIDinterface = getFaceMatID
					setIDinterface = setFaceMatID
					theObjectBaseMesh = theObjectBase.mesh
				)
				
				----------------------------------------------------------------------
				--If the object does not have a material:
				if org_matIDs_arr[org_obj_index][1] == undefined do
				(
					new_subSlot = (findItem new_matNames_arr[theSlot_index] undefined )
					new_ID = new_subSlot
					
					--Loop through faces and set new ID:
					for currentFace in 1 to faceCount do setIDinterface theObjectBaseMesh currentFace new_ID
				)
				
				----------------------------------------------------------------------
				--If the object only have one material:
				if org_matIDs_arr[org_obj_index][1] == 0 do
				(
					--Find material name. Since the object has a single, non multiMaterial, the name is in the first slot in the corresponding original object array:
					matName = org_matNames_arr[org_obj_index][1]
					
					--Find material name in the new object slot in new_matNames_arr. This is the new faceID for all faces:
					new_subSlot = (findItem new_matNames_arr[theSlot_index] matName)
					new_ID = new_subSlot
					
					--Loop through faces and set new ID:
					for currentFace in 1 to faceCount do setIDinterface theObjectBaseMesh currentFace new_ID
				)
				
				----------------------------------------------------------------------
				--If the object has a multisub material:
				if org_matIDs_arr[org_obj_index][1] != undefined and org_matIDs_arr[org_obj_index][1] != 0 do
				(
					for currentFace in 1 to faceCount do
					(
						--Find current material ID:
						currentID = getIDInterface theObjectBaseMesh currentFace
						
						--Find the index of the current material ID in org_matIDs_arr. The material name will be found in the same position:
						org_matID_index = (findItem org_matIDs_arr[org_obj_index] currentID)
						
						--Variable that holds the material name for this face:
						matName = "No material name yet"
						--If the material ID exist in org_matIDs_arr: (The current face might have an ID that did not exist in the multiMaterial)
						if org_matID_index != 0 then matName = org_matNames_arr[org_obj_index][org_matID_index]
						--If the material ID on the face does not exist in org_matIDs_arr:
						else matName = undefined
						
						--Find material name in the new object slot in new_matNames_arr:
						new_subSlot = (findItem new_matNames_arr[theSlot_index] matName)
						new_ID = new_subSlot
						
						--Set new faceID:
						setIDinterface theObjectBaseMesh currentFace new_ID
					)
				)
				
				----------------------------------------------------------------------
				
				
				
			)--END loop through new_obj_arr[theSlot_index]
			
			
			
		) --END loop through new_obj_arr.count
		
		----------------------------------------------------------------------
		
		--Make new material slots and assign materials and objects to them:
		for theSlot_index in 1 to new_materials_arr.count where new_materials_arr[theSlot_index].count > 0 do
		(
			--Make material slot:
			the_multiSubMat = Multimaterial()
			the_multiSubMat.numSubs = new_materials_arr[theSlot_index].count
			the_multiSubMat.name = "collected_"+(theSlot_index as string)
			for i in 1 to the_multiSubMat.materialList.count do the_multiSubMat.materialList[i] = undefined
			setMeditMaterial theSlot_index the_multiSubMat
			
			--Assign materials to the subSlots:
			for subSlot_index in 1 to new_materials_arr[theSlot_index].count do
			(
				theMat = new_materials_arr[theSlot_index][subSlot_index]
				if theMat != undefined do 
				(
					the_multiSubMat.materialList[subSlot_index] = theMat
					the_multiSubMat.names[subSlot_index] = theMat.name 
				)
			)
			
			
			--Assign objects to the slot:
			for theObject in new_obj_arr[theSlot_index] do theObject.material = the_multiSubMat
		)
		
		----------------------------------------------------------------------
		--Give instances of selected objects the same material: (Instances were excluded from the whole previous process)
		for obj in allObjects do
		(
			InstanceMgr.GetInstances obj &Instances
			for i in Instances do i.material = obj.material
		)--END Give instances of objects the same material
		
		----------------------------------------------------------------------
		
		
	)--END faceID_op function
	
	
	
)--END struct Scene_Apply