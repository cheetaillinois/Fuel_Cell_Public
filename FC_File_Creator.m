function FC_File_Creator(fc)
% Creates TECPLOT ready files for use in a Matlab-tecplot interpreter. Also
% an example for how to create any type of file output using FC_calc.m

% Define ranges of values to sweep
    altitude_rng = [-1,1e4,2e4,3e4,3.75e4];
    mach_rng = [0.24,0.4,0.6,0.78];
    power_rng = linspace(210000,1000000,26); %26 points between 210-1000 kw at stack. second number should be 1e6
    fuel_sweep = linspace(0.0001,0.022,101);
    dataout = zeros(5,(length(altitude_rng)*length(mach_rng)*length(power_rng)));
    dataout_heat = dataout;
    counter = 0;
    Pstackmax = 0;
       
    % Iterate through sweeps
    for j = 1:5
        altitude = altitude_rng(j);
        for k = 1:4
            mach = mach_rng(k);
            
            % Create lookup table for power estimation
            Pgross = zeros(101,1);
            for ii = 1:101
                mdot_fuel = fuel_sweep(ii);
                [Pnet(ii),Eff_net(ii),Qdot(ii),Pcompressor(ii),mdot_air(ii),FC_eff(ii),Vcell(ii),Id(ii),Pgross(ii),Pstack] = FC_calc(fc,altitude, mdot_fuel, mach);
                if Pgross(ii) < max(Pgross)
                    Pgross(ii) = max(Pgross)+0.01;
                end
                Pstackmax = max(Pstack,Pstackmax);
            end

            for i = 1:26
                % Define the power we're looking for
                counter = counter+1;
                power_lookingfor = power_rng(i);
                
                % Save data to structure
                dataout(2,counter) = mach;
                dataout(3,counter) = altitude;
                dataout(1,counter) = interp1(Pgross,Pnet,power_lookingfor)/fc.weight; %need to correct for weight
                dataout(4,counter) = interp1(Pgross,Eff_net,power_lookingfor);
                dataout(5,counter) = 1;

                dataout_heat(2,counter) = mach;
                dataout_heat(3,counter) = altitude;
                dataout_heat(1,counter) = interp1(Pgross,Pnet,power_lookingfor)/fc.weight; %need to correct for weight
                dataout_heat(4,counter) = interp1(Pgross,Qdot,power_lookingfor)/fc.weight;
                dataout_heat(5,counter) = 1; 

                % Create Least Power (LP) and Maximum Power (MP) 2D lookup
                % tables for minimum and maximum power, respectively
                if i == 1
                    LP_Wlb_mat(k,j) = dataout(1,counter);
                    LP_Eff_mat(k,j) = dataout(4,counter);
                    LP_Heat_mat(k,j) = dataout_heat(4,counter);
                end
                if i == 26
                    MP_Wlb_mat(k,j) = dataout(1,counter);
                    MP_Eff_mat(k,j) = dataout(4,counter);
                    MP_Heat_mat(k,j) = dataout_heat(4,counter);
                end
            end
        end
    end
    
    
    
    MP_M_rng = mach_rng';

    MP_h_rng = altitude_rng';

    save('fc_values.mat','MP_M_rng','MP_h_rng','LP_Wlb_mat','LP_Eff_mat','MP_Wlb_mat','MP_Eff_mat','LP_Heat_mat','MP_Heat_mat');


    fid = fopen('eff.dat','wt');
    fprintf(fid, 'VARIABLES = "powerdemand", "mach", "altitude", "efficiency", \n');
    fprintf(fid, 'ZONE T = "FCmapR2_Drag", I = 26, J = 4, K = 5 \n');
    fprintf(fid,'%f\t%f\t%i\t%f\t%f\t\n', (dataout));
    fclose(fid);
    
    fid = fopen('HEAT.dat','wt');
    fprintf(fid, 'VARIABLES = "powerdemand", "mach", "altitude", "heat", \n');
    fprintf(fid, 'ZONE T = "FCmapR2_Drag", I = 26, J = 4, K = 5 \n');
    fprintf(fid,'%f\t%f\t%i\t%f\t%f\t\n', (dataout_heat));
    fclose(fid);
end