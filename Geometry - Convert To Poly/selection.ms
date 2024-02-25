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