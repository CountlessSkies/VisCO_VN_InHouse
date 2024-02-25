(--START script

	struct FaceIDs
	(
		-------------------------------------------------------------------------------------------------------------------------
		--Object properties:
		theObjectBase,
		theClass,
		
		--Object mesh properties
		faceCount,
		getIDinterface,
		setIDinterface,
		theObjectBaseMesh,
		
		--Face ID´s store in array. The corresponding face number is the index position itself:
		id_array = #(),
		
		-------------------------------------------------------------------------------------------------------------------------
		fn Prepare theObject =
		(
			--Object properties:
			theObjectBase = theObject.baseObject
			theClass = classOf theObjectBase
			
			--Set object mesh properties:
			if theClass == Editable_Poly do
			(
				faceCount = polyOp.getNumFaces theObjectBase
				getIDinterface = polyop.getFaceMatID
				setIDinterface = polyOp.setFaceMatID
				theObjectBaseMesh = theObjectBase
			)
			
			if theClass == Editable_Mesh do
			(
				faceCount = meshOp.getNumFaces theObjectBase
				getIDinterface = getFaceMatID
				setIDinterface = setFaceMatID
				theObjectBaseMesh = theObjectBase.mesh
			)
		),
		
		-------------------------------------------------------------------------------------------------------------------------
		fn Get_FaceIDs theObject =
		(
			--Empty id_array:
			id_array = #()
			
			--Run prepare function to set the correct object parameters:
			Prepare theObject
			
			--Loop through faces and get IDs:
			for currentFace in 1 to faceCount do 
			(
				current_ID = getIDinterface theObjectBaseMesh currentFace
				append id_array current_ID
			)
			
		),
		
		-------------------------------------------------------------------------------------------------------------------------
		fn Set_FaceIDs theObject =
		(
			--Run prepare function to set the correct object parameters:
			Prepare theObject
			
			--Loop through faces and set IDs:
			for currentFace in 1 to faceCount do 
			(
				setIDinterface theObjectBaseMesh currentFace id_array[currentFace]
			)
		)
		
		-------------------------------------------------------------------------------------------------------------------------
		
		
	)--END Struct
	
	
	
	
	
)--END script