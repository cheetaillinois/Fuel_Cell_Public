# Fuel-Cell-Public
Publicly available fuel cell model that is used in the CHEETA aircraft.


FC_calc.m:
FC_calc.m calculates the gross and net power of a fuel cell defined in structure FC. An example of implementation is providedin FC_calc_tester.m. The values are as follows:
```
fc.OpT      Operating Temperature
fc.Ncells   Number of Cells
fc.A        Area per Cell
fc.r        Resistance per area of cell
fc.alpha    ???
fc.xpara    Parasitic loss factor
fc.Comp_eff Compressor Efficiency
fc.Pfuel    Fuel Pressure
fc.mu       Fuel utilization (percentage, max 1.00)
fc.c0       Static coefficient of the compressor pressurization
fc.c1       Linear coefficient of the compressor pressurization
fc.k        ???
fc.m        V-trans?
fc.n        V-trans?
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

