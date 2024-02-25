/*
MergeMats is a struct that takes materials, finds the ones with similar colors, and then instances those materials
*/

(--START script
	
	struct MergeMats
	(
		--Variables that are brought into the struct from the outside:
		allObjects,
		allMaterials,
		mergeValue,
		
		--Variables that the struct fills:
		reducedMatArray = #(),
		finished_multiMaterials = #(),
		
		------------------------------------------------------------------
		--Function to compare two material colors:
		fn CompareColors color1 color2 mergeValue =
		(
			mergeValue = 100-mergeValue --turn the mergeValue input around
			mergeValue *= (255/100.0) --convert from % to a 0-255 scale
			
			color1 = color1 as point3
			color2 = color2 as point3
			
			mergeColors = true
			for colChan in 1 to 3 do
			(
				if (color1[colChan] + mergeValue) < color2[colChan] do mergeColors = false
				if (color1[colChan] - mergeValue) > color2[colChan] do mergeColors = false
			)
			
			return mergeColors--Determine if the material colors should be merged or not
		),		
		
		------------------------------------------------------------------
		--Function to return the basecolor of the material:
		fn ReturnBaseColor theMaterial =
		--Just add more material classes and put their base color\diffuse color into the color variable. Remember to also add the material class to error checking
		(
			local baseColor
			
			if classOf theMaterial == PhysicalMaterial do baseColor = theMaterial.base_color
			if classOf theMaterial == StandardMaterial do baseColor = theMaterial.diffuse
			if classOf theMaterial == PBRMetalRough do baseColor = theMaterial.base_color
			
			return baseColor
		),
		
		------------------------------------------------------------------
		--SET COLORS TO BE THE SAME IF THEY ARE WITHIN COLOR TOLERANCE:
		
		fn SetSameColor =
		(
			for theMat in allMaterials do
			(
				--Set the color:
				theColor = (ReturnBaseColor theMat)
				
				--Loop through all  the other materials:
				for otherMat in allMaterials do
				(
					--Set the color:
					otherColor = (ReturnBaseColor otherMat)
					
					--Compare colors if both theColor and otherColor has been set:
					if (CompareColors otherColor theColor mergeValue) == true do otherMat.base_color = theMat.base_color
					
				)--END loop through all the other materials
				
			)--END loop through allMaterials
		),
		
		------------------------------------------------------------------
		--MERGE MATERIALS WITH IDENTICAL COLOR VALUE:
		
		fn MergeByColor =
		(
			--An array of materials with different colors only:
			--reducedMatArray = #()
			
			--A collection of multiMaterials that has already been worked on. This is to prevent uneccesary work if several objects share a multiMaterial:
			--finished_multiMaterials = #()
			
			----------------------------------------------------------------------------
			--Fill reducedMatArray
			for theMat in allMaterials do
			(
				--Set the color:
				theColor = (ReturnBaseColor theMat)
				
				--Check if a material with the same color already exist in the array:
				addToArray = true
				for otherMat in reducedMatArray do
				(
					--Set the color:
					otherColor = (ReturnBaseColor otherMat)
					if theColor == otherColor do addToArray = false
				)
				if addToArray == true do append reducedMatArray theMat
			)
			
			----------------------------------------------------------------------------
			--Change materials on the object to a material from the reduced material library:
			for obj in allObjects do
			(
				--Object has single material:
				if classOf obj.material != Multimaterial do
				(
					--Set the color:
					theColor = (ReturnBaseColor obj.material)
					
					for otherMat in reducedMatArray do
					(
						--Set the color:
						otherColor = (ReturnBaseColor otherMat)
						
						--If the color is the same, switch the object material to the material from reducedMatArray:
						if theColor == otherColor do obj.material = otherMat
					)
				)
				
				----------------
				--Object has multiMaterial:
				if classOf obj.material == Multimaterial and (findItem finished_multiMaterials obj.material)== 0 do
				(
					--Put the multiMaterial in the array finished_multiMaterials to prevent the script from working on it multiple times:
					append finished_multiMaterials obj.material
					
					--To make it loop through slots, not use the highest ID, use materialList:
					matList = obj.material.materialList
					
					--Loop through slots:
					for currentSlot in 1 to matList.count where matList[currentSlot] != undefined do
					(
						--Set the color:
						theColor = (ReturnBaseColor matList[currentSlot])
						
						for otherMat in reducedMatArray do
						(
							--Set the color:
							otherColor = (ReturnBaseColor otherMat)
							
							--If the color is the same, switch the object material to the material from reducedMatArray:
							if theColor == otherColor do matList[currentSlot] = otherMat
							
						)--END looping though materials in reducedMatArray
						
					)--END loop through material slots
					
				)--END if object has a multiMaterial
				
				----------------
				
			)--END looping though objects
			
			
			
			
			
		)--END fn MergeByColor
		
		------------------------------------------------------------------
		
		
	)--END struct MergeMats
	
)--END script