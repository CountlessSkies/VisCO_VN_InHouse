(--START script
	
	--Import object selection module:
	include "selection.ms"

	
	
	
	--START function to set mesh edges visible: (Mapped functions takes an array as the first argument. It then treats the variable that contains the array as a single object, looping through all objects in the array)
	mapped fn edgesVisible object_arr threshold =
	(
		if classOf object_arr.baseobject == Editable_mesh and (getNumFaces object_arr.baseobject.mesh) > 0 do
		(
			edgeList = #{1..(object_arr.baseobject.mesh.numFaces * 3)}
			meshop.autoEdge object_arr.baseobject.mesh edgeList threshold type:#SetClear
			update(object_arr)
		)
	)--END function to set mesh edges visible
	
	
	
	
	
	
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

	
	
	
	
	--START main function that runs the script.
	--The function is contained in the variable var_run. This is because the function is used in the interface before it´s declared. 
	--Because of this the variable var_run is declared in the very beginning, so the interface points to the same memory location, thereby enabling
	--the possibility to run it before its delcared.
	var_run = ( \
		fn run \
			includeSelected \
			includeNotSelected \
			includeVisible \
			includeHidden \
			includeNotFrozen \
			includeFrozen \
			includeMesh \
			includePoly \
			includeSpline \
			includeOther \
			_mesh_op \ 
			_mod_op \ 
			AutoEdge \
			workInstances \
			_undo =
		(
			setWaitCursor()
			with redraw off
			(
				--Initialize the selection struct:
				my_selection = Get_selection \
				includeSelected includeNotSelected includeVisible includeHidden \
				includeNotFrozen includeFrozen includeMesh \
				includePoly includeSpline includeOther
				
				
				
				if _undo == 2 do holdMaxFile()
				if _undo == 1 or _undo == 2 do clearUndoBuffer()
				undo "ConvertToPoly" (_undo == 3)
				(
					--Deselect objects:
					local preSelObjs = (for i in selection collect i)
					clearSelection()
					
					--Set correct selection array, depending on wether instanced objects are to be included or not:
					obj_array = (if workInstances then my_selection.nonInstancesArray else my_selection.singleObjectsArray)
					
					--Set all mesh object edges visible: (object array, autoEdge threshold)
					if AutoEdge do edgesVisible obj_array 0
					
					--Convert objects: (object array, operation type)
					convertOp obj_array _mesh_op _mod_op
					
					--Select previously selected objects:
					select preSelObjs
					
				)--END undo scope
			)--END with redraw off
			completeRedraw()
			setArrowCursor()	
		)--END run function
	) -- END var_run variable that contains function
	
	
	
	
	
	
	
	
	
)--END script
