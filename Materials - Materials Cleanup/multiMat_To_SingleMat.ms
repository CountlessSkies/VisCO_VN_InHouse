/*
If the object has a multimaterial with no valid subMaterial, this function replaces the multiMaterial with a single undefined material
If the object has a multimaterial with a single valid subMaterial, this function promotes it to the object material (and removes the previous multiMaterial)
*/


(--START script
	
	struct MultiMat_To_SingleMat
	(
		
		--Members that will get values from outside the struct:
		allObjects,
		allMaterials,
		allMaterialNames,
		undefinedMatName,
		
		
		fn FN_MultiMat_To_SingleMat =
		/*
		If the object has a multimaterial with no valid subMaterial, this function replaces the multiMaterial with a single undefined material
		If the object has a multimaterial with a single valid subMaterial, this function promotes it to the object material (and removes the previous multiMaterial)
		*/
		(
			for theObject in allObjects where classOf theObject.material == Multimaterial do
			(
				--The original multiMaterial:
				theMat = theObject.material
				
				--To make it loop through slots, not use the highest ID, use materialList:
				matList = theMat.materialList
				
				--Collects subMats so that they can be counted later:
				subMats = #()
				
				--Loop through slots and collect materials:
				for currentSlot in 1 to matList.count do
				(
					--If the current slot contains a material, collect it:
					if matList[currentSlot] != undefined then append subMats matList[currentSlot]
				)
				
				--If there is no valid submaterial on the object:
				if subMats.count == 0 do
				(
					theMat = allMaterials[(findItem allMaterialNames undefinedMatName)]
					theObject.material = theMat
				)
				
				--If there is a single valid submaterial on the object:
				if subMats.count == 1 do
				(
					theMatName = subMats[1].name
					theMatIndex = (findItem allMaterialNames theMatName)
					theObject.material = allMaterials[theMatIndex]
				)
				
			)--END loop through objects
			
		)--END fn FN_MultiMat_To_SingleMat
		
	)--END struct MultiMat_To_SingleMat
	
)--END script