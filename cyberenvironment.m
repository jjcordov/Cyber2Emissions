%Application of a Framework to determine emission leaded by change in
%generation mix due to FDI cyberattack

clc
clear all
%General data
%Emission factors per generator
emi_fac=[0.9976; 0.9976; 0.0100; 0.0142; 0.9976; 0.0142]; 
mpc=case30; %IEEE 30 buses Test System

%Modify the generation costs with RE cost for G3, G4 and G6
mpc.gencost=[2.0000	0	0	3.0000	0.0200	30.0000	0;
             2.0000	0	0	3.0000	0.0250	30.0000	0;
             2.0000	0	0	3.0000	0.0010	02.0000	0;
             2.0000	0	0	3.0000	0.0010	02.0000	0;
             2.0000	0	0	3.0000	0.0300	30.0000	0;
             2.0000	0	0	3.0000	0.0020	04.0000	0];

%Modify Maximum Pmax to allow more generation from every source and maximum
%generation from RE

mpc.gen(:,9)=[120; 120; 30; 30; 120; 50];

%Load and run Baseline case
baslin_results=rundcopf(mpc); %DC-OPF
baslin_gen_out=baslin_results.gen(:,2);
baslin_emi=emi_fac.*baslin_gen_out;

%Scenario 1 - FDI 30% increase load in buses 7, 12, 15, 17, 21
mpc_s1=mpc;
mpc_s1.bus(7,3)=mpc.bus(7,3)*1.3;
mpc_s1.bus(12,3)=mpc.bus(12,3)*1.3;
mpc_s1.bus(15,3)=mpc.bus(15,3)*1.3;
mpc_s1.bus(17,3)=mpc.bus(17,3)*1.3;
mpc_s1.bus(21,3)=mpc.bus(21,3)*1.3;
%limit the generation on RE sources
mpc_s1.gen(6,9)=50; %Wind
mpc_s1.gen(3,9)=30; %Solar
mpc_s1.gen(4,9)=30; %Solar

sce1_results=rundcopf(mpc_s1); %DC-OPF
sc1_gen_out=sce1_results.gen(:,2);
sc1_emi=emi_fac.*sc1_gen_out;

%Scenario 2 Wind Curtailment
mpc_s2=mpc;
%limit the generation on RE sources and Wind curtailment
mpc_s2.gen(6,9)=05; %Wind
mpc_s2.gen(3,9)=30; %Solar
mpc_s2.gen(4,9)=30; %Solar

sce2_results=rundcopf(mpc_s2); %DC-OPF
sc2_gen_out=sce2_results.gen(:,2);
sc2_emi=emi_fac.*sc2_gen_out;

results(:,1)=baslin_gen_out;
results(:,2)=baslin_emi;
results(:,3)=sc1_gen_out;
results(:,4)=sc1_emi;
results(:,5)=sc2_gen_out;
results(:,6)=sc2_emi;
%Reorder generator according to number name
results([1 2 3 4 5 6],:)=results([1 2 6 3 5 4],:);
res_tab=array2table(results,"VariableNames",{'BL_Pout','BL_Emi','S1_Pout','S1_Emi','S2_Pout','S2_Emi'},"RowNames",{'G1_Th','G2_Th','G3_Wind','G4_Sol','G5_Th','G6_Sol'})

bars(1,:)=results(:,1);
bars(2,:)=results(:,3);
bars(3,:)=results(:,5);
b=bar(bars,'stacked');
xticklabels({'Base Line','30% Inc Load','Curt 90% Wind'});
xlabel('Scenarios')
ylabel('Generation [MWh]')
b(1).FaceColor = [0.00 0.45 0.74]; % G1 Thermal
b(2).FaceColor = [0.85 0.33 0.10]; % G2 Thermal
b(3).FaceColor = [0.00 0.39 0.00]; % G3 Wind
b(4).FaceColor = [0.00 0.45 0.74]; % G4 Solar
b(5).FaceColor = [0.64 0.08 0.58]; % G5 Thermal
b(6).FaceColor = [0.47 0.67 0.19]; % G6 Solar
legend({'G1-Ther','G2-Ther','G3-Wind','G4-Solar','G5-Ther','G6-Solar'});
grid on

%Determine Emision Factor (EF)
EF(1)=(sum(res_tab.BL_Emi)/sum(res_tab.BL_Pout));
EF(2)=(sum(res_tab.S1_Emi)/sum(res_tab.S1_Pout));
EF(3)=(sum(res_tab.S2_Emi)/sum(res_tab.S2_Pout));
EF_tab=array2table(EF',"VariableNames",{'Emission Factors'},"RowNames",{'Scenario 1 BL','Scenario 2 Inc Load','Scenario 3 10%Wind'})

%Determine increase in EF
Inc(1)=((EF(2)/EF(1))-1)*100;
Inc(2)=((EF(3)/EF(1))-1)*100;

res_tab=array2table(results,"VariableNames",{'BL_Pout','BL_Emi','S1_Pout','S1_Emi','S2_Pout','S2_Emi'},"RowNames",{'G1_Th','G2_Th','G4_Sol','G6_Sol','G5_Th','G3_Wind'})
