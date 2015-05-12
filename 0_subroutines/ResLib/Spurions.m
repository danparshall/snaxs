function Spurions(H,K,L,E,EXP)
%===================================================================================
%  function Spurions(H,K,L,E,EXP)
%  ResLib v.3.4
%===================================================================================
%
%  Display potential false peaks and spurions at a given scattering position.
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================

EXP=EXP(1); H=H(1);K=K(1);L=L(1);E=E(1);


[M1,M2,S1,S2,A1,A2]=specgoto(H,K,L,E,EXP);
[H1,K1,L1,E1,Q,Ei,Ef]=SpecWhere(M2,S1,S2,A2,EXP);

fprintf('\n\nNormal scattering:\n');
fprintf('  ki->kf    H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n\n',H,K,L,E,Q);

EXP1=EXP;

fprintf('Higher-order scattering in monochromator and analyzer:\n');

EXP1.mono.tau=GetTau(EXP.mono.tau)*2;
EXP1.ana.tau=GetTau(EXP.ana.tau);
[H1,K1,L1,E1,Q1,Ei1,Ef1]=SpecWhere(M2,S1,S2,A2,EXP1);
fprintf(' 2ki->kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.mono.tau)*3;
EXP1.ana.tau=GetTau(EXP.ana.tau);
[H1,K1,L1,E1,Q1,Ei1,Ef1]=SpecWhere(M2,S1,S2,A2,EXP1);
fprintf(' 3ki->kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.mono.tau);
EXP1.ana.tau=GetTau(EXP.ana.tau)*2;
[H1,K1,L1,E1,Q1]=SpecWhere(M2,S1,S2,A2,EXP1);
fprintf(' ki->2kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.mono.tau);
EXP1.ana.tau=GetTau(EXP.ana.tau)*3;
[H1,K1,L1,E1,Q1]=SpecWhere(M2,S1,S2,A2,EXP1);
fprintf(' ki->3kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.mono.tau)*2;
EXP1.ana.tau=GetTau(EXP.ana.tau)*2;
[H1,K1,L1,E1,Q1]=SpecWhere(M2,S1,S2,A2,EXP1);
fprintf('2ki->2kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.mono.tau)*2;
EXP1.ana.tau=GetTau(EXP.ana.tau)*3;
[H1,K1,L1,E1,Q1]=SpecWhere(M2,S1,S2,A2,EXP1);
fprintf('2ki->3kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.mono.tau)*3;
EXP1.ana.tau=GetTau(EXP.ana.tau)*2;
[H1,K1,L1,E1,Q1]=SpecWhere(M2,S1,S2,A2,EXP1);
fprintf('3ki->2kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.mono.tau)*3;
EXP1.ana.tau=GetTau(EXP.ana.tau)*3;
[H1,K1,L1,E1,Q1]=SpecWhere(M2,S1,S2,A2,EXP1);
fprintf('3ki->3kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n\n',H1,K1,L1,E1,Q1);


fprintf('Thermal-diffuse scattering in monochromator, elastic in sample:\n');
EXP1.mono.tau=GetTau(EXP.ana.tau);
EXP1.ana.tau=GetTau(EXP.ana.tau);
[H1,K1,L1,E1,Q1,Ei1,Ef1]=SpecWhere(A2,S1,S2,A2,EXP1);
fprintf('  ki->kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.ana.tau)*2;
EXP1.ana.tau=GetTau(EXP.ana.tau)*2;
[H1,K1,L1,E1,Q1,Ei1,Ef1]=SpecWhere(A2,S1,S2,A2,EXP1);
fprintf('2kf->2kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.ana.tau)*3;
EXP1.ana.tau=GetTau(EXP.ana.tau)*3;
[H1,K1,L1,E1,Q1,Ei1,Ef1]=SpecWhere(A2,S1,S2,A2,EXP1);
fprintf('3kf->3kf:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n\n',H1,K1,L1,E1,Q1);

fprintf('Thermal-diffuse scattering in analyzer, elastic in sample:\n');
EXP1.mono.tau=GetTau(EXP.mono.tau);
EXP1.ana.tau=GetTau(EXP.mono.tau);
[H1,K1,L1,E1,Q1,Ei1,Ef1]=SpecWhere(A2,S1,S2,A2,EXP1);
fprintf('  ki->ki:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.mono.tau)*2;
EXP1.ana.tau=GetTau(EXP.mono.tau)*2;
[H1,K1,L1,E1,Q1,Ei1,Ef1]=SpecWhere(A2,S1,S2,A2,EXP1);
fprintf('2ki->2ki:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n',H1,K1,L1,E1,Q1);

EXP1.mono.tau=GetTau(EXP.mono.tau)*3;
EXP1.ana.tau=GetTau(EXP.mono.tau)*3;
[H1,K1,L1,E1,Q1,Ei1,Ef1]=SpecWhere(A2,S1,S2,A2,EXP1);
fprintf('3ki->3ki:   H=%10.4g         K=%10.4g        L=%10.4g        E=%10.4g meV        Q=%10.4g A-1 \n\n',H1,K1,L1,E1,Q1);



fprintf('Reminder: for Al, Q111=7.0775, Q200=8.1724, Q220=11.558, and Q311=13.552 \n',H1,K1,L1,E1,Q1);
