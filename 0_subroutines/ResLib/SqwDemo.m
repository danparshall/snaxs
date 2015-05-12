function sqw=SqwDemo(H,K,L,W,p)
% This is an example of a cross section function for use with ConvRes.m.
% This particular function calculates the cross section for a gapped 
% excitations in a 1-dimensional antiferromagnet. "a" is the chain axis.
% The polarization factors for each mode are NOT calculated here, but
% should be included in the prefactor function instead. This function is
% meant to be used together with the prefactor function PrefDemo.m
% Arguments H-W and are vectors, so dont forget to use ".*" instead of "*", etc.
%  ResLib v.3.4
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory


% Extract the three parameters contained in "p":
Deltax=p(1);                    % Gap at the AF zone-center in meV for x-axis mode
Deltay=p(2);                    % Gap at the AF zone-center in meV for y-axis mode
Deltaz=p(3);                    % Gap at the AF zone-center in meV for z-axis mode
cc=p(4);                        % Bandwidth in meV 
Gamma=p(5);                     % Intrinsic HWHM of exccitation in meV
%I=p(6);                            % Intensity prefactor It will be used in the PrefDemo function, not here!
%bgr=p(7);                      % Background. It will be used in the PrefDemo function, not here!

% Calculate excitation energy at the (H,K,L) position for each of the three modes:
omegax=sqrt(cc^2*(sin(2*pi*H)).^2+Deltax^2);
omegay=sqrt(cc^2*(sin(2*pi*H)).^2+Deltay^2);
omegaz=sqrt(cc^2*(sin(2*pi*H)).^2+Deltaz^2);

% Assume Lorenzian excitation broadening:
lorx=1/pi*Gamma./( (W-omegax).^2+Gamma^2 );
lory=1/pi*Gamma./( (W-omegay).^2+Gamma^2 );
lorz=1/pi*Gamma./( (W-omegaz).^2+Gamma^2 );


% Intensity scales as (1-cos(2*pi*H))/omega0 for each of the three modes:
sqw(1,:)=lorx.*(1-cos(pi*H))./omegax/2;
sqw(2,:)=lory.*(1-cos(pi*H))./omegay/2;
sqw(3,:)=lorz.*(1-cos(pi*H))./omegaz/2;
