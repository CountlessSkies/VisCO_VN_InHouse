(--START Interface

	--Get Dict_From_File struct:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "dict_from_file.ms" --Combines directory and filename to create a path
	file_dict_from_file = fileIn path_script
	
	--Get Main struct from main.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "main.ms" --Combines directory and filename to create a path
	file_main = fileIn path_script
	

	--Interface:
	rollout rollout_main "Convert To Poly"
	(
		group "Object Selection"
		(
			checkBox chkBox_inclSelected "Include selected objects" checked:true
			checkBox chkBox_inclNotSelected "Include non-selected objects" offset:[175,-20] checked:false
			checkBox chkBox_inclVisible "Include visible objects" checked:true
			checkBox chkBox_inclHidden "Include hidden objects" offset:[175,-20] checked:false
			checkBox chkBox_inclNotFrozen "Include non-frozen objects" checked:true
			checkBox chkBox_inclFrozen "Include frozen objects" offset:[175,-20] checked: false
			checkBox chkBox_inclMesh "Include mesh objects" checked: True
			checkBox chkBox_inclPoly "Include poly objects" offset:[175,-20] checked: True
			checkBox chkBox_inclSpline "Include spline objects" checked: false
			checkBox chkBox_inclOther "Include other objects" offset:[175,-20] checked: True
		)
		group "Settings"
		(
			radiobuttons rBtn_mesh_op "Convert To:" labels: #("Poly", "Mesh") default:1 Align:#left
			radiobuttons rBtn_mod_op "Modifiers:" labels: #("Delete", "Bake", "Maintain") default:1 Align:#left offset:[175,-35]
			checkBox chkBox_AutoEdge "Mesh Edges Visible" align:#left checked: True
			checkBox chkBox_workInstances "Work Instances" align:#left  offset:[175,-20] checked: True
		)
		group "Execute"
		(
			button btn_execute "Execute" Align: #left
			radioButtons rBtn_undo "Undo Level:" labels:#("None", "Hold", "Undo") default:2 align:#left offset:[175,-35]
		)
		group "Notes"
		(
			label lbl_references "Set modifiers to be deleted if at least one object is a reference"
		)
		
		on btn_execute pressed do
		(
			--Make dictionary with settings:
			convToPoly_dict = Dictionary (#string) -- empty dictionary of the specified type
			
			convToPoly_dict["inclSelected"] = chkBox_inclSelected.checked
			convToPoly_dict["inclNotSelected"] = chkBox_inclNotSelected.checked
			convToPoly_dict["inclVisible"] = chkBox_inclVisible.checked
			convToPoly_dict["inclHidden"] = chkBox_inclHidden.checked
			convToPoly_dict["inclNonFrozen"] = chkBox_inclNotFrozen.checked
			convToPoly_dict["inclFrozen"] = chkBox_inclFrozen.checked
			convToPoly_dict["inclMesh"] = chkBox_inclMesh.checked
			convToPoly_dict["inclPoly"] = chkBox_inclPoly.checked
			convToPoly_dict["inclSpline"] = chkBox_inclSpline.checked
			convToPoly_dict["inclOther"] = chkBox_inclOther.checked
			convToPoly_dict["conv_type"] = rBtn_mesh_op.state
			convToPoly_dict["edgesVisible"] = chkBox_AutoEdge.checked
			convToPoly_dict["mod_action"] = rBtn_mod_op.state
			convToPoly_dict["doInstances"] = chkBox_workInstances.checked
			convToPoly_dict["undo"] = rBtn_undo.state
			convToPoly_dict["dir_proj"] = "undefined"
			convToPoly_dict["name_proj"] = "undefined"
			convToPoly_dict["path_proj"] = "undefined"
			convToPoly_dict["save"] = False
			convToPoly_dict["close"] = False
			convToPoly_dict["path_logFile"] = "undefined"
			convToPoly_dict["newName_proj"] = "undefined"
			convToPoly_dict["newPath_proj"] = "undefined"
			
			--Make dictionary to text and put it in a file:
			file_dict_from_file.make_file convToPoly_dict "settings.ini " "="
			
			--Run main:
			file_main.run()
		)
		
	)--END rollout


)--END Interface