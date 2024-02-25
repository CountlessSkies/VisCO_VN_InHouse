/*
Converge is a struct that converges face IDs.
The point is that some objects might have multimaterials, but they have one predominant material. Depending on how predominant it is, the whole object will get one single material

The struct collects face material IDs and counts the number of times it occur.
If the occurence is more than the user specified amount of %, the submaterial will be promoted to its own material and assigned to the object.

It does not change any face IDs in the process
*/

(--START script
	
	struct Converge
	(
		--Members that will get values from outside the struct:
		nonInstances,
		convergeValue,
		
		
		fn Converge_MultiMats =
		(
			
			--Variable that contains objects that are to get converged face IDs:
			allObjects = (for obj in nonInstances where classOf obj.material == Multimaterial collect obj)
			
			for theObject in allObjects do
			(
				------------------------------------------------------------------------------------------------------------------------------------------------------------
				--Puts baseObject and its class in variables:
				local theObjectBase = theObject.baseObject
				local theClass = classOf theObjectBase
				
				--Counts faces and puts interfaces to get and set material ID`s in variables:
				local faceCount = 0
				local getIDinterface = undefined
				local theObjectBaseMesh = undefined
				
				--Face ID array:
				--Two dimensional array. First item is the material ID, while the second is a counter that tracks how many faces with this ID
				local faceMatIDs = #(#(undefined,undefined))
				
				--converge_ID as undefined indicates that the object should not converge. If converge_ID has a number, that is the faceID it should converge to:
				local converge_ID = undefined
				
				------------------------------------------------------------------------------------------------------------------------------------------------------------
				if theClass == Editable_Poly do
				(
					faceCount = polyOp.getNumFaces theObjectBase
					getIDinterface = polyop.getFaceMatID
					theObjectBaseMesh = theObjectBase
				)
				if theClass == Editable_Mesh do
				(
					faceCount = meshOp.getNumFaces theObjectBase
					getIDinterface = getFaceMatID
					theObjectBaseMesh = theObjectBase.mesh
				)
				
				------------------------------------------------------------------------------------------------------------------------------------------------------------
				--currentFace is the current face number
				for currentFace in 1 to faceCount do 
				(
					--currentID is the current face ID:
					local currentID = undefined
					currentID = getIDInterface theObjectBaseMesh currentFace
					
					--If this is the first face, fill the first slot in faceMatIDs array:
					if currentFace == 1 do
					(
						faceMatIDs[1][1] = currentID
						faceMatIDs[1][2] = 0
					)
					
					
					new_slot = true --Indicates wether a new slot must be created
					
					--If the current face ID is found as the first item in one of the slots, add a number to the second item which is a counter.
					--new_slot is set to false, which indicates that it doesnt have to create a new slot in faceMatIDs
					for slot in faceMatIDs where slot[1] == currentID do
					(
						slot[2] += 1
						new_slot = false
					)
					
					--If a new slot has to be created, give it an array with the current face ID and face count 1
					if new_slot == true do append faceMatIDs #(currentID, 1)
					
				) --END for currentFace in 1 to faceCount 
				
				------------------------------------------------------------------------------------------------------------------------------------------------------------
				--Sort faceMatIDs to get the face ID with the highest count first:
				fn sort_arr arrSlot1 arrSlot2 = (return arrSlot2[2] - arrSlot1[2])
				qsort faceMatIDs sort_arr
				
				------------------------------------------------------------------------------------------------------------------------------------------------------------
				--Converge or not by comparing the % face ID with minConvergeValue, which is the spinner value in the UI:
				if (faceMatIDs[1][2] / (faceCount as float))*100 >= convergeValue do converge_ID = faceMatIDs[1][1]
				
				------------------------------------------------------------------------------------------------------------------------------------------------------------
				--Give the object the correct material:
				if converge_ID != undefined do theObject.material = (theObject.material[converge_ID])
					
				------------------------------------------------------------------------------------------------------------------------------------------------------------
				--Give object instances the correct material:
				if converge_ID != undefined do
				(
					--Add the same material to all the objects instances:
					InstanceMgr.GetInstances theObject &Instances
					for the_instance in Instances do the_instance.material = theObject.material
				)
				
				------------------------------------------------------------------------------------------------------------------------------------------------------------
					
			)--END loop through allObjects
			
		)--END fn Converge_faceIDs
		
	)--END struct Converge
	
)--END script