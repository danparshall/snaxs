from phonopy import Phonopy
from phonopy.interface.vasp import read_vasp
from phonopy.file_IO import parse_FORCE_SETS, parse_BORN
import numpy as np

cell = read_vasp("POSCAR")

# Initialize phonon. Supercell matrix has to have the shape of (3, 3)
phonon = Phonopy(cell, np.diag([3, 3, 2]))

symmetry = phonon.get_symmetry()
print "Space group:", symmetry.get_international_table()

# Read forces and displacements
force_sets = parse_FORCE_SETS()

# Sets of forces have to be set before phonon.set_post_process or
# at phonon.set_post_process(..., sets_of_forces=sets_of_forces, ...).
phonon.set_force_sets(force_sets)
phonon.set_post_process()

# Character table
phonon.set_irreps([1./3, 1./3, 0], 1e-4)
ct = phonon.get_irreps() 
band_indices = ct.get_band_indices()
characters = np.rint(ct.get_characters()).real
for bi, cts in zip(band_indices, characters):
    print np.array(bi) + 1, cts
# phonon.show_character_table()
