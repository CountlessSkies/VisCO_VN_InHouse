(--START script
	
	struct Condense_Multimats
	/*
	The struct has functions that collects all objects with multimaterials, figure out which sub-materials they need,
	finds other objects with the same sub-materials, and gives them the same common multiMaterial
	*/
	(
		---------------------------------------------------------------------------------------------------------------------
		--Members that will get values from outside the struct:
		
		nonInstances,
		allMaterials,
		allMaterialNames,
		undefinedMatName, --The name of undefined materials
		
		---------------------------------------------------------------------------------------------------------------------
		--Members that will get values from inside the struct:
		
		-----------------------
		--The original collection of objects, their corresponding multiMaterial and faces:
		old_multiMatNames = #(), --Each item is a sub-array with all material names for the corresponding object
		old_objects_arr = #(), --Contains an array of objects
		old_submat_faces = #(), --Contains a sub-array for each multimat, and a sub-array of that again with faceIDs corresponding to each sub-material
		
		-----------------------
		--The new collection of objects and corresponding material names:
		new_multiMatNames = #(), --Each sub-array within will later become a multiMaterial, and consists of material names
		new_objects_arr = #(), --Each sub-array contains one or more objects. The objects will be assigned a corresponding multiMaterial from new_multiMatNames
		
		-----------------------
		--The newly created multiMaterials:
		new_multiMats = #(),
		
		---------------------------------------------------------------------------------------------------------------------
		
		
		
		
		
		fn Collect_MultiMats =
		/*
		This function will collect materials, objects and faces in corresponding arrays.
		*/
		(
			--Variable that contains objects that are to have their multimaterials condensed:
			allObjects = (for obj in nonInstances where classOf obj.material == Multimaterial collect obj)
			
			--Loop through objects:
			For theObject_index in 1 to allObjects.count do
			(
				--A variable that contains the current object:
				theObject = allObjects[theObject_index]
				
				---------------------------------------------------------------------------------------------------------------------
				--PREPARE WORKING ON FACE ID´s:
				
				--Puts baseObject and its class in variables:
				local theObjectBase = theObject.baseObject
				local theClass = classOf theObjectBase
				
				local faceCount = 0
				local getIDinterface = undefined
				local setIDinterface = undefined
				local theObjectBaseMesh = undefined
				
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
				
				---------------------------------------------------------------------------------------------------------------------
				--ARRAYS:
				
				new_names = #() --contains all object material names. The index position is their material ID
				new_multiMat_faceIDs = #() --contains sub-arrays, where each array contains face IDs and corresponds to the material name in new_names
				
				---------------------------------------------------------------------------------------------------------------------
				--COLLECT OBJECT MATERIALS FROM MULTIMATERIAL
				--(The object doesn´t neccesarily use all of them since it might share a multiMaterial with several other objects)
				
				--Sub-arrays that are to be filled:
				matName_subArr = #()
				matID_subArr = #()
				
				--The original multiMaterial:
				theMat = theObject.material
				
				--To make it loop through slots, not use the highest ID, use materialList:
				matList = theMat.materialList
				
				--Initialize array sizes:
				matName_subArr[matList.count] = true
				matID_subArr[matList.count] = true
				
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
				
				--------------------------------------
				--COLLECT MATERIAL NAMES FROM FACE IDs:
				
				--currentFace is the current face number
				for currentFace in 1 to faceCount do 
				(
					--currentID is the current face ID:
					local currentID
					currentID = getIDInterface theObjectBaseMesh currentFace
					
					--currentName is the name of the material on the current face:
					local currentName = undefined --(It can stay as "undefined" if the face doesnt correspond to any IDs in the multimaterial)
					index = (findItem matID_subArr currentID)
					if index != 0 do currentName = matName_subArr[index]
					
					
					--Find the new material ID in new_names by matching its material name:
					local index = findItem new_names currentName
					
					if index == 0 then --If the face material name does not exist
					(
						append new_names currentName --Append the current material name to new_names
						append new_multiMat_faceIDs #() --Make a new sub-array in new_multiMat_faceIDs to contain the corresponding face IDs to this material name
						append new_multiMat_faceIDs[new_multiMat_faceIDs.count] currentFace --Add the current face number to the sub-array that corresponds with material names
					)
					else append new_multiMat_faceIDs[index] currentFace --If the face material name does exist, append the face number to the corresponding sub-array
					
					
				) --END for currentFace in 1 to faceCount 
				
				---------------------------------------------------------------------------------------------------------------------
				--APPEND THE OBJECT, ALL MATERIAL NAMES, AND CORRESPONDING FACE ID´S TO TOP ARRAYS:
				
				append old_objects_arr theObject --Put object into array
				append old_multiMatNames new_names --A corresponding array with sub-material names is put in old_multiMatNames
				append old_submat_faces new_multiMat_faceIDs --Contains a sub-array for each multimat, and a sub-array of that again with faceIDs corresponding to each sub-material
				
				---------------------------------------------------------------------------------------------------------------------
				
			)--END looping through objects
			
		),--END fn Collect_MultiMats
		
		
		
		
		fn Condense_MultiMats =
		/*
		This function will take the previous arrays and condense them.
		The idea is to re-organize the the arrays in such a way that objects with multimaterials that consists of the same sub-materials will get one single, shared multimaterial.
		However, the only disprecancy that is allowed between the two multimaterials, is sub-materials in different order.
		It will NOT merge multimaterials where one MM has more or less number of materials than the other.
		
		The function will make new arrays that corresponds objects with a multimaterial (consisting of several sub-material names).
		It might or might not share that material with other objects
		*/
		(
			---------------------------------------------------------------------------------------------------------------------
			for i in 1 to old_multiMatNames.count do
			(
				--------------------------------------
				the_object = old_objects_arr[i] --Finds the corresponding object to the old sub-material
				old_subMatNames = old_multiMatNames[i] --Finds the list of sub-material names for this particular object
				
				--------------------------------------
				suited_slot = 0 -- Will contain the multiMaterial slot number in new_multiMatNames if it finds one that suits. 0 (zero) indicates that a new slot must be created
				
				--Loop through new_multiMatNames to see if it already contains a suitable slot. The slot number will be set in the variable "suited_slot":
				for j in 1 to new_multiMatNames.count do
				(
					new_subMatNames = new_multiMatNames[j]
					allMatch = true --Will change to false if there is a disprecancy between the materials
					
					--Check if all new_subMatNames exist in old_subMatNames: (otherwise the number of materials are not identical)
					for k in 1 to new_subMatNames.count do
					(
						new_subMatName = new_subMatNames[k]
						if (findItem old_subMatNames new_subMatName) == 0 do allMatch = false
					)
					
					--And then check if all old_subMatNames exist in new_subMatNames: (otherwise the number of materials are not identical)
					for k in 1 to old_subMatNames.count do
					(
						old_subMatName = old_subMatNames[k]
						if (findItem new_subMatNames old_subMatName) == 0 do allMatch = false
					)
					
					if allMatch == true do suited_slot = j
					
				)--END Loop through new_multiMatNames
				
				--------------------------------------
				if suited_slot == 0 then --If it did not find a suited slot:
				(
					--Make a new sub-array in new_objects_arr (since it may contain several objects) and put the object in that slot:
					append new_objects_arr #()
					append new_objects_arr[new_objects_arr.count] the_object
					
					--Make a new slot in new_multiMatNames and put sub-material names in that slot:
					append new_multiMatNames #()
					for matName in old_subMatNames do append new_multiMatNames[new_multiMatNames.count] matName
				)
				--If it found a suited slot:
				else append new_objects_arr[suited_slot] the_object --Put the object in that slot (The objects sub-materials might not be in the same order, but that will be fixed later)
				
			)--END loop through old_multiMatNames
			
			---------------------------------------------------------------------------------------------------------------------
		), --END fn Condense_MultiMats 
		
		
		
		
		
		
		fn Make_MultiMats =
		/*
		This function will create the actual multiMaterials based on the previously created new_multiMatNames array
		*/
		(
			
			--Loop through all top array slots that each contain a collection of materials (and together make up a multiMaterial):
			for new_multiMatName in new_multiMatNames do
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
					for other_name in allMaterialNames where other_name == multiMat_name do create_new_name = true
					X += 1
				)
				
				------------------------------------------
				--Make the multiMaterial:
				
				the_multiMat = Multimaterial numSubs:new_multiMatName.count name: multiMat_name
				
				--Loop through all materials in the array slot:
				for i in 1 to new_multiMatName.count do
				(
					matName = new_multiMatName[i]
					
					--Find the index position for the material to use:
					index = (findItem allMaterialNames matName)
					
					--If the material is found in the material collection:
					if index != 0 then
					(
						theMat = allMaterials[index]
						the_multiMat[i] = theMat
					)
					else
					--If the faceID has no assigned material, give it the undefined material from the materials collection:
					(
						theMat = allMaterials[(findItem allMaterialNames undefinedMatName)]
						the_multiMat[i] = theMat
					)
				)
				
				
				--Append multiMat to new_multimats array:
				append new_multiMats the_multiMat
				
				--Append the new multiMaterial into allMaterials and allMaterialNames:
				append allMaterials the_multiMat
				append allMaterialNames multiMat_name
				
			)--END loop through new_multiMatNames
			
		),--END fn Make_MultiMats
		
		
		
		
		
		
		fn Change_FaceIDs =
		/*
		This function will change faceIDs to the new multiMaterial reorganizing
		*/
		(
			
			
			--Loop through to object collections:
			for top_obj_coll_index in 1 to new_objects_arr.count do
			(
				---------------------------------
				obj_collection = new_objects_arr[top_obj_coll_index]
				new_multiMat = new_multiMatNames[top_obj_coll_index]
				
				---------------------------------
				--Loop through objects:
				for obj_coll_index in 1 to obj_collection.count do
				(
					--A variable that contains the current object:
					theObject = obj_collection[obj_coll_index]
					
					old_obj_index = (findItem old_objects_arr theObject)
					old_multiMat = old_multiMatNames[old_obj_index]
					faces_collections = old_submat_faces[old_obj_index]
					
					---------------------------------------------------------------------------------------------------------------------
					--PREPARE WORKING ON FACE ID´s:
					
					--Puts baseObject and its class in variables:
					local theObjectBase = theObject.baseObject
					local theClass = classOf theObjectBase
					
					local faceCount = 0
					local getIDinterface = undefined
					local setIDinterface = undefined
					local theObjectBaseMesh = undefined
					
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
					
					---------------------------------------------------------------------------------------------------------------------
					--currentFace is the current face number
					for face_collection_index in 1 to faces_collections.count do 
					(
						--Set variables:
						face_collection = faces_collections[face_collection_index]
						matName = old_multiMat[face_collection_index]
						new_faceID = findItem new_multiMat matName
						
						--Set new faceID for the face collection:
						setIDinterface theObjectBaseMesh face_collection new_faceID
					)
					
					---------------------------------------------------------------------------------------------------------------------
					
				)--END loop through objects	
				
			)--END loop through to object collections
			
		),--END fn Change_FaceIDs
		
		
		
		
		
		
		fn Apply_MultiMats =
		/*
		This function will apply new multiMaterials for each object
		*/
		(
			for i in 1 to new_multiMats.count do
			(
				the_multiMat = new_multiMats[i]
				for theObject in new_objects_arr[i] do
				(
					theObject.Material = the_multiMat
					
					--Add the same material to all the objects instances:
					InstanceMgr.GetInstances theObject &Instances
					for the_instance in Instances do the_instance.material = the_multiMat
				)
			)
			
			
			
			
		),--END fn Apply_multiMats
		
		
		
		
		fn Debug =
		(
			print old_multiMatNames
			print old_objects_arr
			print old_submat_faces
			
			
			print new_objects_arr
			print new_multiMatNames
			print new_multiMats
		)
		
		
		
		
		
	)--END struct Condense_Multimats
	
)--END script
















