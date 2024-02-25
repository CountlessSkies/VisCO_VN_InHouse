(--START SCRIPT
local orgArray = #()
local forArray = #()
local copiedObjects = #()
local originalObjects = #()
local newArray = #()

rollout rollout_top "Find Similar Objects"
	(
		subRollout subRollout_params "Parameters"
	)
	
rollout rollout_main "Select similar objects"
(--Start rollout
	--START Interface------------------------------------------------------------------------------------------------------------------------
	Group "BEFORE YOU START"
	(
		label lbl_before_1 "When a checkbox is marked as deprecated,"
		label lbl_before_2 "you should be extra careful before checking it"
	)
	Group "OBJECTS TO FIND COPIES OF"
	(
		checkBox chkBox_org_includeSelected "Include selected objects" checked:true
		checkBox chkBox_org_includeNotSelected "Include not selected objects" checked:true
		checkBox chkBox_org_includeHidden "Include hidden objects" checked:true
		checkBox chkBox_org_includeVisible "Include visible objects" checked:true
		checkBox chkBox_org_includeFrozen "Include frozen objects" checked:true
		checkBox chkBox_org_includeNotFrozen "Include not frozen objects" checked:true
		checkBox chkBox_org_includeNewArray "Include objects in new array" checked:true
		checkBox chkBox_org_includeNotNewArray "Include objects not in new array" checked:true
		button btn_objToOrgArray "Save"
		label lbl_objToFindCopiesOf_1 "Must be executed each time there is"
		label lbl_objToFindCopiesOf_2 "a change in settings or the scene"
		editText txt_org_count "Objects in array:" readOnly:true
	)
	Group "OBJECTS TO SEARCH THROUGH"
	(
		checkBox chkBox_for_includeSelected "Include selected objects" checked:true
		checkBox chkBox_for_includeNotSelected "Include not selected objects" checked:true
		checkBox chkBox_for_includeHidden "Include hidden objects" checked:true
		checkBox chkBox_for_includeVisible "Include visible objects" checked:true
		checkBox chkBox_for_includeFrozen "Include frozen objects" checked:true
		checkBox chkBox_for_includeNotFrozen "Include not frozen objects" checked:true
		checkBox chkBox_for_includeNewArray "Include objects in new array" checked:true
		checkBox chkBox_for_includeNotNewArray "Include objects not in new array" checked:true
		button btn_objToForArray "Save"
		label lbl_objToSearchThorugh_1 "Must be executed each time there is"
		label lbl_objToSearchThorugh_2 "a change in settings or the scene"
		editText txt_for_count "Objects in array:" readOnly:true
	)
	Group "SEARCH PARAMETERS"
	(
		checkBox chkBox_similarName "Similar object names" checked:true
		checkBox chkBox_similarMaterialName "Similar material names"
		checkBox chkBox_faceCount "Polys and mesh: Similar face count" checked:true
		checkBox chkBox_vertexCount "Polys and mesh: Similar vertex count"
		label lbl_searchParams_1 ""
		checkBox chkBox_withinRadius "Similar objects pivot is within radius:" checked:true
		spinner spn_withinRadius "Radius:" range:[0,99999999,1] align:#left
		label lbl_searchParams_2 "Set spinner to zero for no deviation from original object" align:#left
		label lbl_searchParams_3 ""
		checkBox chkBox_boundingBoxSize "Bounding box size is within XYZ-offset:" checked:true
		spinner spn_boundingBoxSizeOffset "Offset" range:[0,99999999,1] align:#left
		label lbl_searchParams_4 "Set spinner to zero for no deviation from original object" align:#left
		label lbl_searchParams_5 ""
		checkBox chkBox_boundingBoxCenter "Bounding box center position is within XYZ-offset:" checked:true
		spinner spn_boundingBoxCenterOffset "Offset" range:[0,99999999,1] align:#left
		label lbl_searchParams_6 "Set spinner to zero for no deviation from original object" align:#left
		label lbl_searchParams_7 ""
	)
	
	Group "ACTION FOR SIMILAR OBJECTS"
	(
		radioButtons rBtn_do  labels:#("Append sorted objects to new array", "Select sorted objects", "Delete sorted objects (deprecated)") align:#left
	)
	Group "ACTION FOR ORIGINAL OBJECT"
	(
		checkBox chk_includeOrgObj "Include original object (deprecated)" align:#left
		label lbl_action_org_2 "Usually, the script excludes the original object in a" align:#left
		label lbl_action_org_3 "collection of similar objects. By checking this," align:#left
		label lbl_action_org_4 "the original object will also be included in the actions" align:#left
	)
	Group "ACTION FOR OBJECTS IN NEW ARRAY"
	(
		checkBox chk_preserveObjects "Keep existing objects in new array (deprecated)" align:#left
		label lbl_action_newArray_1 "Usually, the new array is emptied when a search" align:#left
		label lbl_action_newArray_2 "is performed. By checking this, new array will keep" align:#left
		label lbl_action_newArray_3 "the objects it held from before, and add the new as well" align:#left
	)
	Group "SEARCH"
	(
		button btn_execute "Execute search"
		label lbl_search_1 "Must be executed each time there is a change"
		label lbl_search_2 "in settings or the scene"
	)
	Group "SELECTION OPERATIONS"
	(
		Button btn_selectedInNewArray "Put selected objects in new array"
		label lbl_selectionOp_1 "Select your own objects to put in new array"
	)
	Group "NEW ARRAY OPERATIONS"
	(
		Button btn_array_select "Select objects in new array" align:#left
		Button btn_array_delete "Delete objects in new array" align:#left
		Button btn_array_clear "Empty new array list" align:#left
	)
	Group "PRINT NEW ARRAY"
	(
		editText txt_newArrayCount "Number of objects in New Array" readOnly:True
		Button btn_array_print "Print information to listener" align:#left
		radioButtons rBtn_printOptions labels:#("Print names", "Print extended information") align:#left default:2
	)
	Group "INFO"
	(
		label lbl_info_1 "Cameron Sense AS 2014"
	)
	--END Interface------------------------------------------------------------------------------------------------------------------------
	
	------------------------Append scene objects to orgArray (OBJECTS TO FIND COPIES OF):---------------
	on btn_objToOrgArray pressed do
	(
		free orgArray
		
		for obj = objects where \
		(if obj.isSelected == false or chkBox_org_includeSelected.checked == true then true else false) and \
		(if obj.isSelected == true or chkBox_org_includeNotSelected.checked == true then true else false) and \
		(if obj.isHidden == false or chkBox_org_includeHidden.checked == true then true else false) and \
		(if obj.isHidden == true or chkBox_org_includeVisible.checked == true then true else false) and \ 
		(if obj.isFrozen == false or chkBox_org_includeFrozen.checked == true then true else false) and \
		(if obj.isFrozen == true or chkBox_org_includeNotFrozen.checked == true then true else false) and \
		(if (findItem newArray obj) == 0 or chkBox_org_includeNewArray.checked == true then true else false) and \
		(if (findItem newArray obj) != 0 or chkBox_org_includeNotNewArray.checked == true then true else false)
		do append orgArray obj
		
		txt_org_count.text = orgArray.count as string
	)
	------------------------Append scene objects to forArray (OBJECTS TO SEARCH THROUGH):---------------
	on btn_objToForArray pressed do
	(
		free forArray
		
		for obj = objects where \
		(if obj.isSelected == false or chkBox_for_includeSelected.checked == true then true else false) and \
		(if obj.isSelected == true or chkBox_for_includeNotSelected.checked == true then true else false) and \
		(if obj.isHidden == false or chkBox_for_includeHidden.checked == true then true else false) and \
		(if obj.isHidden == true or chkBox_for_includeVisible.checked == true then true else false) and \ 
		(if obj.isFrozen == false or chkBox_for_includeFrozen.checked == true then true else false) and \
		(if obj.isFrozen == true or chkBox_for_includeNotFrozen.checked == true then true else false) and \
		(if (findItem newArray obj) == 0 or chkBox_for_includeNewArray.checked == true then true else false) and \
		(if (findItem newArray obj) != 0 or chkBox_for_includeNotNewArray.checked == true then true else false)
		do append forArray obj
		
		txt_for_count.text = forArray.count as string
	)
	------------------------------------------START EXECUTE-----------------------------------------------------.
	on btn_execute pressed do
	(
		setWaitCursor()
		with reDraw off
		selectedObj = (for i = selection collect i)
		clearSelection()
		if chk_preserveObjects.checked != true do free newArray
		local copyOriginal = false
		---------------------------------Functions to speed up the sorting operations----------------------------
		fn getBoundingBoxSize obj =
		(
			result
			boundingBox = nodeLocalBoundingBox
			result = (boundingBox obj)[2] - (boundingBox obj)[1]
		)
		
		fn getBoundingBoxCenter obj =
		(
			result
			a = nodeGetBoundingBox obj (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
			result = (a[1] + a[2])/2
		)
		
		fn getNumFunction operation obj = 
		(
			result
			numFaces = getNumFaces
			numVertices = getNumVerts
			if operation == "faces" do result = numFaces obj
			if operation == "vertices" do result = numVertices obj
			result
		)
		
		fn fn_getClass obj =
		(
			result = classOf obj
		)
		--------------------------------------Run sorting operations-----------------------		
		for index = orgArray.count to 1 by -1 where (findItem copiedObjects orgArray[index]) == 0 do
		(
			copyOriginal = false
			for j = forArray where j != orgArray[index] and \
			(chkBox_similarName.checked == false or j.name == orgArray[index].name) and \
			(chkBox_similarMaterialName.checked == false or (if j.material != undefined and orgArray[index].material != undefined then orgArray[index].material.name == j.material.name else false)) and \
			(chkBox_withinRadius.checked == false or (distance j orgArray[index]) <= spn_withinRadius.value) and \
			(
				chkBox_boundingBoxSize.checked == false or
				(
					(getBoundingBoxSize orgArray[index] - getBoundingBoxSize j).x >= -spn_boundingBoxSizeOffset.value and \
					(getBoundingBoxSize orgArray[index] - getBoundingBoxSize j).y >= -spn_boundingBoxSizeOffset.value and \
					(getBoundingBoxSize orgArray[index] - getBoundingBoxSize j).z >= -spn_boundingBoxSizeOffset.value and \
					(getBoundingBoxSize orgArray[index] - getBoundingBoxSize j).x <= spn_boundingBoxSizeOffset.value and \
					(getBoundingBoxSize orgArray[index] - getBoundingBoxSize j).y <= spn_boundingBoxSizeOffset.value and \
					(getBoundingBoxSize orgArray[index] - getBoundingBoxSize j).z <= spn_boundingBoxSizeOffset.value
				)
			) and \
			(
				chkBox_boundingBoxCenter.checked == false or
				(
					(getBoundingBoxCenter orgArray[index] - getBoundingBoxCenter j).x >= -spn_boundingBoxCenterOffset.value and \
					(getBoundingBoxCenter orgArray[index] - getBoundingBoxCenter j).y >= -spn_boundingBoxCenterOffset.value and \
					(getBoundingBoxCenter orgArray[index] - getBoundingBoxCenter j).z >= -spn_boundingBoxCenterOffset.value and \
					(getBoundingBoxCenter orgArray[index] - getBoundingBoxCenter j).x <= spn_boundingBoxCenterOffset.value and \
					(getBoundingBoxCenter orgArray[index] - getBoundingBoxCenter j).y <= spn_boundingBoxCenterOffset.value and \
					(getBoundingBoxCenter orgArray[index] - getBoundingBoxCenter j).z <= spn_boundingBoxCenterOffset.value
				)
			) and \
			(chkBox_faceCount.checked == false or ((fn_getClass j == Editable_Poly or fn_getClass j == Editable_mesh) and fn_getClass j == fn_getClass orgArray[index] and getNumFunction "faces" j == getNumFunction "faces" orgArray[index]) ) and \
			(chkBox_vertexCount.checked == false or ((fn_getClass j == Editable_Poly or fn_getClass j == Editable_mesh) and fn_getClass j == fn_getClass orgArray[index] and getNumFunction "vertices" j == getNumFunction "vertices" orgArray[index]) ) \
			do 
			(
				appendIfUnique copiedObjects j
				copyOriginal = true
			)
			if chk_includeOrgObj.checked == true and copyOriginal == true do appendIfUnique originalObjects orgArray[index]
		)
		--------------------------------------------------------------------------------------
		if rBtn_do.state == 1 do for i = copiedObjects do appendIfUnique newArray i
		if rBtn_do.state == 2 do select copiedObjects
		if rBtn_do.state == 3 do for i = copiedObjects.count to 1 by -1 do delete copiedObjects[i]
		if chk_includeOrgObj.checked == true do for i = originalObjects do appendIfUnique newArray i
		--------------------------------------------------------------------------------------
		txt_newArrayCount.text = newArray.count as string
		--------------------------------------------------------------------------------------
		free copiedObjects
		free originalObjects
		select selectedObj
		redrawViews()
		setArrowCursor()
	)--END Execute
	------------------------------------------SELECTION OPERATIONS-------------------------------------------------------------------------------
	on btn_selectedInNewArray pressed do 
	(
		for i = selection do appendIfUnique newArray i
		txt_newArrayCount.text = newArray.count as string
	)
	------------------------------------------ NEW ARRAY OPERATIONS: --------------------------------------------------------------------------------
	on btn_array_select pressed do select newArray
	on btn_array_delete pressed do
	(
		for i = newArray.count to 1 by -1 do delete newArray[i]
		free newArray
	)
	on btn_array_clear pressed do free newArray
	on btn_array_print pressed do
	(
		if rBtn_printOptions.state == 1 do for i = newArray do print i.name
		if rBtn_printOptions.state == 2 do for i = newArray do print i
	)
)--End rollout
createDialog rollout_top 330 800
addSubRollout rollout_top.subRollout_params rollout_main
	rollout_top.subRollout_params.height = 800
)--END SCRIPT