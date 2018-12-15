function mF = Fuel_Composition( Wg, Wf )

Mgair=28*79/100+32*21/100; 
MOL_air=Wg*1000/Mgair; 

L0=Wf*1000*0.595238;

MOL_air_rest = MOL_air-L0 ;
MOL_N2_rest = MOL_air_rest*0.79; 
MOL_O2_rest = MOL_air_rest*0.21; 

MOL_mix = 0.87*Wf*1000/12+0.126*Wf*1000/2+0.79*L0;
MOL_mix_CO2 = MOL_mix*0.0725/(0.0725+0.063+0.3907);
MOL_mix_H2O = MOL_mix*0.063/(0.0725+0.063+0.3907);
MOL_mix_N2 = MOL_mix*0.3907/(0.0725+0.063+0.3907);

MOL_gas_CO2 = MOL_mix_CO2;
MOL_gas_H2O =MOL_mix_H2O;
MOL_gas_O2 = MOL_O2_rest;
MOL_gas_N2 = MOL_N2_rest+MOL_mix_N2;

mF = zeros( 1, 4 );
Mg=MOL_gas_CO2*44+MOL_gas_H2O*18+MOL_gas_O2*32+MOL_gas_N2*28; 
mF(1) = MOL_gas_N2*28/Mg;
mF(2) = MOL_gas_O2*32/Mg;
mF(3) = MOL_gas_CO2*44/Mg;
mF(4) = MOL_gas_H2O*18/Mg;

end