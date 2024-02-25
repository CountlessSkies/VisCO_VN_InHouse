(--Start script
	--Arrays:
	allObjects = #()
	nonInstancesArray = #()
	duplicateObjectsArray = #()
	-----------------------------------------------------------------------------------------------------------------------------------------------------
	--Functions:
	fn fn_operation theObject opType action oldID newOffsetID LUT prefixCurrentID txt_IDDelimiter prefixNewID EOLSuffix revertToID =
	( 
		theObjectBase = theObject.baseObject
		theClass = classOf theObjectBase
		--Interfaces to make the script run faster:
		local polyGetIDInterface = polyop.getFaceMatID
		local polySetIDInterface = polyOp.setFaceMatID
		local meshGetIDInterface = getFaceMatID
		local meshSetIDInterface = setFaceMatID
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		if opType == 1 do
		(
			if action == 1 do
			(
				if theClass == Editable_Poly do for currentFace = 1 to (polyOp.getNumFaces theObjectBase) do polySetIDInterface theObjectBase currentFace newOffsetID
				if theClass == Editable_mesh do for currentFace = 1 to (meshOp.getNumFaces theObjectBase) do meshSetIDInterface theObjectBase.mesh currentFace newOffsetID
			)
			
			if action == 2 do
			(
				if theClass == Editable_Poly do for currentFace = 1 to (polyOp.getNumFaces theObjectBase) do
				(
					local currentID = polyGetIDInterface theObjectBase currentFace
					polySetIDInterface theObjectBase currentFace (currentID + newOffsetID)
				)
				if theClass == Editable_mesh do for currentFace = 1 to (meshOp.getNumFaces theObjectBase) do
				(
					local currentID = meshGetIDInterface theObjectBase.mesh currentFace
					meshSetIDInterface theObjectBase.mesh currentFace (currentID + newOffsetID)
				)
			)
		)
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		if opType == 2 do
		(
			if action == 1 do
			(
				if theClass == Editable_Poly do for currentFace = 1 to (polyOp.getNumFaces theObjectBase) do 
				(
					local currentID = polyGetIDInterface theObjectBase currentFace
					if currentID == oldID do polySetIDInterface theObjectBase currentFace newOffsetID
				)
				if theClass == Editable_mesh do for currentFace = 1 to (meshOp.getNumFaces theObjectBase) do 
				(
					local currentID = meshGetIDInterface theObjectBase.mesh currentFace
					if currentID == oldID do meshSetIDInterface theObjectBase.mesh currentFace newOffsetID
				)
			)
			
			if action == 2 do
			(
				if theClass == Editable_Poly do for currentFace = 1 to (polyOp.getNumFaces theObjectBase) do
				(
					local currentID = polyGetIDInterface theObjectBase currentFace
					if currentID == oldID do polySetIDInterface theObjectBase currentFace (currentID + newOffsetID)
				)
				if theClass == Editable_mesh do for currentFace = 1 to (meshOp.getNumFaces theObjectBase) do
				(
					local currentID = meshGetIDInterface theObjectBase.mesh currentFace
					if currentID == oldID do meshSetIDInterface theObjectBase.mesh currentFace (currentID + newOffsetID)
				)
			)
		)
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		if opType == 3 do
		(
			--MAKE ARRAYS:
			faceID_arr = #()
			faceNR_topArr = #()
			
			--face count
			objectFaceCount
			if theClass == Editable_Poly do  objectFaceCount = polyOp.getNumFaces theObjectBase
			if theClass == Editable_Mesh do  objectFaceCount = getNumFaces theObjectBase.mesh
			
			for currentFace = 1 to objectFaceCount do
			(
				local currentID
				if theClass == Editable_Poly do currentID = polyGetIDInterface theObjectBase currentFace
				if theClass == Editable_Mesh do currentID = meshGetIDInterface theObjectBase.mesh currentFace
				
				faceID_arr_index = (findItem faceID_arr currentID)
				
				if faceID_arr_index == 0 then
				(--What happens when the currentID does not exist in faceID_arr:
					append faceID_arr currentID
					append faceNR_topArr (#(currentFace))
				)
				else
				(--What happens when the currentID exist in faceID_arr:
					append faceNR_topArr[faceID_arr_index] currentFace
				)
			)
			------------------------------------------------------------------
			--READ TEXT FILE AND CHANGE MATID ON ALL FACES:
			
			--Go through the whole faceID_arr to change faceNR
			for i = 1 to faceID_arr.count do
			(
				--Go to beginning of text file:
				seek LUT 0
				--Find the faceID string:
				tagExist = (skipToString LUT (prefixCurrentID + (faceID_arr[i] as string)))
				if tagExist == ok then
				(
					--Skip past comma:
					readChars LUT (txt_IDDelimiter.count)
					--Skip past the prefix for new IDs:
					readChars LUT prefixNewID.count
					--Read the new ID and save it in a variable
					local newID = (readDelimitedString LUT EOLSuffix) as integer
					--switch every faceNr that belongs to that ID to the new faceID in the variabel:
					if theClass == Editable_Poly do for currentFace = faceNR_topArr[i] do polySetIDInterface theObjectBase currentFace newID
					if theClass == Editable_Mesh do for currentFace = faceNR_topArr[i] do meshSetIDInterface theObjectBase.mesh currentFace newID
				)
				else
				(
					--what to do if the tag does NOT exist:
					local newID
					if revertToID == 0 then newID = faceID_arr[i] else newID = revertToID
					
					if theClass == Editable_Poly do for currentFace = faceNR_topArr[i] do polySetIDInterface theObjectBase currentFace newID
					if theClass == Editable_Mesh do for currentFace = faceNR_topArr[i] do meshSetIDInterface theObjectBase.mesh currentFace newID
				)
			)
			------------------------------------------------------------------
		)
	)
	-----------------------------------------------------------------------------------------------------------------------------------------------------
	rollout rollout_main "Change material ID"
	(--START Rollout
		group "Restrictions"
		(
			label lbl_res_2 "Works only on editable poly and editable mesh objects"
		)
		group "Objects to work on"
		(
			checkBox chkBox_includeSelected "Include selected objects" checked:true
			checkBox chkBox_includeNotSelected "Include non-selected objects"
			checkBox chkBox_includeHidden "Include hidden objects"
			checkBox chkBox_includeVisible "Include visible objects" checked:true
			checkBox chkBox_includeFrozen "Include frozen objects"
			checkBox chkBox_includeNotFrozen "Include non-frozen objects" checked:true
			editText txt_materialName "Work on objects with only this material name: (leave empty for all materials)" labelOnTop:true
		)
		group "Operation"
		(
			radiobuttons rBtn_operation "Choose operation" \
				labels:#("Change all material ID`s to another", "Change particular material ID`s to another", "Use a table in text file (LUT)") align:#left
		)
		group "Material ID`s"
		(
			radioButtons rBtn_action "Choose action" \
				labels:#("Change material ID`s", "Offset material ID`s") align:#left enabled:true
			spinner spn_oldID "Current material ID" range:[1,9999999,1] type:#integer align:#left enabled:false
			spinner spn_newOffsetID "New or offset material ID value" range:[1,9999999,1] type:#integer align:#left enabled:true
		)
		group "Look-up table"
		(
			editText txt_LUTPath "Look up table path: (Path\\\filename.fileSuffix)" labelOnTop:True text: "Z:\\Script\3dsmax\\Internal\\Change Face Material IDs\\table_example.txt" enabled:false
			editText txt_prefixCurrentID "Current ID table prefix" text:"currentID_" labelOnTop:True enabled:false
			editText txt_IDDelimiter "Delimiter between old ID and new ID" text:"," enabled:false
			editText txt_prefixNewID "New ID table prefix" text:"newID_" labelOnTop:True enabled:false
			editText txt_EOLSuffix "Suffix to mark the end of each line" text:";" enabled:false
			spinner spn_revertToID "non-existent ID in table get this ID: (0=keep existing)" range:[0,9999999,0] type:#integer align:#left enabled:false
		)
		group "Execution"
		(
			checkBox chk_printObjName "Print worked objects name in maxScript listener" checked:true
			Button btn_Execute "Execute"
		)
		group "Information"
		(
			label lbl_Inf_1 "By Cameron AS Norway 2014"
		)
		--Enable \ disable user interface elements:
		on rBtn_operation changed state do
		(
			if state == 1 do
			(
				rBtn_action.enabled = true
				spn_oldID.enabled = false
				spn_newOffsetID.enabled = true
				txt_LUTPath.enabled = false
				txt_prefixCurrentID.enabled = false
				txt_IDDelimiter.enabled = false
				txt_prefixNewID.enabled = false
				txt_EOLSuffix.enabled = false
				spn_revertToID.enabled = false
			)
			if state == 2 do
			(
				rBtn_action.enabled = true
				spn_oldID.enabled = true
				spn_newOffsetID.enabled = true
				txt_LUTPath.enabled = false
				txt_prefixCurrentID.enabled = false
				txt_IDDelimiter.enabled = false
				txt_prefixNewID.enabled = false
				txt_EOLSuffix.enabled = false
				spn_revertToID.enabled = false
			)
			if state == 3 do
			(
				rBtn_action.enabled = false
				spn_oldID.enabled = false
				spn_newOffsetID.enabled = false
				txt_LUTPath.enabled = true
				txt_prefixCurrentID.enabled = true
				txt_IDDelimiter.enabled = true
				txt_prefixNewID.enabled = true
				txt_EOLSuffix.enabled = true
				spn_revertToID.enabled = true
			)
		)
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		on btn_Execute pressed do
		(
			setWaitCursor()
			with redraw off
			(
				free allObjects
				free nonInstancesArray
				free duplicateObjectsArray
				local tableFile = undefined
				--Open text file:
				if rBtn_operation.state == 3 do tableFile = ( try( openFile (txt_LUTPath.text as string) ) catch (undefined) )
				
				--Sort objects:
				for obj = objects where \
				(if chkBox_includeSelected.checked == true or obj.isSelected == false then true else false) and \
				(if chkBox_includeNotSelected.checked == true or obj.isSelected == true then true else false) and \
				(if chkBox_includeHidden.checked == true or obj.isHidden == false then true else false) and \
				(if chkBox_includeVisible.checked == true or obj.isHidden == true then true else false) and \
				(if chkBox_includeFrozen.checked == true or obj.isFrozen == false then true else false) and \
				(if chkBox_includeNotFrozen.checked == true or obj.isFrozen == true then true else false) and \
				( if txt_materialName.text != "" then (try(obj.material.name == txt_materialName.text) catch false) else true ) and \
				superClassOf obj == GeometryClass and (classOf obj.baseObject == Editable_Poly or classOf obj.baseObject == Editable_Mesh) \
					do append allObjects obj
				
				--Sort out instances of objects in the array:
				for obj = allObjects do
				(
					InstanceMgr.GetInstances obj &Instances
					if Instances.count == 1 then append nonInstancesArray obj else
					(
						if (findItem duplicateObjectsArray obj) == 0 do
						(
							append nonInstancesArray obj
							for i = Instances do append duplicateObjectsArray i
						)
					)
				)
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--Function is run on a per object basis:
				undo "Change material ID" on
				(
					--Saves and deselects objects that are selected when the script runs:
					local preSelObjs = (for i = selection collect i)
					clearSelection()
					
					if rBtn_operation.state != 3 or tableFile != undefined then
					(
						--Run script on all objects that are not instances:
						for i = 1 to nonInstancesArray.count do
						(
							--Print object name if checked:
							if chk_printObjName.checked == true do print nonInstancesArray[i].name
							--Run operation on all objects:
							fn_operation \
							nonInstancesArray[i] rBtn_operation.state rBtn_action.state spn_oldID.value spn_newOffsetID.value tableFile txt_prefixCurrentID.text txt_IDDelimiter.text txt_prefixNewID.text txt_EOLSuffix.text spn_revertToID.value
						)
					)
					else messageBox "Table file not found or not readable"
					--Select objects that was selected before the script ran:
					select preSelObjs
				)
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--Close text file:
				if rBtn_operation.state == 3 do try (close tableFile) catch (messageBox "Text file not properly closed")
			)
			completeRedraw() 
		)--END Execute
	)--END Rollout
	createDialog rollout_main 400 825
)--End script