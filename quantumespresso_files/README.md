This script should translate phonon calculations done using QuantumEspresso into the format used by Phonopy.

I've tested this by comparing the results of an MgB2 calculation done with QE to the MgB2 result provided with Phonopy.

Obviously, there will be minor numerical differences between the two calculation methods, but I would expect that the overall symmetry should be preserved.

Unfortunately, I find that while the Phonopy has 82 unique force-constant matrices (FCM), the QE calculation has only 80. I *think* this is just the result of numerical differences, but I'm not sure. When I inspect the FCMs between the two models, they look remarkably similar. When I round off the result to 4 sigfigs, the results between the two methods are in agreement.

I welcome any thoughts or feedback on the code and method.
