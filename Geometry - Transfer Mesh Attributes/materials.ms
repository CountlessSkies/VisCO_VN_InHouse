(--START materials
	
	struct Materials
	(
		theMaterial = undefined, --Contains the collected material
		
		fn Get_Material theObject =
		(
			theMaterial = theObject.material
		),
		
		
		
		fn Set_Material theObject =
		(
			theObject.material = theMaterial
		)
		
	)
	
	
	
)--END materials