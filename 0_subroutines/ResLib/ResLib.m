% 3-axis resolution calculation and convolution: Res Lib v.3.4
%
%Resolution matric calculation:
% ResMat   -  Calculate Cooper-Nathans resolution matrixes 
%            with or without horizontal focusing.
% ResMatS  -  Same thing, in a coordinate system related 
%            to sample crystallographic axes.
%
%Convolution with resolution function:
% ConvRes  -  convolute a user-defined cross-section 
%            function with the Cooper-Nathans resolution function.
% ConvResSMA  -  convolute a user-defined single-mode cross-section 
%            function with the Cooper-Nathans resolution function.
%
%Least-squares fitting of convoluted cross sections:
% FitConv  -  fit convoluted cross section to experimental data.
% FitConvSMA 
%          -  fit convoluted SMA cross section to experimental data.
% FitConvBoth 
%          -  fit convoluted sum of standard and SMA cross sections
%             to experimental data.
%
%Visualization:
% ResPlot.m - 2-D visualization of resolution ellipsoids and dispersion.
% ResPlot3D.m - 3-D visualization of resolution ellipsoids and dispersion.
%
%Crystallographic utilities :
% scalar   -  scalar product of vectors defined by
%             direct- or reciprocal-space fractional coordinates
% vector   -  vector product of vectors defined by
%             direct- or reciprocal-space fractional coordinates
% modvec   -  length of vectorsdefined by
%             direct- or reciprocal-space fractional coordinates
% star     -  calculate reciprocal-lattice parameters, unit
%             cell volume and reciprocal volume.
% angle     - angle between vectors in real or reciprocal space
% angle2    - angle between a real- and reciprocal-space vectors
% gtensor   - crystallographic g-tensor
% reciprocate  - reciprocal space to real space coordinates
% R2S       - reciprocal space coordinates to Cartesian  coordinates
% S2R       - Cartesian coordinates to reciprocal space coordinates
% StandardSystem  -  components of a ``standard'' sample-centered 
%             Cartesian basis set
% GetLattice - extract lattice parameters from experimental 
%             conditions structure for use with  other 
%             crystallographic functions
%
%Other utilities:
% GetTau    - reciprocal d-spacings of common monochromator crystals
% CleanArg  - ensure MatLab row-vectors of the same length
% Rebin     - re-bin and average statistical data
% SpecGoTo  - 3-axis spectrometer shaft angle for given (h,k,l,W)
% SpecWhere - wave vector and energy transfer for
%             given 3-axis spectrometer shaft angles
% Spurions  - potential false peaks and spurions at a given position
% 
%Examples and demos:
% MakeExp  -  Example of seting up a structure that contains 
%            details on experimental conditions for use 
%            with ResMat and ConvRes.
% SqwDemo  -  Example of a user cross section function 
%            for use with ConvRes.
% SMADemo  -  Example of a user single-mode cross section function 
%            for use with ConvResSMA.
% PrefDemo - Example of a  "slowly varying prefactor" 
%            function for use with ConvRes, ConvResSMA, SqwDemo and SMADemo.
% ConvDemo - A demo script of the convolution routines.
% FitDemo -  A demo script of the fitting routines.
% PlotDemo - A demo script of ResPlot.
% Plot3DDemo - A demo script for ResPlot3D.  
%
%
%  Written by A. Zheludev, 1999-2006
%  HFIR Center for Neutron Scattering, Oak Ridge National Laboratoy
%  Early versions developed at Physics Department, Brookhaven National Laboratory


disp('ResLib v.3.3. By A. Zheludev, Oak Ridge National Laboratoy, 1999-2006.');