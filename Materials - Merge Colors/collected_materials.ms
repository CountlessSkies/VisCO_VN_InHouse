/*
In the struct Collect_Materials, all materials will be collected.
The point is to have a standalone material collection that all objects can pick from when they rearrange materials, faceID´s etc.
*/


(--START script
	
	struct Collected_Materials
	(
		--Members that will get values from outside the struct:
		allObjects,
		
		--Members that will get values from inside the struct:
		allMaterials = #(),
		
		fn Collect_Materials =
		(
			For theObject in allObjects do
			(
				--------------------------------------------------------------------------------------------------------------------
				--The material, which can be either a single material or a multimaterial (multiSub):
				theMat = theObject.material
				
				--------------------------------------------------------------------------------------------------------------------
				--Collect material instances:
			
				--If the material is a single material, not multimaterial:
				if classOf theMat != Multimaterial do appendIfUnique allMaterials theMat
				
				--If the material is a multimaterial:
				if classOf theMat == Multimaterial do
				(
					--Use materialList to loop through slots:
					matList = theMat.materialList
					for currentSlot in 1 to matList.count do --Loop through slots
					(
						--If the current slot contains a material:
						if matList[currentSlot] != undefined do appendIfUnique allMaterials matList[currentSlot]
					)
				)
				
				--------------------------------------------------------------------------------------------------------------------
			)--END loop through objects
			
		)--END fn Collect_Materials
		
	)--END struct Collect_Materials
	
)--END script