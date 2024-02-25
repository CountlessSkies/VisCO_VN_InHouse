rollout rollout_main "Collect Scene Materials"
(	
	group "Script functionality overview"
	(
		button btn_overview "functionality overview" toolTip:"Read this if this is the first time you use the script."
	)
	group "MATERIAL EDITOR SETTINGS"
	(
		button btn_matEditorSettings_help "Help" align:#left
		spinner spn_matsPerSlot "Materials per slot:" range:[1,150,25] type:#integer 
		spinner spn_slotsAvailable "Number of material editor slots to keep open:" range: [0,24,1] type:#integer 
		spinner spn_defaultSlot "Default slot: (Recommended: 1)" range: [1,24,1] type:#integer 
		editText txt_slotName "Common material names: (will be numbered at the end)" text: "sceneMaterials_" 
		editText txt_undefinedMatName "Undefined materials contain this string in name:" text: "material #" 
	)
	group "OBJECT SELECTION"
	(
		button btn_objectSelection_help "Help" align:#left
		checkBox chkBox_org_includeSelected "Include selected objects" checked:true align:#center
		checkBox chkBox_org_includeNotSelected "Include not selected objects" checked:true align:#center
		checkBox chkBox_org_includeHidden "Include hidden objects" checked:true align:#center
		checkBox chkBox_org_includeVisible "Include visible objects" checked:true align:#center
		checkBox chkBox_org_includeFrozen "Include frozen objects" checked:true align:#center
		checkBox chkBox_org_includeNotFrozen "Include not frozen objects" checked:true align:#center
		button btn_collectObjects "Collect objects" align:#center
	)
	group "OBJECT ORDER"
	(
		button btn_objectOrder_help "Help" align:#left
		radioButtons rBtn_objectSort  labels:#("Default", "Face count", "Material count")
		radioButtons rBtn_sortOrder  labels:#("Ascending", "Descending")
		button btn_newOrder "Sort objects in new order"
		button btn_printOrder "Print the new object order"
	)
	group "AFTER EXECUTION"
	(
		checkbox chk_clearSlots "Clear material slots"
		checkbox chk_saveScene "Save scene"
		editText txt_savePath "save path"
		checkbox chk_close3dsmax "Close 3dsmax"
	)
	group "EXECUTE"
	(
		button btn_execute_help "Help" align:#left
		label lbl_execute_1 "Script actions cannot be undone. Backup first!"
		label lbl_execute_2 "For first time users, read the functionality overview first."
		label lbl_execute_3 ""
		button btn_gatherMaterials "Collect scene materials"
		button btn_selectNonWorkedObjects "Select objects that was not worked"
	)
	Group "INFO"
	(
		label lbl_info_1 "Cameron"
		label lbl_info_2 "Norway 2014"
	)
	
	
	
	rollout rollout_functionality "Functionality and overview"
	(
		label lbl_info_1 "The script will:" align:#left
		label lbl_info_2 "*Clear material editor" align:#left
		label lbl_info_3 "*Sort out similar materials, based on their names" align:#left
		label lbl_info_4 "*Divide object materials on all material slots, based on the user settings" align:#left
		label lbl_info_5 "*Reassign material IDs on objects to accomodate the new material scheme" align:#left
		label lbl_info_6 "*Keep one or more of the last material slots in the editor open, based on user input" align:#left
		label lbl_info_7 "" align:#left
		label lbl_info_8 "Script limitations:" align:#left
		label lbl_info_9 "*Only works on mesh and poly objects. Run the script convert to poly to handle this" align:#left
		label lbl_info_10 "*The scene should not contain referenced objects. Run the script convert to poly to handle this" align:#left
		label lbl_info_11 "*Object instances should have the same material applied (Default from Inventor)" align:#left
		label lbl_info_12 "*Materials with a particular name string will be collected in a single slot and named undefinedMat." align:#left
		label lbl_info_13 "This is to handle the massive amount of materials from Inventor which is just gray." align:#left
		label lbl_info_14 "*Script actions cannot be undone because of memory limitations. Backup first!" align:#left
		label lbl_info_15 "" align:#left
		label lbl_info_16 "Notes:" align:#left
		label lbl_info_17 "*The script might use up to an hour on large scenes" align:#left
		label lbl_info_18 "*Editable meshes sometimes have a problem to update its visual apperance in the viewport" align:#left
		label lbl_info_19 "after changing its material ID`s. This is a problem with the mesh class object, not the script." align:#left
		label lbl_info_20 "Try to save and reload the scene to fix this." align:#left
		label lbl_info_21 "" align:#left
	)
		
	rollout rollout_matEditorSettings_help "Material editor settings help"
	(
		label lbl_info_1 "*Materials per slot indicate how many materials you want in each created multiSub material." align:#left
		label lbl_info_2"More materials in each slot will slow down performance, while fewer will force the script to distribute" align:#left
		label lbl_info_3 "materials on more slots. It also means that some complex object with many materials might" align:#left
		label lbl_info_4 "not fit into a slot, and it will be forced to be dumped in the default material slot." align:#left
		label lbl_info_5 "" align:#left
		label lbl_info_6 "*Default slot is the slot that the script will assign to all objects that for some reason does not fit" align:#left
		label lbl_info_7 "into any other slot. A typical example is when materials per slot is set lower than the number of submaterials in the object." align:#left
		label lbl_info_8 "This object will then be assigned to the default slot." align:#left
		label lbl_info_9 "Default slot does not take maximum number of materials per slot setting into account" align:#left
		label lbl_info_10 "" align:#left
		label lbl_info_11 "*Common material names is the name each created multiSub material will have. It will be numbered at the end." align:#left
		label lbl_info_12 ""
		label lbl_info_13 "*Undefined material contains this string means that any material name that contains this spesific string somewhere in its name" align:#left
		label lbl_info_14 "will be put in a common submaterial slot. This is to handle the large amount of grey materials that Inventor assigns" align:#left
		label lbl_info_15 "as default to objects that the Inventor operator have not assigned a particular material." align:#left
	)
	
	rollout rollout_objectSelection_help "Object selection help"
	(
		label lbl_info_1 "*This is to enable the operator to sort objects based on different parameters." align:#left
		label lbl_info_2 "The operator can use this as a way to exclude or include objects to work on by" align:#left
		label lbl_info_3 "hiding, selecting or freezing objects that he does or does not want to work on." align:#left
		label lbl_info_4 "The operator needs to collect objects by pressing the collect objects button." align:#left
		label lbl_info_5 "This is so he can choose a different sorting order before running the script" align:#left
	)
	
	rollout rollout_objectOrder_help "Object order help"
	(
		label lbl_info_1 "*The object order indicates the order it will work through objects to collect materials." align:#left
		label lbl_info_2 "If objects that have many materials is worked through first, the script might be able to" align:#left
		label lbl_info_3 "gather all those objects into a single slot. When the script later works on objects with just one" align:#left
		label lbl_info_4 "or two materials, they might also fit into a already created slot." align:#left
		label lbl_info_5 "If objects with few materials is worked first, the later objects with many materials" align:#left
		label lbl_info_6 "might have difficulty fitting into an already created slot and will be forced to create a new one." align:#left
		label lbl_info_7 "" align:#left
		label lbl_info_8 "*Sometimes the operator wants to have large objects prioritized, which is why he also" align:#left
		label lbl_info_9 "can sort by face count" align:#left
		label lbl_info_10 "" align:#left
		label lbl_info_11 "*The default order is usually the order which the objects where created in Inventor." align:#left
		label lbl_info_12 "That means the objects that belong together usually will be put in the same slot." align:#left
	)
	
	rollout rollout_execute_help "Execute help"
	(
		label lbl_info_1 "*Execute the script." align:#left
		label lbl_info_2 "Make sure that you have a backup of the scene first, since the script is not undoable." align:#left
		label lbl_info_3 "Let us know about any bugs or problems you encounter by leaving a" align:#left
		label lbl_info_4 "text document in the script folder with a problem description and your name." align:#left
	)
	---------END----------------------------------------USER INTERFACE------------------------------------------------------------------------
	
	--------START---------------------------------SCRIPT FUNCTIONALITY OVERVIEW BUTTON--------------------------------------------
	on btn_overview pressed do
	(
		try (destroyDialog rollout_functionality) catch()
		createDialog rollout_functionality 500 450
	)
	
	on btn_matEditorSettings_help pressed do
	(
		try (destroyDialog rollout_matEditorSettings_help) catch()
		createDialog rollout_matEditorSettings_help 650 350
	)
	
	on btn_objectSelection_help pressed do
	(
		try (destroyDialog rollout_objectSelection_help) catch()
		createDialog rollout_objectSelection_help 400 150
	)
	
	on btn_objectOrder_help pressed do
	(
		try (destroyDialog rollout_objectOrder_help) catch()
		createDialog rollout_objectOrder_help 500 250
	)
	
	on btn_execute_help pressed do
	(
		try (destroyDialog rollout_execute_help) catch()
		createDialog rollout_execute_help 500 100
	)
	
	--------END---------------------------------SCRIPT FUNCTIONALITY OVERVIEW BUTTON--------------------------------------------
	
	
	---------START---------------------------------------COLLECT OBJECTS------------------------------------------------------------------------
	local objArray = #()
	local nonInstancesArray = #()
	local duplicateObjectsArray = #()
	local nonInstancesArrayCopy = #() --Keeps a copy of nonInstancesArray in the original order
	
	on btn_collectObjects pressed do
	(
		free objArray
		free nonInstancesArray
		free duplicateObjectsArray
		free nonInstancesArrayCopy
		
		--Gather all objects:
		for obj = objects where \
		(if obj.isSelected == false or chkBox_org_includeSelected.checked == true then true else false) and \
		(if obj.isSelected == true or chkBox_org_includeNotSelected.checked == true then true else false) and \
		(if obj.isHidden == false or chkBox_org_includeHidden.checked == true then true else false) and \
		(if obj.isHidden == true or chkBox_org_includeVisible.checked == true then true else false) and \ 
		(if obj.isFrozen == false or chkBox_org_includeFrozen.checked == true then true else false) and \
		(if obj.isFrozen == true or chkBox_org_includeNotFrozen.checked == true then true else false) and \
		superClassOf obj == geometryClass and (classOf obj.baseObject == editable_poly or classOf obj.baseObject == editable_mesh) and \
		(obj.material != undefined)
		do append objArray obj
		
		--Sort out instances:
		for obj = objArray do
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
		
		--Copies the nonInstancesArray:
		nonInstancesArrayCopy = deepCopy nonInstancesArray
	)
	---------END-----------------------------------------COLLECT OBJECTS------------------------------------------------------------------------
	
	

	---------START---------------------------------------SORT OBJECTS------------------------------------------------------------------------
	on btn_newOrder pressed do
	(
		setWaitCursor()
		with redraw off
		(
			--Sort instances in the default order:
			if rBtn_objectSort.state == 1 do
			(
				if rBtn_sortOrder.state == 1 do 
				(
					free nonInstancesArray
					nonInstancesArray = deepCopy nonInstancesArrayCopy
				)
				if rBtn_sortOrder.state == 2 do
				(
					free nonInstancesArray
					for i = nonInstancesArrayCopy.count to 1 by -1 do
					(
						append nonInstancesArray nonInstancesArrayCopy[i]
					)
				)
			)
			
			
			--Sort nonInstancesArray based on face count with qsort:
			if rBtn_objectSort.state == 2 do
			(
				--Qsort function:
				fn fn_sort obj1 obj2 sortOrder: = 
				(
					if sortOrder == 1 then (getNumFaces obj1.mesh) - (getNumFaces obj2.mesh) else (getNumFaces obj2.mesh) - (getNumFaces obj1.mesh)
				)
				--Run qSort on array:
				qSort nonInstancesArray fn_sort sortOrder:rBtn_sortOrder.state
			)
			
			
			--Sort nonInstancesArray based on material count with qsort:
			if rBtn_objectSort.state == 3 do
			(
				--Qsort function:
				fn fn_sort obj1 obj2 sortOrder: = 
				(
					obj1Count = 0
					obj2Count = 0
					
					if classOf obj1.material == Multimaterial do
					(
						for i = 1 to obj1.material.count where classOf obj1.material[i] != undefinedClass do obj1Count += 1
					)
					
					if classOf obj2.material == Multimaterial do
					(
						for i = 1 to obj2.material.count where classOf obj2.material[i] != undefinedClass do obj2Count += 1
					)
					
					if sortOrder == 1 then obj1Count - obj2Count else obj2Count - obj1Count
				)
				--Run qSort on array:
				qSort nonInstancesArray fn_sort sortOrder:rBtn_sortOrder.state
			)
		)
	)
	
	on btn_printOrder pressed do for i = nonInstancesArray do print i.name
	-----------END---------------------------------------SORT OBJECTS------------------------------------------------------------------------
	
	
	
	on btn_gatherMaterials pressed do
	(
	setWaitCursor()
	MatEditor.Close() 
	with redraw off
	(
		selectedObj = (for i = selection collect i)
		clearSelection()
		
		local matLib = #()
		local slot = #(#(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #())
		local obj_slot = #(#(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #(), #())
		
		
		---------------------------START------------------------FILL MATERIAL LIBRARY------------------------------------------------------
		for obj = nonInstancesArray do
		(
			objClass = classOf obj
			matClass = classOf obj.material
			
			for matIndex = 1 to (if matClass == multiMaterial then obj.material.count else 1) do
			(
				currentMaterial = (if matClass == multiMaterial then obj.material[matIndex] else obj.material)
				if currentMaterial != undefined and ((findString currentMaterial.name txt_undefinedMatName.text) == undefined) do appendIfUnique matLib currentMaterial
			)
		)
		--Add a black standard material for objects that might have a undefined submaterial. Check first that this material does not exist:
		fn fn_findMat matLib =
		(
			X = false
			for currentMat in matLib do if currentMat.name == "undefinedMat" do X = true
			return X
		)
		if (fn_findMat matLib) == false do append matLib (standardMaterial diffuse:black name:"undefinedMat")
		--------------------------END---------------------------FILL MATERIAL LIBRARY------------------------------------------------------
		
		
		
		
		
		
		---------------------------START------------------FIND THE BEST SLOT IN SLOT-ARRAY-----------------------------
		for obj = nonInstancesArray do
		( 
			objClass = classOf obj
			matClass = classOf obj.material
			
			local mostPoints = 0
			local bestSubMatSlot = undefined
			local altSubMatSlot = spn_defaultSlot.value
			--subMatSlot loop:
			for subMatSlot = 1 to (slot.count - spn_slotsAvailable.value) do
			(
				local matPoints = 0
				local newSlotsNeeded = 0
				--material loop:
				for matIndex = 1 to (if matClass == multiMaterial then obj.material.count else 1) do
				(
					currentMaterial = (if matClass == multiMaterial then obj.material[matIndex] else obj.material)
					if currentMaterial != undefined and ((findString currentMaterial.name txt_undefinedMatName.text) == undefined) do if findItem slot[subMatSlot] currentMaterial.name != 0 then matPoints += 1 else newSlotsNeeded += 1
				)
				--fill bestSubMatSlot, altSubMatSlot and mostPoints:
				if newSlotsNeeded <= (amax 0 (spn_matsPerSlot.value - slot[subMatSlot].count)) do altSubMatSlot = subMatSlot
				if matPoints > mostPoints and newSlotsNeeded <= (amax 0 (spn_matsPerSlot.value - slot[subMatSlot].count)) then
				(
					bestSubMatSlot = subMatSlot
					mostPoints = matPoints
				)
			)
			---------------------ADD MATERIAL NAMES AND OBJECT TO THEIR RESPECTIVE ARRAY-----------------------------------
			for matIndex = 1 to (if matClass == multiMaterial then obj.material.count else 1) do
			(
				currentMaterial = (if matClass == multiMaterial then obj.material[matIndex] else obj.material)
				if currentMaterial != undefined and ((findString currentMaterial.name txt_undefinedMatName.text) == undefined) do if bestSubMatSlot != undefined then appendIfUnique slot[bestSubMatSlot] currentMaterial.name
				else appendIfUnique slot[altSubMatSlot] currentMaterial.name
			)
			if bestSubMatSlot != undefined then append obj_slot[bestSubMatSlot] obj else append obj_slot[altSubMatSlot] obj	
		)
		--Adds an extra "undefinedMat" subMatSlot to accomodate for multisub materials that have a undefinedClass material (if the slot does not exist from before):
		for i = 1 to slot.count where slot[i].count > 0 do if (findItem slot[i] "undefinedMat") == 0 do append slot[i] "undefinedMat"
		---------------------------END--------------------FIND THE BEST SLOT IN SLOT-ARRAY-----------------------------
		
		
		
		
		
		
		-------------------------START-----------------------------CHANGE FACE ID`S--------------------------------------------------------
		--Functions to get and set material ID`s:
		fn fn_getID theClass theObject theObjectBase theFace =
		(
			local polyGetIDInterface = polyop.getFaceMatID
			local meshGetIDInterface = getFaceMatID
			
			local currentID
			
			if theClass == editable_poly do currentID = polyGetIDInterface theObjectBase theFace
			if theClass == editable_mesh do currentID = meshGetIDInterface theObjectBase.mesh theFace
			
			currentID			
		)
		-----------------------------------------------
		fn fn_setID theClass theObject theObjectBase theFace theNewID =
		(
			local polySetIDInterface = polyOp.setFaceMatID
			local meshSetIDInterface = setFaceMatID
			
			if theClass == editable_poly do polySetIDInterface theObjectBase theFace theNewID
			if theClass == editable_mesh do meshSetIDInterface theObjectBase.mesh theFace theNewID		
		)
		-------------------------------------------------------------------------------------------------------------------------------------
		
		for obj = nonInstancesArray do
		(	
			local objClass = classOf obj.baseObject
			local objBase = obj.baseObject
			local matClass = classOf obj.material
			local matName = (if obj.material != undefined and ((findString obj.material.name txt_undefinedMatName.text) == undefined) then obj.material.name else undefined)
			local objSlot
			for i = 1 to obj_slot.count where (findItem obj_slot[i] obj) != 0 do objSlot = i
			--------------------------------------------
			
			local objectFaceCount
			if objClass == Editable_Poly do objectFaceCount = polyOp.getNumFaces objBase
			if objClass == Editable_Mesh do objectFaceCount = getNumFaces objBase.mesh
				
			for currentFace = 1 to objectFaceCount do
			(
				--Find current face ID:
				local currentID = fn_getID objClass obj objBase currentFace
				
				--Find material name for current face:
				local currentMatName = "undefinedMat"
				if matClass == multiMaterial and classOf obj.material[currentID] != UndefinedClass and ((findString obj.material[currentID].name txt_undefinedMatName.text) == undefined) do currentMatName = obj.material[currentID].name
				if matClass != multiMaterial and matName != undefined do currentMatName = obj.material.name
				
				--Find and set new face ID:
				local newID
				for i = 1 to slot[objSlot].count where slot[objSlot][i] == currentMatName do newID = i
				fn_setID objClass obj objBase currentFace newID
			)
		)
		-------------------------END-------------------------------CHANGE FACE ID`S--------------------------------------------------------
		
		
		
		
		
		---------------------START----------FILL MATERIAL EDITOR, GIVE OBJECTS THE RIGHT SLOT AND GIVE EACH SLOT THE SAME NAME AS THE MATERIAL--
		--Reset material editor:
		for cnt in 1 to 24 do (meditmaterials[cnt] = Standard name:("Standard - "+(substring ((100+cnt) as string) 2 2)))
		
		for i = 1 to slot.count where slot[i].count >0 do 
		(
			--Prepare slots:
			setMEditMaterial i (multiMaterial numSubs:slot[i].count name:(txt_slotName.text + (i as string)))
			
			--Fill slots:
			for currentMaterial = matLib where (findItem slot[i] currentMaterial.name) != 0 do (getMEditMaterial i).material[(findItem slot[i] currentMaterial.name)] = currentMaterial
		)
		
		--Give objects the right slot:
		for i = 1 to obj_slot.count where obj_slot[i].count >0 do for obj = obj_slot[i] do 
		(
			--Object gets the correct material:
			obj.material = (getMEditMaterial i)
			
			--Give objects that are instances of the original, the same material:
			InstanceMgr.GetInstances obj &Instances
			if Instances.count != 1 do for inst = Instances do inst.material = (getMEditMaterial i)
		)
		
		--Give submaterial slots the same name as the material itself:
		for i = 1 to 24 where classOf (getMEditMaterial i) == Multimaterial do
		(
			local nameArray = #()
			for mat = (getMEditMaterial i).material do append nameArray mat.name
			(getMEditMaterial i).names = nameArray
		)
		---------------------------END----------FILL MATERIAL EDITOR AND GIVE OBJECTS THE RIGHT SLOT-----------------------
		
		
		---------------------------START----------AFTER SCRIPT EXECUTION ACTIONS----------------------------------------------------
		
		--Clear slots if selected:
		if chk_clearSlots.checked == true do
		(
			for matSlot in 1 to 24 where classOf (getMEditMaterial matSlot) == Multimaterial do
			(
				local theMultiMat = (getMeditMaterial matSlot)
				
				for index in 1 to theMultiMat.count do
				(
					theMultiMat[index] = undefined
				)
			)
		)
		
		
		--Save file if selected:
		if chk_saveScene.checked == true do
		(
			saveMaxFile(txt_savePath.text)
		)
		
		
		--Close 3dsmax if selected:
		if chk_close3dsmax.checked == true do quitMax #noPrompt
		
		
		
		
	)
	select selectedObj
	forceCompleteRedraw doDisabled:true
	setArrowCursor()
	)
	
	on btn_selectNonWorkedObjects pressed do select (for i = objects where (findItem objArray i) == 0 collect i)
)
createDialog rollout_main 510 900