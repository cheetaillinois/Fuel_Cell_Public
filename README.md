# Fuel-Cell-Public
Publicly available fuel cell model that is used in the CHEETA aircraft.


FC_calc.m:
FC_calc.m calculates the gross and net power of a fuel cell defined in structure FC. An example of implementation is providedin FC_calc_tester.m. The values are as follows:
```
fc.OpT      Operating temperature, C
fc.Ncells   Number of cells, count
fc.A        Area per cell, m^2
fc.r        Resistance per area of cell, ohms/m^2
fc.alpha    Charge transfer coefficient
fc.xpara    Parasitic loss factor
fc.Comp_eff Compressor efficiency
fc.Pfuel    Fuel pressure, bar
fc.mu       Fuel utilization (percentage, max 1.00)
fc.c0       Static coefficient of the compressor pressurization, bar
fc.c1       Linear coefficient of the compressor pressurization, bar/(amp/cm^2)
fc.k        Fuel utilization coefficient
fc.m        Mass transport loss coefficient, volts
fc.n        Mass transport loss coefficient, m^2/amp
```

It outputs the following:
```
Pnet        Net Power, Watts
Eff_net     Net Efficiency
Qdot        Heat, Watts
Pcompressor Compressure pressurization, bar
mdot_air    Mass flow rate of air through compressor, kg/sec
FC_eff      Gross efficiency of fuel cell
Vcell       Individual cell voltage (check?), Volts
Id          Internal current, amps/m^2
Pgross      Gross power, watts
eo          Nernst Voltage, volts
```

FC_calc.m's implementation is demonstrated in lines 1-72 of FC_calc_tester.m, which demonstrates a set of possible fuel cell inputs and an implementation to show cell performance across a range of powers, represented by a range of fuel inputs. The script demonstrates the differences in fuel cell performance between gross power and net power at different altitudes.

The final section is an example of how to create fuel cell files for interpolation. A new fuel cell parameter, weight, is defined and represents the weight for a 1-MW stack. A 1-MW stack is used as a baseline, representative power system. FC_File_Creator calls the fuel cell structure and generates two tables based off the fuel cell characteristics. The tables are in a TecPlot format and enable 3D interpolation using a suitable TecPlot 3D interpretor. (It is also entirely possible to do this via interp3, but for ease of integration to the main CHEETA code this is the system that was used.) By default, this will create a series of power values such that the maximum gross power of the stack is 1 MW and calculate the power at 5 heights of [0, 10,000, 20,000, 30,000, 37,500] feet and Mach speeds of [0.24,0.4,0.6,0.78]. The matricies LP and MP represent the Least Power and Most Power available throughout the flight and enable fast lookup of minimum and maximum power for descent and climb, respectively. 

The output files contain altitude, Mach, and Power, discretized to weight. This allows an aircraft sizing code to be run and to calculate a fuel cell size equal to the exact power it needs. For example, if the peak power point of sizing is at top of climb and requires 20 MW, and the peak power of a fuel cell is 1,000 W/lb, it would require 20,000 lb. of fuel cell to achieve the 20 MW of power. 

To find the fuel consumption at cruise, efficiency is provided as a lookup table of [altitude, speed, power]. Looking up on these will provide an efficiency, eta, which can be used to find the chemical energy flow rate by having (power required)/eta, and then multiplying that by the energy density of LH2 to find the fuel flow rate per second. Similarly, the heat output is measured in watts/pound of fuel cell. To find the heat output, lookup on the table of [altitude, speed, power] to find the heat/lb, and multiply it by the weight of the fuel cell to find the heat generated on board.
