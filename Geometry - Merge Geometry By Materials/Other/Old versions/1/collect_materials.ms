/*
In the struct Collect_Materials, all materials will be collected.
The point is to have a standalone material collection that all objects can pick from when they rearrange materials, faceID´s etc.

Material names are trimmed and condensed while they are on the object. This is to remove uneccessary spaces and capital letters.
The materials are since collected in two arrays. One that contains materials, and one that contains corresponding material names. (having material names as a standalone array makes things easier down the line)
*/


(--START script
	
	struct Collect_Materials
	(
		--Members that will get values from outside the struct:
		allObjects,
		
		--Members that will get values from inside the struct:
		allMaterials = #(),
		allMaterials_names = #(),
		
		fn Collect_Materials =
		(
			For theObject_index in 1 to allObjects.count do
			(
				--------------------------------------------------------------------------------------------------------------------
				--A variable that contains the current object:
				theObject = allObjects[theObject_index]
				
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
				--Collect material instances:
			
				--If the material is a single material, not multimaterial:
				if classOf theMat != Multimaterial then
				(
					if theMat != undefined and (findItem allMaterials_names theMat.name)==0 do 
					(
						append allMaterials_names theMat.name
						append allMaterials theMat
					)
				)
				--If the material is a multimaterial:
				else
				(
					--Use materialList to loop through slots:
					matList = theMat.materialList
					for currentSlot in 1 to matList.count do --Loop through slots
					(
						--If the current slot contains a material:
						if matList[currentSlot] != undefined and (findItem allMaterials_names matList[currentSlot].name)==0 do 
						(
							append allMaterials_names matList[currentSlot].name
							append allMaterials matList[currentSlot]
						)
					)
				)
				
				--------------------------------------------------------------------------------------------------------------------
			)--END loop through objects
		)--END fn Collect_Materials
	)--END struct Collect_Materials
)--END script