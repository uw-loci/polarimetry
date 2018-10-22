function [depol,rotation, D, lin_reta, orientation1]=polardecomposition_paper_FASTER(muel)

warning('off','all')
warning('off','MATLAB:singularMatrix');

I=[1 0 0;
   0 1 0;
   0 0 1];

% ###########################diattenuation matrix############################################################
% functional form of R is given as ###### R=acos[2*cos(theta)^2*cos(delta/2)^2-1]  ####################

pvec=[muel(2,1),muel(3,1),muel(4,1)]*(1/muel(1,1));
dvec=[muel(1,2),muel(1,3),muel(1,4)]*(1/muel(1,1));

%#############diattenuation##################

D=((muel(1,2)^2+muel(1,3)^2+muel(1,4)^2)^0.5)*(1/muel(1,1)); % for linear diattenuation only first three elements of first row are required
                                                             % magnitude of diattenuation vector ('d' in paper)
%############################################

m=(1/muel(1,1))*[muel(2,2),muel(2,3),muel(2,4);              % 3x3, normalized mueller
                 muel(3,2),muel(3,3),muel(3,4);
                 muel(4,2),muel(4,3),muel(4,4)];
             
D1=(1-D^2)^0.5;


if D==0                                               %if there is no diattenuation
    muel_0=muel/muel(1,1);                                    % continue with muel as is
else                                                  %if there is diattenuation
    mD=D1*I+(1-D1)*dvec'*dvec/D^2;                            % 3x3 matrix m_D
    MD=muel(1,1)*[1,dvec;
                  dvec',mD];                                  % 4x4 matrix M_D (diattenuation matrix)
    muel_0=muel*inv(MD);                                      % continue with muel_0 such that [muel_0 * MD = muel]
    
end


%####################################### depolarization matrix###################################################################

m_1=[muel_0(2,2) muel_0(2,3) muel_0(2,4);                    % 3x3 matrix m_1 = what's left 
     muel_0(3,2) muel_0(3,3) muel_0(3,4);                    %      after diattenuation effect is removed
     muel_0(4,2) muel_0(4,3) muel_0(4,4)];

%m_1=m_1';
try
l_0=eig(m_1*m_1');                                           % eigenvalues of m_1 * m_1'
catch
    l_0=eig(eye(3));
end
    
m_0=inv(m_1*m_1'+((l_0(1)*l_0(2))^0.5+(l_0(2)*l_0(3))^0.5+(l_0(3)*l_0(1))^0.5)*I);   %3x3 matrix, inverse of big thing
m_00=(l_0(1)^0.5+l_0(2)^0.5+l_0(3)^0.5)*m_1*m_1'+I*(l_0(1)*l_0(2)*l_0(3))^0.5;

if det(m_1)>=0
    mdelta=m_0*m_00;                                         % 3x3 depolarization matrix
else
    mdelta=-m_0*m_00;                                        % add a minus sign if det(m_1) is negative
end

try
[v,mdeltaf] = eig(mdelta);                                         % mdeltaf is a diagonal matrix containing the eigenvalues of mdelta                        
catch
    [v,mdeltaf] = eig(eye(3));
end
depol=1-(abs(mdelta(1,1))+abs(mdelta(2,2))+abs(mdelta(3,3)))/3;    % this is the, as opposed to degree of pol...
degpolc = sqrt((muel(2,1)+muel(2,4))^2+(muel(3,1)+muel(3,4))^2+(muel(4,1)+muel(4,4))^2)/ (muel(1,1)+ muel(1,4));
degpoll = 0.5*(  ...     
   sqrt((muel(2,1)+muel(2,2))^2+(muel(3,1)+muel(3,2))^2+(muel(4,1)+muel(4,2))^2)/(muel(1,1) + muel(1,4))...
   + ...
   ((muel(2,1)+muel(2,3))^2+(muel(3,1)+muel(3,3))^2+(muel(4,1)+muel(4,3))^2)/(muel(1,1)+muel(1,3))      );
nul=(pvec'-m*dvec')/D1^2;                                          % what's this??

Mdelta=[1 0 0 0;                                             % 4x4 depolatization matrix
   nul mdelta];
   
Mdeltaf =[1 0 0 0;                                           % 4x4 depol eigenvalues matrix
        nul mdeltaf];

Mdinv=inv(Mdelta);                                           % inverse of depolarization matrix


%############################################## Retarder matrix ###########################################

MR=Mdinv*muel_0;                                             % such that MR*Mdelta*M_D = muel


trmR=(MR(2,2)+MR(3,3)+MR(4,4))/2;                            % tr(MR)/2
argu=trmR-1/2;                                               % MANUSCRIPT SAYS -1, not1/2...

if argu > 1                                      
    R=acos(1);                                                
elseif argu < -1   
    R=acos(-1);                                                                                           
else                                                    % i.e. -1 < argu < 1
    R=acos(argu);                                       % R = total retardance (linear and circular)
end


%LINEAR RETARDANCE

de=((MR(2,2)+MR(3,3))^2+(MR(3,2)-MR(2,3))^2)^0.5-1;      % just some argument                                

if de>0.999999999999, de=1; elseif de<-0.99999999999, de=-1; end

lin_reta=acos(de);

%OPTICAL ROTATION

tan_rot=(MR(3,2)-MR(2,3))/(abs(MR(2,2))+abs(MR(3,3)));
rotation=atan(tan_rot);                                         % optical rotation (phi)

if tan_rot<0.000000001
    rotation=rotation+pi;
end

rotation=rotation/2;                                            % why??

%if (MR(3,2)-MR(2,3))<0.0 
%    if (MR(2,2)+MR(3,3))<0.0    
%        rotation=rotation+pi/2;
%    end
%end
% 
%if (MR(3,2)-MR(2,3))<0.0 
%    if (MR(2,2)+MR(3,3))>0.0
%       rotation=rotation+pi/2;
%    end
%end

% effectively all this does is 

if (MR(3,2)-MR(2,3))<0.0 & (MR(2,2)+MR(3,3))~=0.0
   rotation = rotation + pi/2;                                             % again, why?
end


if abs(MR(3,2)-MR(2,3))<=0.000000001 & MR(2,2)+MR(3,3)>0.0000000001
    rotation=0;
end


% LINEAR RETARDANCE VECTOR

if abs(sin(R))<=0.000000001                                         % ie. R ~ 0 
   a3=((1+cos(lin_reta))/2)^0.5;
   a1=(MR(3,4)+MR(4,3))/(4*a3);
   a2=(MR(4,2)+MR(2,4))/(4*a3);
else
    D2=1/(2*sin(R));                                                % using R instead of delta as in paper
    a1=D2*(MR(3,4)-MR(4,3));                                        %        and MR instead of MLR
    a2=D2*(MR(4,2)-MR(2,4));
    a3=D2*(MR(2,3)-MR(3,2));
 end

rvec=[1,a1,a2,a3]';                                                 % linear retardance vector ?


%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

if abs(cos(R))>=0.9999999999                                 % for special cases where R = pi/2 or -pi/2
    
    C1=MR(2,2)+MR(3,3);
    C2=MR(2,3)-MR(3,2);

    if abs(C1)<0.0000000001
        % it means linear retardance is = pi    
        MR=MR*[1 0 0 0; 0 1 0 0; 0 0 -1 0; 0 0 0 -1];
        rotation=0.5*acos((MR(2,2)+MR(3,3))/2);
        lin_reta=pi;
    end
    
    if C1<1.999999999 & abs(C2)<0.0000000001
        % it means rotation is pi/2
            MR=MR*[1 0 0 0; 0 -1 0 0; 0 0 -1 0; 0 0 0 1];        
            dum=MR(2,2)+MR(3,3)-1;
        
            if dum>=1, lin_reta=0;            
            elseif dum<=-1, lin_reta=pi;    
            else lin_reta=acos(dum);
            end
        
            rotation=pi/2;
    end
    
end


% ORIENTATION OF LINEAR RETARDANCE

mrr1=MR*inv(rota(rotation));                                        % linear retardance matrix = MLR?
mrr2=inv(rota(rotation))*MR;                                        % NB matrix multiplication is not commutative

%mrr1 = MR;
%mrr2 = MR;

% Calculate Stokes vector of orientation of birefringence for each
% multiplication order (mrr1, mrr2), from Lu and Chipman page 3.

% Stokes vector for first order, mrr1
a1 = 1;                         % I
a2 = mrr1(3,4)-mrr1(4,3);       % Q
a3 = mrr1(4,2)-mrr1(2,4);       % U
a4 = mrr1(2,4)-mrr1(3,4);       % V, don't use this but here anyway

% Now from the Stokes vector calculate the orientation based on Q and U
% Need to deal with 

if a2 > 0 & a3 > 0
    orientation1 = 0.5*atan(a3/a2);
elseif a2 < 0 & a3 > 0;
    orientation1 = 0.5*atan(a3/a2) + pi/2;
elseif a2 < 0 & a3 < 0
    orientation1 = 0.5*atan(a3/a2)+ pi/2;
elseif a2 > 0 & a3 < 0
    orientation1 = 0.5*atan(a3/a2) + pi;
elseif a2 == 0 & a3 < 0;
    orientation1 = 3*pi/4;
elseif a2 == 0 & a3 > 0;
    orientation1 = pi/4;
elseif a2 > 0 & a3 == 0;
    orientation1 = 0;
elseif a2 < 0 & a3 == 0;
    orientation1 = pi/2;
else
    orientation1 = 0;
end

% Stokes vector for second order, mrr2
b1 = 1;                         % I
b2 = mrr2(3,4)-mrr2(4,3);       % Q
b3 = mrr2(4,2)-mrr2(2,4);       % U
b4 = mrr2(2,4)-mrr2(3,4);       % V, don't use this but here anyway


% Now from the Stokes vector calculate the orientation based on Q and U
%if b2 < 0
%    orientation2 = 0.5*atan(b3/b2) + pi/2;                      % if Q is negative must add pi/2 to orentation
%elseif b2 > 0 & b3 > 0
%    orientation2 = 0.5*atan(b3/b2);                             % if Q and U are positive 
%elseif b2 > 0 & b3 < 0
%    orientation2 = 0.5*atan(b3/b2) + pi;                        % if Q is positive and U is negative
%elseif b2 == 0 & b3 > 0
%    orientation2 = pi/4;                                        % if Q is 0 and U is positive
%elseif b2 == 0 & b3 < 0
%    orientation2 = 3*pi/4;                                      % if Q is 0 and U is negative 
%else
%    orientation2 = [];                                          % if there is no birefringence 
%end

if b2 > 0 & b3 > 0
    orientation2 = 0.5*atan(b3/b2);
elseif b2 < 0 & b3 > 0;
    orientation2 = 0.5*atan(b3/b2) + pi/2;
elseif b2 < 0 & b3 < 0
    orientation2 = 0.5*atan(b3/b2)+ pi/2;
elseif b2 > 0 & b3 < 0
    orientation2 = 0.5*atan(b3/b2) + pi;
elseif b2 == 0 & b3 < 0;
    orientation2 = 3*pi/4;
elseif b2 == 0 & b3 > 0;
    orientation2 = pi/4;
elseif b2 > 0 & b3 == 0;
    orientation2 = 0;
elseif b2 < 0 & b3 == 0;
    orientation2 = pi/2;
else
    orientation2 = 0;
end

% denom1=(mrr1(3,4)-mrr1(4,3));                                       % r1
% num1=(mrr1(4,2)-mrr1(2,4));                                         % r2  
% denom2=(mrr2(3,4)-mrr2(4,3));
% num2=(mrr2(4,2)-mrr2(2,4));
% if denom1~= 0, orientation1= 0.5*atan(num1/denom1);                % orientation = 0.5*atan(r2/r1)
% else orientation1 = []; end
% if denom2~=0, orientation2= 0.5*atan(num2/denom2);
% else orientation2 = []; end

%orientation = 0.5*acos(mrr(3,4)/sin(lin_reta));
%orientation1= 0.5*atan(MR(2,4)/MR(3,4))
%orientation2= 0.5*atan(MR(4,2)/MR(4,3))
%orientation = (abs(orientation1)+abs(orientation2))/2

return