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
	selected_objects = #() --Contains all objects to be selected when the user wants to retrieve the selection 
	
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
				checkBox chkBox_inclFrozen "Include frozen objects" offset:[175,-20] checked: false
				label lbl ""
				button btn_originals_set "Originals" align: #left tooltip:"Original objects"
				button btn_search_set "Search Set" align: #left offset:[175,-26] tooltip:"Search through these to find copies. Can include original objects as well"
			)
			
		group "Search Parameters"
			(
				checkBox chkBox_same_any "Any" checked:false tooltip:"All copies in search set will qualify. \n Actions will be taken on all objects in the search set"
				checkBox chkBox_same_name "Name" checked:false offset:[175,-20] tooltip:"Copies must have the same name"
				checkBox chkBox_same_meshClass "Mesh class" checked:false tooltip:"Copies must be of the same mesh class (Mesh or poly)"
				checkBox chkBox_same_materialName "Material name" checked:false offset:[175,-20] tooltip:"Copies must have a material with the same name"
				checkBox chkBox_same_position "Position" checked:false tooltip:"Copies geometric center must be at the same position. Pivot position is not considered"
				checkBox chkBox_same_modifier_any "Any modifier" checked:false offset:[175,-20] tooltip:"Copies must share at least one modifier instance"
				checkBox chkBox_same_modifier_all "All modifiers" checked:false tooltip:"Copies must share all modifiers instances"
				checkBox chkBox_same_size "Size" checked:false offset:[175,-20] tooltip:"Copies must have the same size. Scale is NOT considered."
				checkBox chkBox_same_verticesCount "Vertices count" checked:false tooltip:"Copies must have the same number of vertices"
				checkBox chkBox_same_faceCount "Face count" checked:false offset:[175,-20] tooltip:"Copies must have the same number of faces"
				checkBox chkBox_same_verticesPositions "Shape" checked:false tooltip:"Copies must have the same shape. It´s determined by vertices positions"
				label lbl_1 ""
				spinner spn_tolerance "Tolerance: " range:[0.000, 99999999.999, 0.001] type:#float scale:0.001 fieldWidth:80 align:#left tooltip:"Some parameters use this tolerance value to avoid having a very small decimal rounding error disqualify a potential copy object"
			)
			
		group "Action"
			(
				checkBox chkBox_select "Select" checked:true tooltip: "Copies will be selected"
				button btn_retrieveSelection "Retrieve Selection" Align: #left offset:[55,-22] tooltip: "Retrieve the selection"
				checkBox chkBox_instance "Make instances" offset:[175,-20] checked:false tooltip: "Copies will become instances of original objects"
				checkBox chkBox_separate_layers "Put in separate layers" checked:false tooltip: "Copies will be put in a separate layer"
				checkBox chkBox_delete "Delete" offset:[175,-20] checked:false tooltip: "Copies will be deleted"
				checkBox chkBox_incl_originals "Include originals" checked:false tooltip: "Actions will also be taken on original objects"
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
		on btn_retrieveSelection pressed do
		(
			--Clean selected_objects array first, so that it doesn´t contain deleted objects:
			selected_objects = (for obj in selected_objects where isvalidnode obj collect obj) 
			
			--Select objects:
			select selected_objects
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
				--RESET VARIABLES:
				selected_objects = #()
				
				
				--ERROR CHECKING:
				
				--Make an instance of the error checking struct:
				my_file_error_check = file_error_check rBtn_saveExit.state txt_savePath.text originals_set search_set \
				chkBox_same_any.checked chkBox_same_name.checked chkBox_same_meshClass.checked chkBox_same_materialName.checked chkBox_same_position.checked \
				chkBox_same_modifier_any.checked chkBox_same_modifier_all.checked chkBox_same_size.checked chkBox_same_verticesCount.checked chkBox_same_faceCount.checked \
				chkBox_same_verticesPositions.checked
				
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
						chkBox_same_any.checked chkBox_same_name.checked chkBox_same_meshClass.checked chkBox_same_materialName.checked chkBox_same_position.checked \
						chkBox_same_modifier_any.checked chkBox_same_modifier_all.checked chkBox_same_size.checked chkBox_same_verticesCount.checked chkBox_same_faceCount.checked \
						chkBox_same_verticesPositions.checked spn_tolerance.value
					
					
				)--END run operation
				
				----------------------------------------------------------------------------------------------------------------	
				--ACTION:
				if continue_operation do
				(
					--Initialize the class to do actions:
					my_file_action = file_action my_file_find_identicals.main_objects my_file_find_identicals.copies_lists selected_objects
					
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
