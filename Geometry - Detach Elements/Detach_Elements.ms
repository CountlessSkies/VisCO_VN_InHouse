/*
*/


(--START script
	
	struct Detach_Elements
	(
		all_objects,
		--This contains all original objects.
		--It will be added new objects at the end of the array, so the scripts needs to start working at the end of the original collection and down to 1
		
		
		fn Detach_Elements =
		(
			--Variable that holds all the new objects, so that they later can be appended to all_objects:
			temp_all_objects = #()
			
			--Loop through objects:
			For theObject_index in all_objects.count to 1 by -1 do
			(
				--A variable that contains the current object:
				theObject = all_objects[theObject_index]
				
				--A variable that contains all objects that used to be elements:
				new_objects = #()
				
				---------------------------------------------------------------------------------------------------------------------
				--COLLECT MODIFIERS:
				
				all_object_modifiers = (for i in theObject.modifiers.count to 1 by -1 collect theObject.modifiers[i]) --Collect modifiers in reverse order 
				
				---------------------------------------------------------------------------------------------------------------------
				--PREPARE WORKING ON FACES:
				
				--Puts baseObject and its class in variables:
				local theObjectBase = theObject.baseObject
				local theClass = classOf theObjectBase
				
				local faceCount = undefined
				local theObjectBaseMesh = undefined
				local faceCountInterface = undefined
				local getElementInterface = undefined
				local detachInterface = undefined
				
				if theClass == Editable_Poly do
				(
					faceCount = polyOp.getNumFaces theObjectBase --This is just an initial value. It will change when parts of the object detaches
					theObjectBaseMesh = theObjectBase
					faceCountInterface = polyOp.getNumFaces
					getElementInterface = polyop.getElementsUsingFace
					detachInterface = polyOp.detachFaces
				)
				if theClass == Editable_Mesh do
				(
					faceCount = meshOp.getNumFaces theObjectBase --This is just an initial value. It will change when parts of the object detaches
					theObjectBaseMesh = theObjectBase.mesh
					faceCountInterface = meshOp.getNumFaces
					getElementInterface = meshop.getElementsUsingFace
					detachInterface = meshOp.detachFaces
				)
				
				---------------------------------------------------------------------------------------------------------------------
				--COLLECT FACES AND DETACH INTO SEPARATE OBJECTS
				
				while faceCount > 0 do
				(
					--Variable that will hold the newly created object (the detached element):
					newObj = undefined
					
					
					--Faces connected to face number 1 forms an element:
					--(Since it will separate element by element and restart every time, it will always work on face number 1)
					detach_faces = getElementInterface theObjectBase 1
					
					
					--Detach faces for Editable_Mesh and create a new object that contains the element mesh:
					if theClass == Editable_Mesh do
					(
						oldMesh = detachInterface theObjectBaseMesh detach_faces delete:true asMesh:true
						newObj = editable_mesh()
						newObj.mesh = oldMesh
					)--END detach faces for Editable_Mesh 
					
					
					--Detach faces for Editable_Poly and create a new object that contains the element mesh:
					if theClass == Editable_Poly do
					(
						--create random name that later can be assigned to the detached object and then searched for:
						temp_name = (uniquename "detachScript_tempName_")
						
						--Detach faces and put them into the object with temp_name:
						detachInterface theObject detach_faces delete:true asNode:true name:temp_name
						newObj = (getNodeByName temp_name)
						
					)--END detach faces for Editable_Poly
					
					
					
					--Set all parameters for the newly created mesh:
					if newObj != undefined do
					(
						--Update the geometry:
						update newObj
						
						--Give the new object the same pivot transform as the old one:
						oldTr = theObject.transform
						newObj.transform = oldTr
						
						--Give the new object a new name:
						newObj.name = uniquename (theObject.name + "_")
						
						--Give the new object the same parent as the old one:
						newObj.parent = theObject.parent
						
						--Put the new object in the same layer as the old one:
						theLayer = theObject.layer
						theLayer.addNode newObj
						
						--Give the new object the same wirecolor as the old one:
						newObj.wirecolor = theObject.wirecolor
						
						--Give the new object the same material as the old one:
						newObj.material = theObject.material
						
						--Give the new object the same animation controller as the old one, either instanced or unique:
						newObj.controller = (copy theObject.controller)
						
						--Append the new object to a temporary array that contains all objects that used to be elements in this particular object:
						append new_objects newObj
						
						--Append the new object to a temporary array. This array will later be joined with all_objects:
						append temp_all_objects newObj
						
						--Update the geometry:
						update newObj
						
					) --END Set all parameters for the newly created mesh
					
					
					--Update face count:
					if theClass == Editable_Poly do faceCount = faceCountInterface theObjectBase
					if theClass == Editable_Mesh do faceCount = faceCountInterface theObjectBase
					
					
				) --END looping through face count
				
				
				--Add modifiers to the new objects.
				--To make it right you have to select all new objects (that used to be just one) and apply the modifiers to the selection:
				if all_object_modifiers.count > 0 do
				(
					select new_objects
					for theMod in all_object_modifiers do modPanel.addModToSelection theMod
					clearSelection()
				)
				
				
				--Remove theObject from all_objects:
				deleteItem all_objects (findItem all_objects theObject)
				
				
				--When all elements are extracted into their own objects, delete the original object:
				delete theObject
				
				
				---------------------------------------------------------------------------------------------------------------------
			)--END loop through objects
			
			
			--The newly created objects that are stored in temp_all_objects, will now join all_objects so that they become part of the selection:
			join all_objects temp_all_objects
			
			---------------------------------------------------------------------------------------------------------------------
		)--END fn Separate_Operation
		
	)--END struct Weld_Vertices
	
)--END script