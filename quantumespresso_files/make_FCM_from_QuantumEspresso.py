import numpy as np
import itertools as it

# NOTE! QE uses atomic units, which has units of Ry/au^2, 
#	Phonopy uses eV/A^2.
# https://en.wikipedia.org/wiki/Rydberg_constant
#	1 Ry = 13.60569253 eV
#	1 a0 = 0.5291772109 E-10 m
#	13.60569253/0.5291772109/0.5291772109 = 48.586810029071955

# see these: 
# http://www.democritos.it/pipermail/pw_forum/2005-April/002408.html
# http://www.democritos.it/pipermail/pw_forum/2008-September/010099.html
# http://www.democritos.it/pipermail/pw_forum/2009-August/013613.html
# http://www.mail-archive.com/pw_forum@pwscf.org/msg24388.html

## overall structure of .fc file has:
# line 0		number of types, number of atoms in the cell, type of lattice, lattice parameters
# 3 lines		Bravis basis
# nType lines	List of each atom type #, label, atomic mass in au
# 3 lines		atom #, type #, positions in the cell in a0 units: *CARTESIAN*, not basis vecs
# 1 line		Flag indicating if what follows has Born effective charges, epsilon and Z*
# 3 + (4*nType)	Only if Flag is T, otherwise 0 lines
# 1 line		3 integers, size of supercell
# remainder		Force Constants (listed between atoms in various cells, not as matrices)
#
# For the FCMS, first line of every nCells indicates direction (xx,xy,etc) and at1/at2 vals
# QE lists by direction, then within each direction it groups by atom, then by cell

# output file is FORCE_CONSTANTS.  The line before each matrix is used to print the at1/at2 names
# Format is first the unique numeric ID for the atom, then the chemical symbol, then the unit cell for the atom.


debug = 0

################################################################################

def writeBORN(flagline,nAtom,lines):
	# Following atom positions, line can be T or F.  
	# If T, first matrix is dielectric, others are born effective charge, so 3+(4*N_at) lines
	# if F, not included (0 lines)
	# read dielectric constant and Born effective charges if listed (and write to BORN file)


	if debug:
		print "  Writing BORN file."

	fborn = open("BORN", "w")
	fborn.write("14.39972\n")		# scale constant - need to check this value

	epsilon = lines[flagline+1]+ '    ' +lines[flagline+2]+ '    ' +lines[flagline+3]+ '\n'
	fborn.write(epsilon)

	for iAt in range(nAtom):
		bLine = flagline + 4 + 4*iAt
		zBorn = lines[bLine + 1]+ '    ' +lines[bLine + 2]+ '    ' +lines[bLine + 3]+ '\n'
		fborn.write(zBorn)

	fborn.close()

################################################################################

def writePOSCAR(lines,kindList,scale,atomList,crystalPos):
	"""
	Create a POSCAR file (cell dimensions and atomic coordinates) from the data
	found in the QE file.

	Inputs:
		kindList 	: list of strings with the chemical symbol
		atomList	: list of integers (for each atom, index in kindList)
		crystalPos	: position array in crystal coordinates, shape = nAtom x 3

	Outputs:
		NONE
	"""

	if debug:
		print "  Writing POSCAR file."

	nAtom = len(atomList)

	with open("POSCAR", "w") as fpos:

		# write list of atom types
		liststring = ''
		for kind in kindList:
			liststring = liststring + ' ' + kind
		fpos.write(liststring + '\n')

		# write scale
		fpos.write(' ' + str(scale) + '\n')

		# write basis
		fpos.write('\t' + lines[1] + '\n')
		fpos.write('\t' + lines[2] + '\n')
		fpos.write('\t' + lines[3] + '\n')

		# write number of each atom type
		countstring = ''
		for kind in kindList:
			countstring = countstring + ' ' + str(atomList.count(kind))
		fpos.write(countstring + '\n')

		fpos.write('Direct\n')

		# write atomic positions
		for ind in range(nAtom):
			posStrings = ["  {: 10.16f}".format(x) for x in crystalPos[ind,:]]
			fpos.write(''.join(posStrings) + '\n')


################################################################################


def makeFCM(filename):

	# read file into "lines" list
	lines = [line.strip() for line in open(filename)]


	### read data from first line, which has:
	l0 = lines[0].split()
	nKind = int(l0[0])
	nAtom = int(l0[1])
	scale = float(l0[3])*0.5291772109	# scales bravis basis from AU to Ang


	### read bravis basis
	basis=np.zeros([3,3])
	for vec in range(3):
		row = lines[vec+1].split()		# read row into list of elements

		assert len(row)==3, "Error reading bravis basis: must have 3 elements"

		# convert from string to numeric, add to bravis array
		for xyz in range(3):
			basis[vec,xyz]=float(row[xyz])


	### read table of atoms, IDs, and masses
	kindList = []
	kindMass = np.zeros(nKind)
	for ind in range(nKind) :
		kind = lines[4+ind].split('\'')	# split on ' literal
		kindList.append(kind[1].strip())
		kindMass[ind] = float(kind[2])


	### read position of each atom in fractional Cartesian coordinates
	atomList = []	# string corresponding to each atom.  Should be nAtom long
	cartesianPos = np.zeros([nAtom,3])
	for ind in range(nAtom) :
		atom = lines[ 4 + nKind + ind].split()
		atomList.append( kindList[int(atom[1])-1])
		cartesianPos[ind,0] = float(atom[2])
		cartesianPos[ind,1] = float(atom[3])
		cartesianPos[ind,2] = float(atom[4])
	crystalPos = cartesianPos.dot( np.linalg.inv(basis) )  # convert to basis

	assert len(atomList) == nAtom, "atomList error!"

	# the prefix for each atom is a 
	atomIdList=[]
	for iAt, atom in enumerate(atomList):
		atomIdList.append( str(iAt) + atom)


	###	Interlude : create POSCAR file
	#
	writePOSCAR(lines,kindList,scale,atomList,crystalPos)


	###	Interlude : create BORN file
	#
	flagline = 1 + 3 + nKind + nAtom
	flag = lines[flagline].strip()
	if flag=='T':
		writeBORN(flagline,nAtom,lines)
		offset = 1 + 3 + 4*nAtom
	else :
		offset = 1


	# supercell size listed after atom positions (and Born data, if present)
	superline = flagline+offset
	supercell = [int(x) for x in lines[superline].split()]
	nCell = np.prod(supercell)


	############################################################################

	###			 Now read in FORCE-CONSTANTS, create FCM

	##		Phonopy considers the force which atom1 causes on atom2.
	##		QE considers the force which atom2 causes on atom1.
	##		A hilarity of indexing ensues.


	### subarray of just the force constants, to preserve index sanity
	forceList = lines[ flagline+offset+1 :]


	expectLength = (nAtom**2) * (nCell+1)
	forceLength = len(forceList) / 9		#1539/9 = 171
	assert (len(forceList) % 9) == 0, "Forcelist should be divisible by 9 (xx, xy, ..., zy, zz)"
	assert forceLength == expectLength, "ForceList/9 should have length (nAtom**2)*(nCell+1)"


	fcm = np.zeros([3, 3, nCell*(nAtom**2)])

	## QE groups forces for each direction
	for iXYZ in range(9):			# xx, xy, xz, yx, yy, yz, zx, zy, zz

		dirForce = np.zeros( nCell*nAtom**2 )	# force in this direction

		# all atom-atom interactions for a given direction
		dirLines = forceList[ iXYZ*forceLength : (iXYZ+1)*forceLength ]

		if debug:
			print dirLines

		# within each direction, there are nAtom**2 chunks, each of length nCell+1
		for iGroup in range( nAtom**2 ):

			# first line of each group yields: dir1, dir2, at1, at2
			info = [int(x) for x in dirLines[ iGroup * (nCell+1) ].split()]

			iX = info[0]-1	# python indexes from 0
			iY = info[1]-1

			zOffset = (info[2]-1)*nCell*nAtom + (info[3]-1)*nCell

			# group
			group = dirLines[ iGroup*(nCell+1)+1 : (iGroup+1)*(nCell+1) ]

			# read in values for each at1 / at2 combination.
			# This is the value of at2 on at1 in each cell.
			for iCell in range( nCell ):
				vals = group[ iCell ].split()

				# supercell indices
				# negative because QE is at2 on at1
				# 1 because python indexes from 0, QE from 1
				iA = (1-int(vals[0])) % supercell[0]
				iB = (1-int(vals[1])) % supercell[1]
				iC = (1-int(vals[2])) % supercell[2]

				iZ = zOffset + iA + (iB*supercell[0]) + (iC*supercell[0]*supercell[1])

				dirForce[iZ] = float(vals[3])	

		# insert force-constants from this direction into FCM array, and
		# convert from Rydberg/AU^2 to eV/Ang^2
		fcm[ iY, iX, :] = dirForce * 48.586810029071955


	return fcm, supercell, nAtom


################################################################################

def permute_cells(sc,nAtom):
	"""
	INPUT:
		sc  : supercell dimensions
		nAtom : number of unique atoms in each cell

	OUTPUT:
		idx : list of all possible supercell indices, in correct order


	DESCRIPTION:
	If sc were [3,3,2] (the test case using MgB2), then 
		pX = [0,1,2]
		pY = [0,3,6]
		pZ = [0,9]
	thus a combination of one element from each can encode values up to nCell.
	Subsequent iterations permute each pX,pY,pZ via the modulo operator.
	The itertools.product function returns all the permutations of the permutatons,
	thus permuting the numbers up to nCell**2, in the correct sequence.
	"""
	nCell = np.prod(sc)
	perms = []

	if debug:
		print " permute_cells sequence:"

	for iZ in range(sc[2]):
		pZ = [ sc[0] * sc[1] * z for z in (np.arange(sc[2])-iZ) % sc[2] ]

		for iY in range(sc[1]):
			pY = [sc[0]*y for y in (np.arange(sc[1])-iY) % sc[1] ]

			for iX in range(sc[0]):
				pX = (np.arange(sc[0])-iX) % sc[0]

				if debug:
					print "    ", pX, pY, pZ

				perm = []
				for p in it.product( pZ, pY, pX ):
					perm.append(sum(p))
				perms.append(np.array(perm))

	idxFirst = []
	for perm in perms:
		for iAtom in range(nAtom):
			idxFirst.append( perm + iAtom * nCell )
	idxFirst = np.concatenate(idxFirst)

	idx = []
	for iAtom in range(nAtom):
		idx.append( idxFirst + iAtom * nCell * nAtom )
	idx = np.concatenate(idx)

	if debug:
		print "  len(idx) = ", len(idx)

	return idx

################################################################################


def write_phonopy_FCM(fcm,supercell,nAtom):

	nCell = int(np.prod(supercell))
	idxOut = permute_cells(supercell,nAtom)

	if debug:
		print "  Writing phonopy-format output:"
		print "    len(idxOut) = ", len(idxOut)
		print "    fcm.shape = ", fcm.shape

	with open("FORCE_CONSTANTS","w") as f:

		f.write( '  ' + str(nCell*nAtom) + '\n' )
		for ind in idxOut:
			thisMat = fcm[:,:,ind]

			f.write('\n')
			for iy in range(3):
				numstr = ["    {: 10.15f}".format(x) for x in thisMat[iy,:]]
				row = ''.join(numstr) + '\n'
				f.write(row)


################################################################################

fname = 'MgB2-332-pwscf.fc'

if __name__ == "__main__":
	import sys
	argin = sys.argv

	if len(argin)>1:
		fname = argin[1]

print " Force-constant file from QuanutumEspresso :", fname
fcm, supercell, nAtom = makeFCM(fname)
write_phonopy_FCM(fcm,supercell,nAtom)

if debug:

	print "\n"
	print "\n"
	print "  Running comparison between Phonopy and QuantumEspresso FCMs"

	import compare_QE_phonopy
	compare_QE_phonopy.compareSequence()

