--ConvertToPoly

(--START script
	

	--START struct  object selection:
	struct Get_selection
	(
		--struct parameters that are passed to the struct: (These parameters can be used directly by functions within the struct)
		includeSelected,
		includeNotSelected,
		includeVisible,
		includeHidden,
		includeNotFrozen,
		includeFrozen,
		includeMesh,
		includePoly,
		includeSpline,
		includeOther,
		
		--struct variables that contain selection:
		allObjects = #(),
		nonInstancesArray = #(),
		duplicateObjectsArray = #(),
		singleObjectsArray = #(), --Contains objects that has no instances
		
		--START struct function to collect objects: (A function within a struct can read variables that is within the struct, but outside its own scope)
		fn __init__ =
		(
			for obj in objects where \
				(superclassof obj == GeometryClass or superclassof obj == Shape) and \
				(classOf obj != Targetobject) and \
				(if includeSelected == true or obj.isSelected == false then true else false) and \
				(if includeNotSelected == true or obj.isSelected == true then true else false) and \
				(if includeHidden == true or obj.isHidden == false then true else false) and \
				(if includeVisible == true or obj.isHidden == true then true else false) and \
				(if includeFrozen == true or obj.isFrozen == false then true else false) and \
				(if includeNotFrozen == true or obj.isFrozen == true then true else false) and \
				(if includeMesh == true or classof obj.baseobject != Editable_mesh then true else false) and \
				(if includePoly == true or classof obj.baseobject != Editable_poly then true else false) and \
				(if includeSpline == true or superclassof obj.baseobject != shape then true else false) and \
				(if includeOther == true or classof obj.baseobject == Editable_mesh or classof obj.baseobject == Editable_poly or superclassof obj.baseobject == shape then true else false) \
				do append allObjects obj
			--Sort out instances of objects in the array:
			for obj in allObjects do
			(
				InstanceMgr.GetInstances obj &Instances
				if Instances.count == 1 then 
				(
					append nonInstancesArray obj
					append singleObjectsArray obj
				)
				else
				(
					if (findItem duplicateObjectsArray obj) == 0 do
					(
						append nonInstancesArray obj
						for i in Instances do append duplicateObjectsArray i
					)
				)
			)--END sort out instances of objects in the array
		),--END struct function to collect objects
		
		--struct initialize: (maxscript doesnt really have a __init__ function similar to python, so making a variable that runs a function is a trick to make it run a function when the struct is initialized)
		_init = __init__()
		
	) --END struct object selection
	
	
	
	
	
	
	--START function to set mesh edges visible: (Mapped functions takes an array as the first argument. It then treats the variable that contains the array as a single object, looping through all objects in the array)
	mapped fn edgesVisible object_arr threshold =
	(
		if classOf object_arr.baseobject == Editable_mesh and (getNumFaces object_arr.baseobject.mesh) > 0 do
		(
			edgeList = #{1..(object_arr.baseobject.mesh.numFaces * 3)}
			meshop.autoEdge object_arr.baseobject.mesh edgeList threshold type:#SetClear
			update(object_arr)
		)
	)--END function to set mesh edges visible:
	
	
	
	
	
	
	--START function to convert objects:
	mapped fn convertOp object_arr mesh_op mod_op =
	(
		--Variables:
		mod_storage = #()
		
		--Get all instances of the object and store it in Instances:
		InstanceMgr.GetInstances object_arr &Instances
		
		--mod_op delete modifiers:
		if mod_op == 1 do for i in object_arr.modifiers.count to 1 by -1 do deleteModifier object_arr i
		
		--mod_op bake modifiers:
		if mod_op == 2 do pass
		
		--mod_op maintain modifiers:
		if mod_op == 3 do
		(
			--store modifiers in array:
			for i in object_arr.modifiers do append mod_storage i
			--delete modifiers:
			for i in object_arr.modifiers.count to 1 by -1 do deleteModifier object_arr i
		)
		
		--Convert object:
		if mesh_op == 1 do convertToPoly object_arr
		if mesh_op == 2 do convertToMesh object_arr
			
		--Convert instances of the object:
		for obj in Instances where obj != object_arr do 
		(
			for i in obj.modifiers.count to 1 by -1 do deleteModifier obj i
			obj.baseobject = object_arr.baseobject
		)
		
		--Put modifiers back on: (The array might be empty, depending on the mod_op choosen)
		for the_mod in mod_storage do addModifier object_arr the_mod before:object_arr.modifiers.count
		
	)--END function to convert objects (convertOp)
	
	
	
	
	
	
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
		
		--Bindings:
		on btn_execute pressed do
		(
			setWaitCursor()
			with redraw off
			(
				if rBtn_undo.state == 2 do holdMaxFile()
				if rBtn_undo.state == 1 or rBtn_undo.state == 2 do clearUndoBuffer()
				undo "ConvertToPoly" (rBtn_undo.state == 3)
				(
					--Initialize the selection struct:
					my_selection = Get_selection \
					chkBox_includeSelected.checked chkBox_includeNotSelected.checked chkBox_includeVisible.checked chkBox_includeHidden.checked \
					chkBox_includeNotFrozen.checked chkBox_includeFrozen.checked chkBox_includeMesh.checked \
					chkBox_includePoly.checked chkBox_includeSpline.checked chkBox_includeOther.checked
					
					
					--Deselect objects:
					local preSelObjs = (for i in selection collect i)
					clearSelection()
					
					--Set correct selection array, depending on wether instanced objects are to be included or not:
					obj_array = (if chkBox_workInstances.checked then my_selection.nonInstancesArray else my_selection.singleObjectsArray)
					
					--Set all mesh object edges visible: (object array, autoEdge threshold)
					if chkBox_AutoEdge.checked do edgesVisible obj_array 0
					
					--Convert objects: (object array, operation type)
					convertOp obj_array rBtn_mesh_op.state rBtn_mod_op.state
					
					--Select previously selected objects:
					select preSelObjs
					
				)--END undo scope
			)--END with redraw off
			
			completeRedraw()
			setArrowCursor()	
			
		)--END btn_execute
		
	)--END interface
	createDialog rollout_main 400 310	
	
	
	
	
)--END script
