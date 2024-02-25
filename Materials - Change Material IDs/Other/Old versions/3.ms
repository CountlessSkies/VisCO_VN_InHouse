--Change Material ID`s
(--START script
	
	--Material ID LUT:
	local matIdLUT = ""
	local oldID_array = #()
	local newID_array = #()
	
	--START rollout_main:
	rollout rollout_main "Change Material ID`s"
	(
		group "Object selection"
		(
			checkBox chkBox_includeSelected "Include selected objects" checked:true
			checkBox chkBox_includeNotSelected "Include non-selected objects" offset:[240,-20]
			checkBox chkBox_includeVisible "Include visible objects" checked:true
			checkBox chkBox_includeHidden "Include hidden objects" offset:[240,-20]
			checkBox chkBox_includeNotFrozen "Include non-frozen objects" checked:true
			checkBox chkBox_includeFrozen "Include frozen objects" offset:[240,-20]
		)
		group "Choose operation"
		(
			radiobuttons rBtn_operation "" labels:#("Change all material ID`s", "Change individual material ID`s", "Change material ID`s based on look-up table (LUT)") align:#left columns:2
		)
		group "Action"
		(
			spinner spn_oldID "Current material ID" range:[1,9999999,1] type:#integer align:#left fieldWidth:30 enabled:false
			dropDownList drDwn_action "" items:#("change to", "Offset by") align:#left width:80 offset:[140,-24] enabled:true
			spinner spn_newOffsetID "material ID\value" range:[1,9999999,1] type:#integer align:#left fieldWidth:30 offset:[225,-24]
		)
		group "Look-up table settings"
		(
			button btn_openRollout_matIdLUT "Open Look-up table" align:#left enabled:false
			spinner spn_revertToID "Default ID: (0=keep existing)" range:[0,9999999,0] type:#integer align:#left fieldWidth:30 offset:[125,-23] enabled:false
		)
		group "Execute"
		(
			Button btn_execute "Execute" align:#left
			label lbl_Inf_1 "By Cameron AS Norway 2015" align:#center offset:[0,-22]
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
					
					--Counts faces and puts interfaces to get and set material ID`s in variables:
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
					)
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
				--Loop through objects:
				undo "Change material IDs" on
				(
					for objIndex in 1 to nonInstancesArray.count do
					(
						fn_operation \
						nonInstancesArray[objIndex] rBtn_operation.state drDwn_action.selection spn_oldID.value spn_newOffsetID.value spn_revertToID.value
					)--END loop through objects
				)--END undo
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--Select objects that was selected before the script ran:
				select preSelObjs
			) --END with redraw off
			completeRedraw()
			setArrowCursor()			
		)--END btn_execute
	)--END rollout_main
	createDialog rollout_main 500 300
	
)--END script