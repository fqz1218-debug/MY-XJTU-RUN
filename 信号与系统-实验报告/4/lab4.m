clear
clc
clf
close all;

R_Source=50;
R=1000;                   %电阻
L=0.33*10^-3;             %电感
C=0.68*10^-6;             %电容
Wn=1/sqrt(L*C);           %固有角频率
fn=Wn/(2*pi);             %固有频率
zeta1=(R/2)*sqrt(C/L);    %C 阻尼比
zeta2=(R/2)*sqrt(C/L);    %R 阻尼比
zeta3=(1/(2*R))*sqrt(L/C);%RL阻尼比


%理想
H_2_standard_1 = @(f) 1./( (1i*f/fn).^2 + 2*zeta1*1i*f/fn + 1 );
H_2_standard_2 = @(f) (2*zeta2*1i*f/fn)./( (1i*f/fn).^2 + 2*zeta2*1i*f/fn + 1 );
H_2_standard_3 = @(f) ((1i*f/fn).^2)./( (1i*f/fn).^2 + 2*zeta3*1i*f/fn + 1 );
f_Ideal_fn = [0.01:0.01:0.09  0.1:0.1:0.9  1:9  10:10:100]; %归一化频率
f_Ideal=f_Ideal_fn*fn;                                      %理想的实际频率
H_Ideal_1=20*log10(abs(H_2_standard_1(f_Ideal)));
H_Ideal_2=20*log10(abs(H_2_standard_2(f_Ideal)));
H_Ideal_3=20*log10(abs(H_2_standard_3(f_Ideal)));



%测量
f_Real_fn=[0.02,0.05,0.08 0.1:0.1:0.9 1:9 10,20,50];    %归一化频率
f_Real=f_Real_fn*fn;                                    %需要设置的信号源的实际频率


V_Source_Cap=[4.98	4.85	4.84	4.85	4.83	4.83	4.84	4.84	4.84	4.82	4.82	4.82	4.82	4.84	4.84	4.84	4.83	4.84	4.84	4.84	4.85	4.85	4.84	4.84];
V_Cap       =[3.7	2.03	1.32	1.07	0.55	0.37	0.27	0.22	0.18	0.156	0.137	0.122	0.11	0.0572	0.0379	0.0271	0.0233	0.017	0.015	0.0148	0.013	0.012	0.00523	0.00207];
V_Source_Res=V_Source_Cap;
V_Res       =[3.52	4.5	4.71	4.75	4.81	4.8	4.8	4.8	4.81	4.81	4.81	4.82	4.82	4.83	4.83	4.82	4.82	4.81	4.79	4.77	4.76	4.79	4.51	3.56];
V_Source_RL =[5.05	5.03	4.97	4.93	4.55	4.02	3.39	2.77	2.2	1.66	1.16	0.758	0.492	2.37	3.39	3.91	4.2	4.38	4.5	4.58	4.63	4.69	4.8	4.82];
V_RL        =[0.012	0.025	0.042	0.052	0.203	0.418	0.636	0.931	1.17	1.29	1.56	1.76	1.95	3.25	3.89	4.12	4.41	4.52	4.61	4.66	4.69	4.74	4.81	4.83];

%{
V_Cap_Ideal=abs((1/C)./(1/C+1i*2*pi*f_Real*R-(2*pi*f_Real).^2*L));
V_Cap_Ideal=V_Cap_Ideal.*V_Source_Cap;
V_Res_Ideal=abs((1i*2*pi*f_Real*R)./(1/C+1i*2*pi*f_Real*R-(2*pi*f_Real).^2*L));
V_Res_Ideal=V_Res_Ideal.*V_Source_Res;
V_RL_Ideal =(1i*2*pi*f_Real*L*R./(1i*2*pi*f_Real*L+R))./((1i*2*pi*f_Real*L*R./(1i*2*pi*f_Real*L+R))+1./(1i*2*pi*f_Real*C));
V_RL_Ideal =abs(V_RL_Ideal);
V_RL_Ideal =V_RL_Ideal.*V_Source_RL ;

%}
V_RL_Ideal_Source=(1i*2*pi*f_Real*L*R./(1i*2*pi*f_Real*L+R))./((1i*2*pi*f_Real*L*R./(1i*2*pi*f_Real*L+R))+1./(1i*2*pi*f_Real*C)+R_Source);


H_Real_1=20*log10( abs( V_Cap./V_Source_Cap ) );
H_Real_2=20*log10( abs( V_Res./V_Source_Res ) );
H_Real_3=20*log10( abs( V_RL ./V_Source_RL  ) );

%{
H_Real_1=20*log10( abs( V_Cap_Ideal/5 ) );
H_Real_2=20*log10( abs( V_Res_Ideal/5 ) );
H_Real_3=20*log10( abs( V_RL_Ideal /5 ) );
%}
H_Real_3_Source=20*log10( abs( V_RL_Ideal_Source  ) );


%绘图
figure('name','二阶系统1的频率响应');
semilogx(f_Ideal_fn,H_Ideal_1,f_Real_fn,H_Real_1);
ylabel("20lg|H|");
xlabel("f/fn");
grid on;
legend('理论','测量');
figure('name','二阶系统1的零极点图');
zplane(1,[1,2*zeta1,1]);
grid on;

figure('name','二阶系统2的频率响应');
semilogx(f_Ideal_fn,H_Ideal_2,f_Real_fn,H_Real_2);
ylabel("20lg|H|");
xlabel("f/fn");
grid on;
legend('理论','测量');
figure('name','二阶系统2的零极点图');
zplane([0,2*zeta2,0],[1,2*zeta2,1]);
grid on;

figure('name','二阶系统3的频率响应');
semilogx(f_Ideal_fn,H_Ideal_3,f_Real_fn,H_Real_3,f_Real_fn,H_Real_3_Source);
ylabel("20lg|H|");
xlabel("f/fn");
grid on;
legend('理论','测量','考虑内阻的测量');
figure('name','二阶系统3的零极点图');
zplane([1,0,0],[1,2*zeta3,1]);
grid on;


%(1i*1000*66.756*0.33)/(1000+1i*66.756*0.33)
%(1i*1000*66.756*0.33)/(1000+1i*66.756*0.33)+1/(1i*66.756*0.68*0.001)+R_Source