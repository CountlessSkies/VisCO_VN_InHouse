--Change Material ID`s
(--START script
	--Material ID LUT:
	local matIdLUT = ""
	local oldID_array = #()
	local newID_array = #()
	
	--START rollout_main:
	rollout rollout_main "Change Material ID`s"
	(
		group "Object Selection"
		(
			checkBox chkBox_includeSelected "Include selected objects" checked:true
			checkBox chkBox_includeNotSelected "Include non-selected objects" offset:[215,-20] checked: false
			checkBox chkBox_includeVisible "Include visible objects" checked:true
			checkBox chkBox_includeHidden "Include hidden objects" offset:[215,-20] checked: false
			checkBox chkBox_includeNotFrozen "Include non-frozen objects" checked:true
			checkBox chkBox_includeFrozen "Include frozen objects" offset:[215,-20] checked: false
		)
		group "Operation"
		(
			radiobuttons rBtn_operation "" \
			labels:#("Change all material ID`s", "Change individual material ID`s", "Change material ID`s based on LUT", "Propagate material ID`s past UVW modifiers", "Clear Script-added modifiers") \
			align:#left columns:2 default:1 offsets:#([0,0], [-20,0], [0,0], [-20,0], [0,0])
		)
		group "Action"
		(
			spinner spn_oldID "Current material ID" range:[1,9999999,1] type:#integer align:#left fieldWidth:30 enabled:false
			dropDownList drDwn_action "" items:#("change to", "Offset by") align:#left width:80 offset:[140,-24] enabled:true
			spinner spn_newOffsetID "material ID\value" range:[1,9999999,1] type:#integer align:#left fieldWidth:30 offset:[225,-24]
		)
		group "Look-up Table Settings"
		(
			button btn_openRollout_matIdLUT "Open Look-up table" align:#left enabled:false
			spinner spn_revertToID "ID`s not found in LUT default to: (0=keep existing ID)" range:[0,9999999,0] type:#integer align:#left fieldWidth:30 offset:[125,-23] enabled:false
		)
		group "Runtime Settings"
		(
			radioButtons rBtn_undo "Undo Level:" labels:#("None", "Hold", "Undo") align:#left default:2
			radiobuttons rBtn_saveExit "After Completion:" labels:#("Nothing", "Save", "Save and Exit") align:#left columns:3 offsets:#([0,0], [0,0], [-20,0]) offset:[180,-35]
			editText txt_savePath "Save Path:" fieldWidth:360 enabled:False
			button btn_browse "Browse" align:#left offset:[425,-25] enabled: False
			
		)
		group "Execute"
		(
			Button btn_execute "Execute" align:#left
			button btn_clearUndo "Clear Undo Buffer" align:#left offset:[60,-26]
		)
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		--Open LUT file:
		rollout rollout_matIdLUT "Material ID Look-up table"
		(
			label lbl_matIdLUT_1 "Template: old ID value = new ID value"
			editText txt_matIdLUT height:500 fieldWidth:250 align:#center text: matIdLUT
			button btn_saveMatIdLUT "Save Look-up table"
			on btn_saveMatIdLUT pressed do 
			(
				matIdLUT = txt_matIdLUT.text
				try (destroyDialog rollout_matIdLUT) catch()
			)
		)
		on btn_openRollout_matIdLUT pressed do createDialog rollout_matIdLUT 300 575
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		--Enable \ disable user interface elements:
		on rBtn_operation changed state do
		(
			if state == 1 do
			(
				spn_oldID.enabled = false
				drDwn_action.enabled = true
				spn_newOffsetID.enabled = true
				btn_openRollout_matIdLUT.enabled = false
				spn_revertToID.enabled = false
			)
			if state == 2 do
			(
				spn_oldID.enabled = true
				drDwn_action.enabled = true
				spn_newOffsetID.enabled = true
				btn_openRollout_matIdLUT.enabled = false
				spn_revertToID.enabled = false
			)
			if state == 3 do
			(
				spn_oldID.enabled = false
				drDwn_action.enabled = false
				spn_newOffsetID.enabled = false
				btn_openRollout_matIdLUT.enabled = true
				spn_revertToID.enabled = true
			)
			if state == 4 do
			(
				spn_oldID.enabled = false
				drDwn_action.enabled = false
				spn_newOffsetID.enabled = false
				btn_openRollout_matIdLUT.enabled = false
				spn_revertToID.enabled = false
			)
			if state == 5 do
			(
				spn_oldID.enabled = false
				drDwn_action.enabled = false
				spn_newOffsetID.enabled = false
				btn_openRollout_matIdLUT.enabled = false
				spn_revertToID.enabled = false
			)
		)
		
		on rBtn_saveExit changed state do
		(
			if state == 1 do
			(
				txt_savePath.enabled = False
				btn_browse.enabled = False
			)
			if state == 2 or state == 3 do
			(
				txt_savePath.enabled = True
				btn_browse.enabled = True
			)
		)
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		on btn_execute pressed do
		(
			setWaitCursor()
			with redraw off
			(
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--START function:
				fn fn_operation theObject opType action oldID newOffsetID revertToID = 
				(
					--Puts baseObject and its class in variables:
					local theObjectBase = theObject.baseObject
					local theClass = classOf theObjectBase
					
					--Modifier names. This is used in opType 4 and 5
					local beforeMod_name = "matID_UVW_before" 
					local bypassMod_name = "matID_UVW_bypass"
					
					--Counts faces and puts interfaces to get and set material ID`s in variables:
					local faceCount = 0
					local getIDinterface = undefined
					local setIDinterface = undefined
					local theObjectBaseMesh = undefined
					
					if opType == 1 or opType == 2 or opType == 3 do
					(
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
						--END Count faces and put interfaces to get and set material ID`s in variables
						
						
						for currentFace in 1 to faceCount do 
						(
							local currentID = undefined
							if (opType == 1 and action == 2) or (opType == 2) or (opType == 3) do \
							currentID = getIDInterface theObjectBaseMesh currentFace
							
							if opType == 1 do 
							(
								if action == 1 do currentID = 0
								setIDinterface theObjectBaseMesh currentFace (currentID+newOffsetID)
							)
							if opType == 2 and currentID == oldID do 
							(
								if action == 1 do currentID = 0
								setIDinterface theObjectBaseMesh currentFace (currentID+newOffsetID)
							)
							if opType == 3 do
							(
								--Find the current material IDs index number:
								local oldID_index = (findItem oldID_array currentID)
								--Set new ID to undefined by default:
								local newID = undefined
								--If the current ID exists in oldID_array, find the new ID it should have by the same index number in newID_array:
								if oldID_index != 0 do newID = newID_array[oldID_index]
								--If newID still is undefined (either since the current ID did not exist in oldID_array, or it was undefined in newID_array), then revert to default ID:
								if newID == undefined do newID = revertToID
								--If revertToID was 0, the face should keep its kurrent ID (do nothing), otherwise it should change the current face to new ID:
								if newID != 0 do setIDinterface theObjectBaseMesh currentFace newID
							)
						) --END for currentFace in 1 to faceCount 
					) --END if opType == 1 or opType == 2 or opType == 3 
					
					
					--opType 4 has to run its own per face operation, and cannot be part of the currentFace loop for opType 1, 2 and 3:
					if opType == 4 and (maxVersion())[1] >= 19000 do
					(
						getIDinterface = polyop.getFaceMatID
						setIDinterface = polyOp.setFaceMatID
						local faceCount = 0
						local matIDArray = #() --Contains all material IDs
						local faceIDArray = #() --Contains sub arrays with groups of faces. The Sub arrays are placed at the same index number as their corresponding material ID in matIDArray
						
						--Delete all modifiers that the script might have previously added:
						for modIndex in theObject.modifiers.count to 1 by -1 where \
							classOf theObject.modifiers[modIndex] == Edit_Poly and \
							( theObject.modifiers[modIndex].name == beforeMod_name or theObject.modifiers[modIndex].name == bypassMod_name ) \
							do deleteModifier theObject modIndex
						
						--Go through modifier stack and find each UVW modifier:
						for modIndex in theObject.modifiers.count to 1 by -1 where classOf theObject.modifiers[modIndex] == Unwrap_UVW do
						(
							--Add Edit Poly modifier below UVW_unwrap. This modifier provides the faceID list:
							local beforeMod =  ( Edit_Poly name: beforeMod_name)
							addModifier theObject beforeMod before:(modIndex)
							beforeMod.enabled = True
							
							--Add Edit Poly modifier above UVW_unwrap. This modifier recieves the faceID list:
							local bypassMod = ( Edit_Poly name: bypassMod_name )
							addModifier theObject bypassMod before:(modIndex-1)
							bypassMod.enabled = True
							
							--Disable all modifiers above and including the UVW mod in the stack.:
							for i in 1 to modIndex+1 do theObject.modifiers[i].enabled = false
							
							--Update the mesh:
							update(theObject)
							
							--Set theObjectBaseMesh and count faces:
							theObjectBaseMesh = theObject
							faceCount = polyOp.getNumFaces theObjectBaseMesh
							
							---------------------------------------------------------------
							for currentFace in 1 to faceCount do
							(
								--Get currentFace`s current material ID (currentID):
								currentID = getIDInterface theObjectBaseMesh currentFace
								
								--Go through faces to collect material IDs and corresponding faces. matIDArray contains all material IDs,
								--while faceIDArray contains sub arrays with groups of faces. The Sub arrays are placed at the same index number as their corresponding material ID in matIDArray: 
								matIDArrayIndex = (findItem matIDArray currentID)
								if matIDArrayIndex == 0 then
								(
									append matIDArray currentID
									append faceIDArray (#(currentFace))
								)
								else append faceIDArray[matIDArrayIndex] currentFace
							)
							
							---------------------------------------------------------------
							--SET NEW MATERIAL ID`S:
							--The following code is repeated once. Otherwise it seems to have problems setting the first material id in matIDArray correct.
							--As far as I understand, this is a bug in 3dsmax of some sort, since everything SEEMS to be working fine just by the fact that the exact code is repeated.
							--The code should work identical to the one found here: http://maxdebug.blogspot.no/2010/06/setselection-with-editpoly-modifier.html
							for i in 1 to 2 do
							(
								--Go into the right mode in the modify panel to prepare materialID editing:
								max modify mode
								select theObject
								modPanel.setCurrentObject theObject.modifiers[#matID_UVW_bypass]
								theObject.modifiers[#matID_UVW_bypass].SetEPolySelLevel #Face
								
								--Go through matIDArray, select corresponding faces in faceIDbitArray, and set their material ID:
								for i in 1 to matIDArray.count do
								(
									local faceIDbitArray = (faceIDArray[i] as bitArray) --faceIDArray converted to bitArray class
									
									theObject.modifiers[#matID_UVW_bypass].Select #Face faceIDbitArray
									theObject.modifiers[#matID_UVW_bypass].SetOperation #SetMaterial
									theObject.modifiers[#matID_UVW_bypass].MaterialIDtoSet = matIDArray[i]-1
									theObject.modifiers[#matID_UVW_bypass].commit()
									theObject.modifiers[#matID_UVW_bypass].SetSelection #Face #{}
								)
								
								--Make sure the object is fully "reset":
								if i == 2 do subobjectLevel = 0 --Take away the polygon suboject selection. Otherwise it will interfere with other polygon selections in the stack
								clearSelection()
								update(theObject)
								
							)--END for i in 1 to 2 loop
							---------------------------------------------------------------
							--Remove Edit_poly before UVW. This has to be done so the modIndex continues above the current UVW_unwrap modifier:
							deleteModifier theObject beforeMod
							
							clearSelection()
							for theMod in theObject.modifiers do theMod.enabled = true
							update(theObject)
							free matIDArray
							free faceIDArray
						)--END goind through each UVW_unwrap modifier in the stack
					) --END if opType==4
					
					if opType == 5 do
					(
						for modIndex in theObject.modifiers.count to 1 by -1 where \
							classOf theObject.modifiers[modIndex] == Edit_Poly and \
							( theObject.modifiers[modIndex].name == beforeMod_name or theObject.modifiers[modIndex].name == bypassMod_name ) \
							do deleteModifier theObject modIndex
					)--END if opType==5
					
					update(theObject)
				)--END function
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--START object selection:
				local allObjects = #()
				local nonInstancesArray = #()
				local duplicateObjectsArray = #()
				
				for obj = objects where \
				(if chkBox_includeSelected.checked == true or obj.isSelected == false then true else false) and \
				(if chkBox_includeNotSelected.checked == true or obj.isSelected == true then true else false) and \
				(if chkBox_includeHidden.checked == true or obj.isHidden == false then true else false) and \
				(if chkBox_includeVisible.checked == true or obj.isHidden == true then true else false) and \
				(if chkBox_includeFrozen.checked == true or obj.isFrozen == false then true else false) and \
				(if chkBox_includeNotFrozen.checked == true or obj.isFrozen == true then true else false) and \
				(classOf obj.baseObject == Editable_Poly or classOf obj.baseObject == Editable_Mesh) \
				do append allObjects obj
				
				--Deselcts objects:
				local preSelObjs = (for i in selection collect i)
				clearSelection()
				
				--Sort out instances of objects in the array:
				for obj in allObjects do
				(
					InstanceMgr.GetInstances obj &Instances
					if Instances.count == 1 then append nonInstancesArray obj else
					(
						if (findItem duplicateObjectsArray obj) == 0 do
						(
							append nonInstancesArray obj
							for i in Instances do append duplicateObjectsArray i
						)
					)
				)--END object selection
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--START clean up LUT and organize it into oldId_array and newID_array:
				free oldID_array
				free newID_array
				matIdLUT = matIdLUT as stringStream
				seek matIdLUT 0
				
				while (eof matIdLUT == false) do
				(
					--Reads a line:
					local currentLine = (readLine matIdLUT) as stringStream
					
					local oldID = readDelimitedString currentLine "=" --First part of the line is put into oldID
					local newID = readDelimitedString currentLine "=" --Second part of the line is put into newID
					
					--Eliminate spacing errors:
					oldID = (trimLeft (trimRight (toLower (oldID as string))))
					newID = (trimLeft (trimRight (toLower (newID as string))))
					
					--Converts to integer:
					oldID = (oldID as integer)
					newID = (newID as integer)
					
					--An empty string is returned as 0 when it is converted to integer. This changes it to undefined:
					if oldID == 0 do oldID = undefined
					if newID == 0 do newID = undefined
					
					--Puts oldID and newID into respective arrays, either as an integer value or undefined:
					append oldID_array oldID
					append newID_array newID
				)					
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				if rBtn_undo.state == 2 do holdMaxFile()
				if rBtn_undo.state == 1 or rBtn_undo.state == 2 do clearUndoBuffer()
				undo "Change material IDs" (rBtn_undo.state == 3)
				(
					if \
					(rBtn_saveExit.state == 2 or rBtn_saveExit.state == 3) and \
					((dotnetclass "System.IO.Directory").exists (getFilenamePath(txt_savePath.text))) == False \
					then MessageBox "Not a valid save path"
					else
					(
						--Loop through objects:
						for objIndex in 1 to nonInstancesArray.count do
						(
							fn_operation \
							nonInstancesArray[objIndex] rBtn_operation.state drDwn_action.selection spn_oldID.value spn_newOffsetID.value spn_revertToID.value
						)--END loop through objects
						
						--Save:
						if rBtn_saveExit.state != 1 do saveMaxFile(txt_savePath.text)
						--Messagebox Done:
						if rBtn_saveExit.state != 3 and rBtn_operation.state == 3 do MessageBox "Done"
						--Quit:
						if rBtn_saveExit.state == 3 do quitMax #noPrompt
					)
				)--END undo
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--Select objects that was selected before the script ran:
				select preSelObjs
			) --END with redraw off
			completeRedraw()
			setArrowCursor()			
		)--END btn_execute
		
		on btn_clearUndo pressed do clearUndoBuffer()
		
		on btn_browse pressed do 
		(
			filePath = getSaveFileName()
			if filePath == undefined then filePath = txt_savePath.text
			txt_savePath.text=filePath
		)
		
	)--END rollout_main
	createDialog rollout_main 500 395
)--END script