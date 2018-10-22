% %% Set paramaters
filepath = '/Volumes/AdamUSB/2018.09.27/100 micron';
blank = '/blank'; %Name blank sample directory
results = '/Results';
num_steps=20;
sample= '/1057_100';
sample_M='/1057_100_M';

%% Set Decomposition parameters
Coregistration = 1; % 1=true(calculate here) 2=true (use previous file) 0=false
Decomposition = 1; %1=True 0=False
filter = 0; % 1=true 0=false
EigenvalueCalibration = 0; % 1=true 0=false
longexposure = 0;
resize = 1;
coreg_small = 1;
SingleBlank = 1;
Save = 1; %1 = true(saves) 0=false

%% Load Data
tic

% Load Sample Polarizations (Sout)
data = bfopen(sprintf('%s%s',filepath, sample,'.czi'));

HHout=single(data{1, 1}{1, 1});
HBout=single(data{1, 1}{2, 1});
HPout=single(data{1, 1}{3, 1});
HVout=single(data{1, 1}{4, 1});
HRout=single(data{1, 1}{19, 1});
HLout=single(data{1, 1}{24, 1});

PHout=single(data{1, 1}{7, 1});
PBout=single(data{1, 1}{8, 1});
PPout=single(data{1, 1}{6, 1});
PVout=single(data{1, 1}{5, 1});
PRout=single(data{1, 1}{20, 1});
PLout=single(data{1, 1}{23, 1});

VHout=single(data{1, 1}{10, 1});
VBout=single(data{1, 1}{9, 1});
VPout=single(data{1, 1}{11, 1});
VVout=single(data{1, 1}{12, 1});
VRout=single(data{1, 1}{21, 1});
VLout=single(data{1, 1}{22, 1});

RHout=single(data{1, 1}{15, 1});
RBout=single(data{1, 1}{16, 1});
RPout=single(data{1, 1}{14, 1});
RVout=single(data{1, 1}{13, 1});
RRout=single(data{1, 1}{18, 1});
RLout=single(data{1, 1}{17, 1});

clear data

time_LoadCZI1=toc

%% Select Region of Interest
BW=zeros(size(HHout,1),size(HHout,2));
BW(50:size(HHout,1)-50,50:size(HHout,2)-50)=1; %aviuds potential edge effects from coregistration during Mueller calculations

stepsize=floor(size(HHout,2)/num_steps);

%% Co-Register Polarization Images

% Find co-registration transforms
if Coregistration == 1
    tic    

    if coreg_small == 1
        y1=floor(size(HHout,1)/2)-512;
        y2=floor(size(HHout,1)/2)+512;
        x1=floor(size(HHout,2)/2)-512;
        x2=floor(size(HHout,2)/2)+512;
    else
        x1=1;
        x2=floor(size(HHout,1));
        y1=1;
        y2=floor(size(HHout,2));
    end
    
    [optimizer, metric] = imregconfig('multimodal');
    optimizer.InitialRadius = 0.003;
    optimizer.Epsilon = 1.5e-4;
    optimizer.GrowthFactor = 1.01;
    optimizer.MaximumIterations = 500; %300?

    tformB = imregtform(HBout(y1:y2,x1:x2), HHout(y1:y2,x1:x2), 'rigid', optimizer, metric);
    tformP = imregtform(HPout(y1:y2,x1:x2), HHout(y1:y2,x1:x2), 'rigid', optimizer, metric);
    tformR = imregtform(HRout(y1:y2,x1:x2), HHout(y1:y2,x1:x2), 'rigid', optimizer, metric);
    tformL = imregtform(HLout(y1:y2,x1:x2), HHout(y1:y2,x1:x2), 'rigid', optimizer, metric);
    tformV = imregtform(VVout(y1:y2,x1:x2), HHout(y1:y2,x1:x2), 'rigid', optimizer, metric);    

   time_coreg_find=toc   
end

% Co-register Images
if Coregistration > 0 %could add option to use precalculated transforms
    tic
    
    HBout = imwarp(HBout,tformB,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    HPout = imwarp(HPout,tformP,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    HVout = imwarp(HVout,tformV,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    HRout = imwarp(HRout,tformR,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    HLout = imwarp(HLout,tformL,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
%     VHout = imwarp(VHout,tformVH,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    VBout = imwarp(VBout,tformB,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    VPout = imwarp(VPout,tformP,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    VVout = imwarp(VVout,tformV,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    VRout = imwarp(VRout,tformR,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    VLout = imwarp(VLout,tformL,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
%     PHout = imwarp(PHout,tformPH,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    PBout = imwarp(PBout,tformB,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    PPout = imwarp(PPout,tformP,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    PVout = imwarp(PVout,tformV,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    PRout = imwarp(PRout,tformR,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    PLout = imwarp(PLout,tformL,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
%     RHout = imwarp(RHout,tformRH,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    RBout = imwarp(RBout,tformB,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    RPout = imwarp(RPout,tformP,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    RVout = imwarp(RVout,tformV,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    RRout = imwarp(RRout,tformR,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    RLout = imwarp(RLout,tformL,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));

    time_coreg1=toc
end
 %% Calculate Output Stokes Vectors
 tic
 
    H_Iout=((HHout+HVout)+(HPout+HBout))/2;
    H_Qout=(HHout-HVout);
    H_Uout=(HPout-HBout);
    H_Vout=(HRout-HLout);

    P_Iout=((PHout+PVout)+(PPout+PBout))/2;
    P_Qout=(PHout-PVout);
    P_Uout=(PPout-PBout);
    P_Vout=(PRout-PLout);
    
    V_Iout=((VHout+VVout)+(VPout+VBout))/2;
    V_Qout=(VHout-VVout);
    V_Uout=(VPout-VBout);
    V_Vout=(VRout-VLout);

    R_Iout=((RHout+RVout)+(RPout+RBout))/2;
    R_Qout=(RHout-RVout);
    R_Uout=(RPout-RBout);
    R_Vout=(RRout-RLout);
    
    Sout=single(zeros(4,4,size(HHout,1)*stepsize));
    
for i = 1:num_steps
    
    H_Iout_temp=H_Iout(:,(i-1)*stepsize+1:i*stepsize);
    H_Qout_temp=H_Qout(:,(i-1)*stepsize+1:i*stepsize);
    H_Uout_temp=H_Uout(:,(i-1)*stepsize+1:i*stepsize);
    H_Vout_temp=H_Vout(:,(i-1)*stepsize+1:i*stepsize);
    
    P_Iout_temp=P_Iout(:,(i-1)*stepsize+1:i*stepsize);
    P_Qout_temp=P_Qout(:,(i-1)*stepsize+1:i*stepsize);
    P_Uout_temp=P_Uout(:,(i-1)*stepsize+1:i*stepsize);
    P_Vout_temp=P_Vout(:,(i-1)*stepsize+1:i*stepsize);
    
    V_Iout_temp=V_Iout(:,(i-1)*stepsize+1:i*stepsize);
    V_Qout_temp=V_Qout(:,(i-1)*stepsize+1:i*stepsize);
    V_Uout_temp=V_Uout(:,(i-1)*stepsize+1:i*stepsize);
    V_Vout_temp=V_Vout(:,(i-1)*stepsize+1:i*stepsize);
    
    R_Iout_temp=R_Iout(:,(i-1)*stepsize+1:i*stepsize);
    R_Qout_temp=R_Qout(:,(i-1)*stepsize+1:i*stepsize);
    R_Uout_temp=R_Uout(:,(i-1)*stepsize+1:i*stepsize);
    R_Vout_temp=R_Vout(:,(i-1)*stepsize+1:i*stepsize);

    parfor z = 1:size(HHout,1)*stepsize
        
        Sout(:,:,z)=[ H_Iout_temp(z) P_Iout_temp(z) V_Iout_temp(z) R_Iout_temp(z);
                      H_Qout_temp(z) P_Qout_temp(z) V_Qout_temp(z) R_Qout_temp(z);
                      H_Uout_temp(z) P_Uout_temp(z) V_Uout_temp(z) R_Uout_temp(z);
                      H_Vout_temp(z) P_Vout_temp(z) V_Vout_temp(z) R_Vout_temp(z) ];
    end
    
    save(sprintf('%s%s',filepath,results,sample,sample,'_Sout_',num2str(i),'.mat'), 'Sout')
 
end

    clearvars -regexp out$ -except Sout HHout

    time_calculate_Sout=toc
%% Load Input Polarizations (Sin)
tic

datain = bfopen(sprintf('%s%s',filepath, blank,'.czi'));

HH_blank=single(datain{1, 1}{1, 1});
HB_blank=single(datain{1, 1}{2, 1});
HP_blank=single(datain{1, 1}{3, 1});
HV_blank=single(datain{1, 1}{4, 1});
HR_blank=single(datain{1, 1}{19, 1});
HL_blank=single(datain{1, 1}{24, 1});
PH_blank=single(datain{1, 1}{7, 1});
PB_blank=single(datain{1, 1}{8, 1});
PP_blank=single(datain{1, 1}{6, 1});
PV_blank=single(datain{1, 1}{5, 1});
PR_blank=single(datain{1, 1}{20, 1});
PL_blank=single(datain{1, 1}{23, 1});
VH_blank=single(datain{1, 1}{10, 1});
VB_blank=single(datain{1, 1}{9, 1});
VP_blank=single(datain{1, 1}{11, 1});
VV_blank=single(datain{1, 1}{12, 1});
VR_blank=single(datain{1, 1}{21, 1});
VL_blank=single(datain{1, 1}{22, 1});
RH_blank=single(datain{1, 1}{15, 1});
RB_blank=single(datain{1, 1}{16, 1});
RP_blank=single(datain{1, 1}{14, 1});
RV_blank=single(datain{1, 1}{13, 1});
RR_blank=single(datain{1, 1}{18, 1});
RL_blank=single(datain{1, 1}{17, 1});

clear datain;

time_loadCZI2=toc

%%
if SingleBlank==1
    
    tic
    
    size_yblank=size(HHout,1);
    size_xblank=size(HHout,2);
    num_tile_y=floor(size_yblank/1844);
    num_tile_x=floor(size_xblank/1844);

    HH_in=zeros(num_tile_y*1844+2048-1844, num_tile_x*1844+2048-1844);

for j=1:num_tile_y;
    for i = 1:num_tile_x;   
 
        row=rem(j,2);
        
        if row>0 
            HHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=HH_blank;
            HBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=HB_blank;
            HPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=HP_blank;
            HVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=HV_blank;
            HRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=HR_blank;
            HLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=HL_blank;  
            PHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=PH_blank;
            PBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=PB_blank;
            PPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=PP_blank;
            PVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=PV_blank;
            PRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=PR_blank;
            PLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=PL_blank;
            
            VHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=VH_blank;
            VBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=VB_blank;
            VPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=VP_blank;
            VVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=VV_blank;
            VRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=VR_blank;
            VLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=VL_blank;
            
            RHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=RH_blank;
            RBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=RB_blank;
            RPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=RP_blank;
            RVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=RV_blank;
            RRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=RR_blank;
            RLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*1844+(2048-1844))=RL_blank;
        end
        
        if row==0     
            if i == 1
                HHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=HH_blank; 
                HBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=HB_blank; 
                HPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=HP_blank; 
                HVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=HV_blank; 
                HRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=HR_blank; 
                HLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=HL_blank; 
                
                PHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=PH_blank; 
                PBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=PB_blank; 
                PPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=PP_blank; 
                PVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=PV_blank; 
                PRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=PR_blank; 
                PLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=PL_blank; 
                
                VHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=VH_blank; 
                VBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=VB_blank; 
                VPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=VP_blank; 
                VVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=VV_blank; 
                VRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=VR_blank; 
                VLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=VL_blank; 

                RHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=RH_blank; 
                RBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=RB_blank; 
                RPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=RP_blank; 
                RVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=RV_blank; 
                RRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=RR_blank; 
                RLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+1:i*2048)=RL_blank; 
                
            else        
                HHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = HH_blank(:,2048-1844+1:2048);
                HBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = HB_blank(:,2048-1844+1:2048);           
                HPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = HP_blank(:,2048-1844+1:2048);       
                HVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = HV_blank(:,2048-1844+1:2048);           
                HRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = HR_blank(:,2048-1844+1:2048);           
                HLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = HL_blank(:,2048-1844+1:2048);           
                
                PHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = PH_blank(:,2048-1844+1:2048);
                PBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = PB_blank(:,2048-1844+1:2048);           
                PPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = PP_blank(:,2048-1844+1:2048);       
                PVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = PV_blank(:,2048-1844+1:2048);           
                PRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = PR_blank(:,2048-1844+1:2048);           
                PLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = PL_blank(:,2048-1844+1:2048);           
                
                VHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = VH_blank(:,2048-1844+1:2048);
                VBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = VB_blank(:,2048-1844+1:2048);           
                VPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = VP_blank(:,2048-1844+1:2048);       
                VVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = VV_blank(:,2048-1844+1:2048);           
                VRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = VR_blank(:,2048-1844+1:2048);           
                VLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = VL_blank(:,2048-1844+1:2048);           
                
                RHin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = RH_blank(:,2048-1844+1:2048);
                RBin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = RB_blank(:,2048-1844+1:2048);           
                RPin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = RP_blank(:,2048-1844+1:2048);       
                RVin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = RV_blank(:,2048-1844+1:2048);           
                RRin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = RR_blank(:,2048-1844+1:2048);           
                RLin((j-1)*1844+1:j*1844+(2048-1844), (i-1)*1844+(2048-1844)+1:i*1844+(2048-1844)) = RL_blank(:,2048-1844+1:2048);           
            end
        end
              
    end
end

time_assemble_blank=toc
end
% Resize images
if resize == 1   %Resize_dim
    tic
    
    newsize=[size(HHout,1) size(HHout,2)];
    
    HHin=imresize(HHin, newsize);
    HBin=imresize(HBin, newsize);
    HPin=imresize(HPin, newsize);
    HVin=imresize(HVin, newsize);
    HRin=imresize(HRin, newsize);
    HLin=imresize(HLin, newsize);
    PHin=imresize(PHin, newsize);
    PBin=imresize(PBin, newsize);
    PPin=imresize(PPin, newsize);
    PVin=imresize(PVin, newsize);
    PRin=imresize(PRin, newsize);
    PLin=imresize(PLin, newsize); 
    VHin=imresize(VHin, newsize);
    VBin=imresize(VBin, newsize);
    VPin=imresize(VPin, newsize);
    VVin=imresize(VVin, newsize);
    VRin=imresize(VRin, newsize);
    VLin=imresize(VLin, newsize);
    RHin=imresize(RHin, newsize);
    RBin=imresize(RBin, newsize);
    RPin=imresize(RPin, newsize);
    RVin=imresize(RVin, newsize);
    RRin=imresize(RRin, newsize);
    RLin=imresize(RLin, newsize);

    toc;
    time_resize=toc
end
 
% Co-register Images
if Coregistration > 0 %could add option to use precalculated transforms
    tic
    
    HBin = imwarp(HBin,tformB,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    HPin = imwarp(HPin,tformP,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    HVin = imwarp(HVin,tformV,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    HRin = imwarp(HRin,tformR,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    HLin = imwarp(HLin,tformL,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    VBin = imwarp(VBin,tformB,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    VPin = imwarp(VPin,tformP,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    VVin = imwarp(VVin,tformV,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    VRin = imwarp(VRin,tformR,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    VLin = imwarp(VLin,tformL,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    PBin = imwarp(PBin,tformB,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    PPin = imwarp(PPin,tformP,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    PVin = imwarp(PVin,tformV,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    PRin = imwarp(PRin,tformR,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    PLin = imwarp(PLin,tformL,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    RBin = imwarp(RBin,tformB,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    RPin = imwarp(RPin,tformP,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    RVin = imwarp(RVin,tformV,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    RRin = imwarp(RRin,tformR,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
    RLin = imwarp(RLin,tformL,'OutputView',imref2d([size(HHout,1),size(HHout,2)]));
  
    time_coreg2=toc
end

%% Calculate Input Stokes Vectors

if EigenvalueCalibration == 0 
    tic   
    
    %  Calculate Input Stokes Vectors
    H_Iin=((HHin+HVin)+(HPin+HBin))/2;
    H_Qin=(HHin-HVin);
    H_Uin=(HPin-HBin);
    H_Vin=(HRin-HLin);

    P_Iin=((PHin+PVin)+(PPin+PBin))/2;
    P_Qin=(PHin-PVin);
    P_Uin=(PPin-PBin);
    P_Vin=(PRin-PLin);

    V_Iin=((VHin+VVin)+(VPin+VBin))/2;
    V_Qin=(VHin-VVin);
    V_Uin=(VPin-VBin);
    V_Vin=(VRin-VLin);

    R_Iin=((RHin+RVin)+(RPin+RBin))/2;
    R_Qin=(RHin-RVin);
    R_Uin=(RPin-RBin);
    R_Vin=(RRin-RLin);

    Sin=single(zeros(4,4,size(HHout,1)*stepsize)); %define size before loop
    
for i = 1:num_steps
    
    H_Iin_temp=H_Iin(:,(i-1)*stepsize+1:i*stepsize);
    H_Qin_temp=H_Qin(:,(i-1)*stepsize+1:i*stepsize);
    H_Uin_temp=H_Uin(:,(i-1)*stepsize+1:i*stepsize);
    H_Vin_temp=H_Vin(:,(i-1)*stepsize+1:i*stepsize);
    
    P_Iin_temp=P_Iin(:,(i-1)*stepsize+1:i*stepsize);
    P_Qin_temp=P_Qin(:,(i-1)*stepsize+1:i*stepsize);
    P_Uin_temp=P_Uin(:,(i-1)*stepsize+1:i*stepsize);
    P_Vin_temp=P_Vin(:,(i-1)*stepsize+1:i*stepsize);
    
    V_Iin_temp=V_Iin(:,(i-1)*stepsize+1:i*stepsize);
    V_Qin_temp=V_Qin(:,(i-1)*stepsize+1:i*stepsize);
    V_Uin_temp=V_Uin(:,(i-1)*stepsize+1:i*stepsize);
    V_Vin_temp=V_Vin(:,(i-1)*stepsize+1:i*stepsize);
    
    R_Iin_temp=R_Iin(:,(i-1)*stepsize+1:i*stepsize);
    R_Qin_temp=R_Qin(:,(i-1)*stepsize+1:i*stepsize);
    R_Uin_temp=R_Uin(:,(i-1)*stepsize+1:i*stepsize);
    R_Vin_temp=R_Vin(:,(i-1)*stepsize+1:i*stepsize);
    
    parfor z = 1:size(HHout,1)*stepsize
      
        Sin(:,:,z)=[ H_Iin_temp(z) P_Iin_temp(z) V_Iin_temp(z) R_Iin_temp(z);
                     H_Qin_temp(z) P_Qin_temp(z) V_Qin_temp(z) R_Qin_temp(z);
                     H_Uin_temp(z) P_Uin_temp(z) V_Uin_temp(z) R_Uin_temp(z);
                     H_Vin_temp(z) P_Vin_temp(z) V_Vin_temp(z) R_Vin_temp(z) ];
    end
    
    save(sprintf('%s%s',filepath,results,sample,sample,'_Sin_',num2str(i),'.mat'), 'Sin')
end

    clearvars -regexp in$ -except Sin
  
time_calculate_Sin=toc
end

%% Find Mueller matrix

% Generate Mueller matrix variables
m11=single(zeros(size(HHout,1),stepsize));
m12=single(zeros(size(HHout,1),stepsize));
m13=single(zeros(size(HHout,1),stepsize));
m14=single(zeros(size(HHout,1),stepsize));
m21=single(zeros(size(HHout,1),stepsize));
m22=single(zeros(size(HHout,1),stepsize));
m23=single(zeros(size(HHout,1),stepsize));
m24=single(zeros(size(HHout,1),stepsize));
m31=single(zeros(size(HHout,1),stepsize));
m32=single(zeros(size(HHout,1),stepsize));
m33=single(zeros(size(HHout,1),stepsize));
m34=single(zeros(size(HHout,1),stepsize));
m41=single(zeros(size(HHout,1),stepsize));
m42=single(zeros(size(HHout,1),stepsize));
m43=single(zeros(size(HHout,1),stepsize));
m44=single(zeros(size(HHout,1),stepsize));
 
%% Find Mueller

M = single(zeros(4,4));
time_Mueller=zeros(num_steps,1);
time_decomp=zeros(num_steps,1);
    
depol_mat = single(zeros(size(HHout,1),stepsize));
diattenuation_mat = single(zeros(size(HHout,1),stepsize));
lin_reta_mat = single(zeros(size(HHout,1),stepsize));
orientation1_mat = single(zeros(size(HHout,1),stepsize));
rotation_mat = single(zeros(size(HHout,1),stepsize));


for i = 1:num_steps

    tic
    
    load(sprintf('%s%s',filepath,results,sample,sample,'_Sin_',num2str(i),'.mat'), 'Sin');
    load(sprintf('%s%s',filepath,results,sample,sample,'_Sout_',num2str(i),'.mat'), 'Sout');
    
    col_start=(i-1)*stepsize+1;
    col_end= i*stepsize;
    
    BW_temp=BW(:,col_start:col_end);
    
    parfor z = 1:size(HHout,1)*stepsize
        
        if BW_temp(z) == 1 
          
           M=Sout(:,:,z)/Sin(:,:,z);
           
        else %Necessary??
            
           M=[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1]; %If outside of desired area, M is set to identity matrix
        
        end        
                 
        m11(z)=M(1,1);
        m12(z)=M(1,2);
        m13(z)=M(1,3);
        m14(z)=M(1,4);
        m21(z)=M(2,1);
        m22(z)=M(2,2);
        m23(z)=M(2,3);
        m24(z)=M(2,4);
        m31(z)=M(3,1);
        m32(z)=M(3,2);
        m33(z)=M(3,3);
        m34(z)=M(3,4);
        m41(z)=M(4,1);
        m42(z)=M(4,2);
        m43(z)=M(4,3);
        m44(z)=M(4,4);

%% Matrix Decomposition

        if Decomposition == 1 % Uses polardecomposition_paper.m
    
%           stepsize=floor(size(HHout,2)/num_steps);
    
        %Normalize Mueller matrix for decomposition 
%  *******(necessary?)
                 
                muel= (1/m11(z))* [m11(z) m12(z) m13(z) m14(z);
                                   m21(z) m22(z) m23(z) m24(z);
                                   m31(z) m32(z) m33(z) m34(z);
                                   m41(z) m42(z) m43(z) m44(z) ];              
                                     
% Recover decomposition paramaters from decomposition function
            
                [depol, rotation, D, lin_reta, orientation1]=polardecomposition_paper_FASTER(muel);
  
% save all decomposition parameters in appropriate pixel location
                depol_mat(z) = depol*100;
                diattenuation_mat(z)=D*100;
                lin_reta_mat(z) = lin_reta*180/pi;
                rotation_mat(z) = rotation;
                orientation1_mat(z) = orientation1*180/pi;

        end
    end
    
    save(sprintf('%s%s',filepath,results,sample,sample,'_',num2str(i),'.mat'), 'depol_mat', 'lin_reta_mat', 'diattenuation_mat', 'orientation1_mat', 'rotation_mat');
    save(sprintf('%s%s',filepath,results,sample_M,sample,'_M_',num2str(i),'.mat'), 'M');
    time_decomp(i)=toc

end

time_decomp_total=sum(time_decomp)

%% Reassemble images
tic

LR_final=zeros(size(m11));
Depol_final=zeros(size(m11));
Diatten_final=zeros(size(m11));
Orient_final=zeros(size(m11));

for i = 1:num_steps
    load(sprintf('%s%s',filepath,results,sample,sample,'_',num2str(i),'.mat'), 'lin_reta_mat');
    load(sprintf('%s%s',filepath,results,sample,sample,'_',num2str(i),'.mat'), 'depol_mat');
    load(sprintf('%s%s',filepath,results,sample,sample,'_',num2str(i),'.mat'), 'diattenuation_mat');
    load(sprintf('%s%s',filepath,results,sample,sample,'_',num2str(i),'.mat'), 'orientation1_mat');
    
    col_start=(i-1)*stepsize+1;
    col_end= i*stepsize;
    
    LR_final(:,col_start:col_end)=lin_reta_mat;
    Depol_final(:,col_start:col_end)=depol_mat;
    Diatten_final(:,col_start:col_end)=diattenuation_mat;
    Orient_final(:,col_start:col_end)=orientation1_mat;
    
    clearvars lin_reta_mat depol_mat diattenuation_mat orientation1_mat
end

LR_final=real(LR_final);
Depol_final=real(Depol_final);
Diatten_final=real(Diatten_final);
Orient_final=real(Orient_final);


time_reassemble=toc

if Save == 1   
    tic
    
    save(sprintf('%s%s',filepath,results,sample,'_LR.mat'), 'LR_final');
    save(sprintf('%s%s',filepath,results,sample,'_Depol.mat'), 'Depol_final');
    save(sprintf('%s%s',filepath,results,sample,'_Diatten.mat'), 'Diatten_final');
    save(sprintf('%s%s',filepath,results,sample,'_Orient.mat'), 'Orient_final');
    
    time_save_final=toc
end
    


delete(sprintf('%s%s',filepath,results,sample,'/*.mat'))

figure(1), imagesc(LR_final), axis image;
figure(2), imagesc(Depol_final), axis image;
figure(3), imagesc(Orient_final), axis image;
figure(4), imagesc(Diatten_final), axis image;

time_total=(time_LoadCZI1+time_loadCZI2+time_assemble_blank+time_resize+time_coreg_find+time_coreg1+time_coreg2+time_calculate_Sin+time_calculate_Sout+time_decomp_total+time_reassemble+time_save_final)/60