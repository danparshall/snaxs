function PAR=simulate_single(PAR);
% PAR=simulate_single(PAR);
%	Calculates the structure factor for a single Q-point.  Uses simulate_multiQ,
%	which is a bit slower than reading the structure factor data array directly 
%	from file (the original method used with anapert) but means that everything 
%	(Escan, Qscan, SQW) uses the same calculation.

	PAR=simulate_multiQ(PAR, PAR.INFO.Q);

