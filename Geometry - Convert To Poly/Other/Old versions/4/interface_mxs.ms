--Interface:
rollout rollout_main "Convert To Poly"
(
	group "Object Selection"
	(
		checkBox chkBox_includeSelected "Include selected objects" checked:true
		checkBox chkBox_includeNotSelected "Include non-selected objects" offset:[175,-20] checked:true
		checkBox chkBox_includeVisible "Include visible objects" checked:true
		checkBox chkBox_includeHidden "Include hidden objects" offset:[175,-20] checked:true
		checkBox chkBox_includeNotFrozen "Include non-frozen objects" checked:true
		checkBox chkBox_includeFrozen "Include frozen objects" offset:[175,-20] checked: True
		checkBox chkBox_includeMesh "Include mesh objects" checked: True
		checkBox chkBox_includePoly "Include poly objects" offset:[175,-20] checked: True
		checkBox chkBox_includeSpline "Include spline objects"
		checkBox chkBox_includeOther "Include other objects" offset:[175,-20] checked: True
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
		var_run \
		chkBox_includeSelected.checked \
		chkBox_includeNotSelected.checked \
		chkBox_includeVisible.checked \
		chkBox_includeHidden.checked \
		chkBox_includeNotFrozen.checked \
		chkBox_includeFrozen.checked \
		chkBox_includeMesh.checked \
		chkBox_includePoly.checked \
		chkBox_includeSpline.checked \
		chkBox_includeOther.checked \
		rBtn_mesh_op.state \ 
		rBtn_mod_op.state \ 
		chkBox_AutoEdge.checked \
		chkBox_workInstances.checked \
		rBtn_undo.state
	)
	
)--END interface