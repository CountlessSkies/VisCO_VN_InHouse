(--START Interface
	
	
	------------------------------------------------------------------------------------------------------------------------------------------
	--Get Selection struct from "selection.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "selection.ms" --Combines directory and filename to create a path
	file_selection = fileIn path_script
	
	--Get Error_Check struct from error_check.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "error_check.ms" --Combines directory and filename to create a path
	file_error_check = fileIn path_script
	
	--Get Find_Identicals struct from find_identicals.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "find_identicals.ms" --Combines directory and filename to create a path
	file_find_identicals = fileIn path_script
	
	--Get Action struct from action.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "action.ms" --Combines directory and filename to create a path
	file_action = fileIn path_script
	
	------------------------------------------------------------------------------------------------------------------------------------------
	local originals_set = #() --Contain objects that attributes are taken from
	local search_set = #() --Contain objects that attributes are transfered to
	
	------------------------------------------------------------------------------------------------------------------------------------------
	incl_originals_state = true --Set this to the same value as chkBox_incl_originals. Its to save user selection when he toggles checkbox delete
	
	------------------------------------------------------------------------------------------------------------------------------------------
	
	rollout rollout_main "Find Identical Objects"
	(
		group "Object Selection"
			(
				checkBox chkBox_inclSelected "Include selected objects" checked:true
				checkBox chkBox_inclNotSelected "Include non-selected objects" offset:[175,-20] checked:false
				checkBox chkBox_inclVisible "Include visible objects" checked:true
				checkBox chkBox_inclHidden "Include hidden objects" offset:[175,-20] checked:false
				checkBox chkBox_inclNotFrozen "Include non-frozen objects" checked:true
				checkBox chkBox_inclFrozen "Include frozen objects" offset:[175,-20] checked: True
				label lbl ""
				button btn_originals_set "Originals" align: #left tooltip:"Set of original objects"
				button btn_search_set "Search Set" align: #left offset:[175,-26] tooltip:"Set of potential copies. Can include originals set if desired"
			)
			
		group "Search Parameters"
			(
				checkBox chkBox_same_name "Name" checked:false tooltip:"Copies must have the same name"
				checkBox chkBox_same_meshClass "Mesh class" offset:[175,-20] checked:false tooltip:"Copies must be of the same mesh class (Mesh or poly)"
				checkBox chkBox_same_materialName "Material name" checked:false tooltip:"Copies must have a material with the same name"
				checkBox chkBox_same_position "Position" offset:[175,-20] checked:false tooltip:"Copies must be at the same world position"
				checkBox chkBox_same_modifier "Modifier" checked:false tooltip:"Copies must share at least one modifier"
				checkBox chkBox_same_size "Size"  offset:[175,-20] checked:false tooltip:"Copies must have the same bounding box size"
				checkBox chkBox_same_verticesCount "Vertices count" checked:false tooltip:"Copies must have the same number of vertices"
				checkBox chkBox_same_faceCount "Face count" offset:[175,-20] checked:false tooltip:"Copies must have the same number of faces"
				checkBox chkBox_same_smoothingGroups "Smoothing groups" checked:false tooltip:"Each face on copies must have the same smoothing groups"
				checkBox chkBox_same_faceNormals "Face normals" offset:[175,-20] checked:false tooltip:"Each face on copies must have the same relative face normal direction"
				checkBox chkBox_same_verticesPositions "Relative Vertices positions" checked:false tooltip:"Copies must have the same relative vertices positions (Object position, pivot or center can still differ)"
				label lbl_1 ""
				spinner spn_tolerance "Tolerance: " range:[0.000, 1.000, 0.001] type:#float scale:0.001 fieldWidth:40 align:#left tooltip:"Position, size and vertices positions difference tolerance"
			)
			
		group "Action"
			(
				checkBox chkBox_select "Select" checked:true
				checkBox chkBox_instance "Make instances" offset:[175,-20] checked:false
				checkBox chkBox_separate_layers "Put in separate layers" checked:false
				checkBox chkBox_delete "Delete" offset:[175,-20] checked:false
				checkBox chkBox_incl_originals "Include originals" checked:true
			)
			
		group "Runtime Settings"
			(
				radioButtons rBtn_undo "Undo Level:" labels:#("None", "Hold") align:#left default: 2
				radiobuttons rBtn_saveExit "After Completion:" labels:#("Nothing", "Save", "Save and Exit") align:#left columns:3 offsets:#([0,0], [0,0], [-20,0]) offset:[180,-35]
				editText txt_savePath "Save Path:" fieldWidth:360 enabled:False
				button btn_browse "Browse" align:#left offset:[425,-25] enabled: False
				
			)
		
		group "Execute"
			(
				button btn_execute "Execute" Align: #left
			)
			
		-----------------------------------------------------------------------------------------------------------------------------------------------------
			
		on chkBox_delete changed state do
		(
			if state == true then
			(
				incl_originals_state = chkBox_incl_originals.checked
				
				chkBox_select.enabled = false
				chkBox_instance.enabled = false
				chkBox_separate_layers.enabled = false
				chkBox_incl_originals.checked = false
			)
			else
			(
				chkBox_select.enabled = true
				chkBox_instance.enabled = true
				chkBox_separate_layers.enabled = true
				chkBox_incl_originals.checked = incl_originals_state
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
		
		on btn_browse pressed do 
		(
			filePath = getSaveFileName()
			if filePath == undefined then filePath = txt_savePath.text
			txt_savePath.text=filePath
		)
			
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		on btn_originals_set pressed do
		(
			includeSelected = chkBox_inclSelected.checked
			includeNotSelected  = chkBox_inclNotSelected.checked
			includeVisible = chkBox_inclVisible.checked
			includeHidden  = chkBox_inclHidden.checked
			includeNotFrozen = chkBox_inclNotFrozen.checked
			includeFrozen = chkBox_inclFrozen.checked
			
			--Initialize the selection struct:
			my_selection = file_selection \
			includeSelected includeNotSelected includeVisible includeHidden \
			includeNotFrozen includeFrozen
			
			--Save selection as allObjects:
			originals_set = my_selection.allObjects
		)
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		on btn_search_set pressed do
		(
			includeSelected = chkBox_inclSelected.checked
			includeNotSelected  = chkBox_inclNotSelected.checked
			includeVisible = chkBox_inclVisible.checked
			includeHidden  = chkBox_inclHidden.checked
			includeNotFrozen = chkBox_inclNotFrozen.checked
			includeFrozen = chkBox_inclFrozen.checked
			
			--Initialize the selection struct:
			my_selection = file_selection \
			includeSelected includeNotSelected includeVisible includeHidden \
			includeNotFrozen includeFrozen
			
			--Save selection as allObjects:
			search_set = my_selection.allObjects
		)
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		on btn_execute pressed do
		(
			----------------------------------------------------------------------------------------------------------------
			--PREPARE SCENE:
			
			setWaitCursor()
			
			--Deselect objects:
			local preSelObjs = (for i in selection collect i)
			clearSelection()
			
			--Set correct undo setting and run the functions
			if rBtn_undo.state == 2 do holdMaxFile()
			clearUndoBuffer()
			
			----------------------------------------------------------------------------------------------------------------
			with redraw off
			(
				--ERROR CHECKING:
				
				--Make an instance of the error checking struct:
				my_file_error_check = file_error_check rBtn_saveExit.state txt_savePath.text originals_set search_set \
				chkBox_same_name.checked chkBox_same_meshClass.checked chkBox_same_materialName.checked chkBox_same_position.checked \
				chkBox_same_modifier.checked chkBox_same_size.checked chkBox_same_verticesCount.checked chkBox_same_faceCount.checked \
				chkBox_same_smoothingGroups.checked chkBox_same_faceNormals.checked chkBox_same_verticesPositions.checked
				
				local continue_operation = true--Stops the script from running if set to false
				
				--Error checks:
				if continue_operation do if ( my_file_error_check.SavePath_Valid() ) != true do continue_operation = false
				if continue_operation do if ( my_file_error_check.Objects_Collected() ) != true do continue_operation = false
				if continue_operation do if ( my_file_error_check.Check_Objects_Exist() ) != true do continue_operation = false
				if continue_operation do if ( my_file_error_check.Min_One_SearchParam() ) != true do continue_operation = false
				
				
				----------------------------------------------------------------------------------------------------------------
				if continue_operation != true do select preSelObjs
				--Select pre-selected objects again if the error check stops the scripts
				
				----------------------------------------------------------------------------------------------------------------
				--Update meshes before the script runs: (This is important to make sure vertices are in their correct position etc.)
				if continue_operation do
				(
					for obj in originals_set do (update obj)
					for obj in search_set do (update obj)
				)
				
				----------------------------------------------------------------------------------------------------------------
				--FIND IDENTICAL OBJECTS AND SORT THEM:
				if continue_operation do
				(
					--Initialize the class to find identicals:
					my_file_find_identicals = file_find_identicals originals_set search_set
					
					--Run the initial function to fill arrays:
					my_file_find_identicals.Sort_Objects \
						chkBox_same_name.checked chkBox_same_meshClass.checked chkBox_same_materialName.checked chkBox_same_position.checked \
						chkBox_same_modifier.checked chkBox_same_size.checked chkBox_same_verticesCount.checked chkBox_same_faceCount.checked \
						chkBox_same_smoothingGroups.checked chkBox_same_faceNormals.checked chkBox_same_verticesPositions.checked spn_tolerance.value
					
					
				)--END run operation
				
				----------------------------------------------------------------------------------------------------------------	
				--ACTION:
				if continue_operation do
				(
					my_file_action = file_action my_file_find_identicals.main_objects my_file_find_identicals.copies_lists
					
					if chkBox_select.enabled and chkBox_select.checked do my_file_action.Fn_Select chkBox_incl_originals.checked
					if chkBox_instance.enabled and chkBox_instance.checked do my_file_action.Fn_Make_Instances chkBox_incl_originals.checked
					if chkBox_separate_layers.enabled and chkBox_separate_layers.checked do my_file_action.Fn_Separate_Layers chkBox_incl_originals.checked	
					if chkBox_delete.enabled and chkBox_delete.checked do my_file_action.Fn_Delete chkBox_incl_originals.checked
				)
				
				----------------------------------------------------------------------------------------------------------------
				--AFTER-OPERATIONS:
				if continue_operation do
				(
					--Select preselected objects:
					if chkBox_select.checked == false and chkBox_delete.checked == false do select preSelObjs
				)
				
			)--END with redraw off
			
			
			completeRedraw()
			
			
			--If requested, save and close scene. Otherwise, just messagebox done:
			if continue_operation do
			(
				if  rBtn_saveExit.state == 2 or rBtn_saveExit.state == 3 do saveMaxFile(txt_savePath.text)
				if  rBtn_saveExit.state == 1 or rBtn_saveExit.state == 2 do messagebox "Done"
				if  rBtn_saveExit.state == 3 do quitMax #noPrompt
			)
			
			
			setArrowCursor()
			
			
			----------------------------------------------------------------------------------------------------------------
			
			
			
		)--END btn_execute
	)--END rollout	
)--END Interface
