/*
This part of the script will merge objects that shares the same material
*/

(--START script
	
	struct Merge_Geometry
	(
		the_objects,
		allMaterials,
		allMaterials_names,
		all_objects,
		
		--This function will merge objects that shares the same single material:
		fn Merge_Operation =
		(
			for the_material in allMaterials do
			(
				--Variable that contains the object that all others should merge into:
				theObject = undefined
				
				--Parameters that theObject will get, depending on its class:
				local theObjectBase = undefined
				local theClass = undefined
				local theObjectBaseMesh = undefined
				local attachInterface = undefined
				
				for index in the_objects.count to 1 by -1 where the_objects[index].material == the_material do
				(
					-----------------------------------------------------------------------------------------------------------------------------------------------
					--Get the top object (theObject) that all other objects with the same material should merge into:
					if theObject == undefined then 
					(
						theObject = the_objects[index]
						
						--Set parameters for the main object that others should attach to:
						theObjectBase = theObject.baseObject
						theClass = classOf theObjectBase
						
						if theClass == Editable_Poly do 
						(
							theObjectBaseMesh = theObjectBase
							attachInterface = polyop.attach 
						)
						if theClass == Editable_Mesh do
						(
							theObjectBaseMesh = theObjectBase.mesh
							attachInterface = meshOp.attach
						)
					)--END retrieving and setting parameters for the theObject, the object that all others should merge into
					-----------------------------------------------------------------------------------------------------------------------------------------------
					else --All other objects with the same material is attached to theObject, and then deleted from arrays (since it doesnt exist anymore):
					(
						obj_to_attach = the_objects[index]
						
						deleteItem the_objects (findItem the_objects obj_to_attach)
						deleteItem all_objects (findItem all_objects obj_to_attach)
						
						attachInterface theObject obj_to_attach
					)
					
				)--END for index in allObjects
			)--END loop through materials
			
			
			
		)--END fn Merge_Operation
	)--END struct Merge_Geometry
)--END script