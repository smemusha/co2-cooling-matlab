a1 = 'http://webbook.nist.gov/cgi/fluid.cgi?Action=Data&Wide=on&ID=C124389&Type=IsoBar&Digits=';
a2 = '&P=';
a3 = '&THigh=';
a4 = '&TLow=';
a5 = '&TInc=';
a6 = '&RefState=DEF&TUnit=K&PUnit=bar&DUnit=mol%2Fl&HUnit=kJ%2Fkg&WUnit=m%2Fs&VisUnit=Pa*s&STUnit=N%2Fm';

DIGITS = 12;
TMIN = 250;
TMAX = 1100;
TInc = 1;

for P = 1 : 8000
    for i = 1 : ceil((TMAX - TMIN)/200)
        TLow = TMIN + (i - 1) * 200;
        if i < ceil((TMAX - TMIN)/200)
            THigh = TLow + 199;
        else
            THigh = TMAX;
        end
        page = strcat(a1, int2str(DIGITS), a2, num2str(P), a3, num2str(THigh), a4, num2str(TLow), a5, num2str(TInc), a6);
        fileName = strcat('CO2 - ISOBARIC - P = ', num2str(P), 'bar T = ', num2str(TLow), ' - ', num2str(THigh), ' K.txt');
        fid = fopen(fileName, 'wt');
        fprintf(fid, '%s\n', urlread(page));
        fclose(fid);
    end
end