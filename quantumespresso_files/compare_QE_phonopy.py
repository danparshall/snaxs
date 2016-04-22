import numpy as np



################################################################################

def labelSequence( fcmList, nAtom ):
	"""
	Results calculated with VASP vs QuantumEspresso will have various numerical
	differences.  But the symmetry of FCMs should be the same in both systems.

	This function treats each unique FCM as the key, and the indices that FCM
	occurs at as the value.  We can then compare the sequence of FCMs produced 
	from each phonopy and QE.
	"""


	nUnique = 0
	uniqueMats = {}
	matLabels = np.zeros(nAtom**2,dtype=int)

	for ind in range(nAtom**2):

		thisSet = fcmList[ (4*ind)+1 : (4*ind+3)+4]

		r1 = thisSet[1].split()
		r2 = thisSet[2].split()
		r3 = thisSet[3].split()

		inList =  [ float(r1[0]), float(r1[1]), float(r1[2]),\
					float(r2[0]), float(r2[1]), float(r2[2]), \
					float(r3[0]), float(r3[1]), float(r3[2]) ]


		# this is an option for rounding off according to tolerance level
		matList = []
		for num in inList:
			tol = 1E+9
			matList.append(round(tol*num) / tol)

		"""
					bad (max 2268)
		tol = 4		0
		tol = 5		1044
		tol = 6		1260
		tol = 7		2232
		tol = 8		2268
		tol = 9		2268
		"""


		thisMat = (	matList[0], matList[1], matList[2], \
					matList[3], matList[4], matList[5], \
					matList[6], matList[7], matList[8] )


		# fetch label for each unique matrix
		try:
			matLabels[ ind ] = uniqueMats[ thisMat ]
		except:
			uniqueMats[ thisMat ] = nUnique
			matLabels[ ind ] = uniqueMats[ thisMat ]
			nUnique = nUnique+1

		
		tmpMats = [(uniqueMats[mat],np.reshape(mat,[3,3])) for mat in uniqueMats]
		tmpMats.sort()
		outMats = [x[1] for x in tmpMats]
	return matLabels, outMats

################################################################################



def compareSequence():
	from matplotlib.mlab import find
	phName = 'FORCE_CONSTANTS_phonopy'
	qeName = 'FORCE_CONSTANTS'

	# read file into list
	phList = [line.strip() for line in open(phName)]
	qeList = [line.strip() for line in open(qeName)]

	assert len(phList) == len(qeList), "FCM from phonopy and from QE should have same length"


	phInds, phMats = labelSequence( phList, int(phList[0]) )	# first line has number of atoms
	qeInds, qeMats = labelSequence( qeList, int(phList[0]) )	# first line has number of atoms

	comp = phInds != qeInds
	print find(comp)
	good = []
	bads = []
	for ind,phLabel in enumerate(phInds):
		if phLabel == qeInds[ind]:
			good.append(ind)
		else:
			bads.append(ind)

	#print comp
	print "bads = ", len(bads)
	print "good = ", len(good)
	print bads

	print "  len(qeMats) :", len(qeMats)
	print "  len(phMtas) :", len(phMats)


