(--Start script
	--Arrays:
	allObjects = #()
	nonInstancesArray = #()
	duplicateObjectsArray = #()
	-----------------------------------------------------------------------------------------------------------------------------------------------------
	--Functions:
	fn fn_operation theObject opType action oldID newOffsetID LUT prefixCurrentID txt_IDDelimiter prefixNewID EOLSuffix revertToID =
	(
		theClass = classOf theObject
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
				if theClass == Editable_Poly do for currentFace = 1 to (getNumFaces theObject) do polySetIDInterface theObject currentFace newOffsetID
				if theClass == Editable_mesh do for currentFace = 1 to (getNumFaces theObject) do meshSetIDInterface theObject.mesh currentFace newOffsetID
			)
			
			if action == 2 do
			(
				if theClass == Editable_Poly do for currentFace = 1 to (getNumFaces theObject) do
				(
					local currentID = polyGetIDInterface theObject currentFace
					polySetIDInterface theObject currentFace (currentID + newOffsetID)
				)
				if theClass == Editable_mesh do for currentFace = 1 to (getNumFaces theObject) do
				(
					local currentID = meshGetIDInterface theObject currentFace
					meshSetIDInterface theObject.mesh currentFace (currentID + newOffsetID)
				)
			)
		)
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		if opType == 2 do
		(
			if action == 1 do
			(
				if theClass == Editable_Poly do for currentFace = 1 to (getNumFaces theObject) do 
				(
					local currentID = polyGetIDInterface theObject currentFace
					if currentID == oldID do polySetIDInterface theObject currentFace newOffsetID
				)
				if theClass == Editable_mesh do for currentFace = 1 to (getNumFaces theObject) do 
				(
					local currentID = meshGetIDInterface theObject currentFace
					if currentID == oldID do meshSetIDInterface theObject.mesh currentFace newOffsetID
				)
			)
			
			if action == 2 do
			(
				if theClass == Editable_Poly do for currentFace = 1 to (getNumFaces theObject) do
				(
					local currentID = polyGetIDInterface theObject currentFace
					if currentID == oldID do polySetIDInterface theObject currentFace (currentID + newOffsetID)
				)
				if theClass == Editable_mesh do for currentFace = 1 to (getNumFaces theObject) do
				(
					local currentID = meshGetIDInterface theObject currentFace
					if currentID == oldID do meshSetIDInterface theObject.mesh currentFace (currentID + newOffsetID)
				)
			)
		)
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		if opType == 3 do
		(
			--MAKE ARRAYS:
			faceID_arr = #()
			faceNR_topArr = #()
			
			for currentFace = 1 to (getNumFaces theObject) do
			(
				local currentID
				if theClass == Editable_Poly do currentID = polyGetIDInterface theObject currentFace
				if theClass == Editable_Mesh do currentID = meshGetIDInterface theObject currentFace
				
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
					if theClass == Editable_Poly do for currentFace = faceNR_topArr[i] do polySetIDInterface theObject currentFace newID
					if theClass == Editable_Mesh do for currentFace = faceNR_topArr[i] do meshSetIDInterface theObject.mesh currentFace newID
				)
				else
				(
					--what to do if the tag does NOT exist:
					local newID
					if revertToID == 0 then newID = faceID_arr[i] else newID = revertToID
					
					if theClass == Editable_Poly do for currentFace = faceNR_topArr[i] do polySetIDInterface theObject currentFace newID
					if theClass == Editable_Mesh do for currentFace = faceNR_topArr[i] do meshSetIDInterface theObject.mesh currentFace newID
				)
			)
			------------------------------------------------------------------
		)
	)
	-----------------------------------------------------------------------------------------------------------------------------------------------------
	rollout rollout_main "Change material ID"
	(--START Rollout
		group "How to use"
		(
			label lbl_1 "Works only on editable poly and editable mesh"
			label lbl_2 "There can be no modifiers on the objects"
		)
		group "Objects to work on"
		(
			radiobuttons rBtn_objectSet "Choose objects" labels:#("All", "Selection") align:#left default:2
			checkBox chkBox_includeHidden "Include hidden objects"
			checkBox chkBox_includeFrozen "Include frozen objects" checked:true
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
			editText txt_LUTPath "Look up table path: (Path\\\filename.fileSuffix)" labelOnTop:True text: "Z:\\Script\3dsmax\\Internal\\Change matID on selection\\table_example.txt" enabled:false
			editText txt_prefixCurrentID "Current ID table prefix" text:"currentID_" labelOnTop:True enabled:false
			editText txt_IDDelimiter "Delimiter between old ID and new ID" text:"," enabled:false
			editText txt_prefixNewID "New ID table prefix" text:"newID_" labelOnTop:True enabled:false
			editText txt_EOLSuffix "Suffix to mark the end of each line" text:";" enabled:false
			spinner spn_revertToID "IDs that does not exist in table get this ID: (0=keep existing)" range:[0,9999999,0] type:#integer align:#left enabled:false
		)
		group "Execution"
		(
			Button btn_Execute "Execute"
			CheckButton chkBtn_Stop "Stop"
		)
		group "Progress on per object basis"
		(
			progressBar prBar 
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
			free allObjects
			free nonInstancesArray
			free duplicateObjectsArray
			local tableFile = undefined
			--Open text file:
			if rBtn_operation.state == 3 do tableFile = openFile (txt_LUTPath.text as string)
			
			--Sort objects:
			for obj = objects where \
				(obj.isSelected == true or rBtn_objectSet.state == 1) and \
				(obj.isHidden == false or chkBox_includeHidden.checked == true) and (obj.isFrozen == false or chkBox_includeFrozen.checked == true) and \
				( if txt_materialName.text != "" then (try(obj.material.name == txt_materialName.text) catch false) else true ) and \
				superClassOf obj == GeometryClass and obj.modifiers.count == 0 and \ 
				(classOf obj == Editable_Poly or classOf obj == Editable_Mesh) \
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
				
				--Run script on all objects that are not instances:
				for i = 1 to nonInstancesArray.count while chkBtn_Stop.checked != true do
				(
					--Run operation on all objects:
					fn_operation \
					nonInstancesArray[i] rBtn_operation.state rBtn_action.state spn_oldID.value spn_newOffsetID.value tableFile txt_prefixCurrentID.text txt_IDDelimiter.text txt_prefixNewID.text txt_EOLSuffix.text spn_revertToID.value
					--Progressbar update:
					tot = nonInstancesArray.count
					prBar.value = (i/tot)*100
					--Halt a moment to let the progressbar update:
					
				)
				--Select objects that was selected before the script ran:
				select preSelObjs
			)
			-----------------------------------------------------------------------------------------------------------------------------------------------------
			--Close text file:
			if rBtn_operation.state == 3 do try (close tableFile) catch (messageBox "Text file not properly closed")
		)--END Execute
	)--END Rollout
	createDialog rollout_main 400 750
)--End script