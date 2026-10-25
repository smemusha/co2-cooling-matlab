% Brayton cycle interactive demo plot all 4 stages of ideal brayton cycle 
% on T-s diagram and computes its thermal efficiency and mechanical power 
% from turbine inlet pressure (kPa), temperature (K), mass flow rate (kg/s), 
% and turbine outlet pressure (kPa) and temperature (K).  
%
% Written by Rodney Tan (PhD)
% Version 1.00 (Jan 2023)
function BraytonCycleInteractiveDemo

    figure('Resize','off','NumberTitle','off','Name',...
           'Brayton Cycle Interactive Demo');
       
    uicontrol('Style', 'text', 'String', 'Gas Turbine','backgroundcolor','w',...
              'Position', [80 360 100 20],'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Pressure (kPa)','backgroundcolor','w',...
              'Position', [80 340 100 20],'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Temperature (K)','backgroundcolor','w',...
              'Position', [80 320 100 20],'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Mass Flow (kg/s)','backgroundcolor','w',...
              'Position', [80 300 100 20],'horizontalAlignment', 'left');
    
    uicontrol('Style', 'text', 'String', 'Inlet','backgroundcolor','w',...
              'Position', [190 360 50 20],'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Outlet','backgroundcolor','w',...
              'Position', [235 360 50 20],'horizontalAlignment', 'left');

    uicontrol('Style', 'text', 'String', 'Efficient (%) =','backgroundcolor','w',...
              'Position', [80 260 100 20],'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Power (kW) =','backgroundcolor','w',...
              'Position', [80 240 100 20],'horizontalAlignment', 'left');

    hP1=uicontrol('Style', 'edit', 'String','100',...
                   'Position', [180 340 40 20],'Callback',@BraytonCycle);
    hP2=uicontrol('Style', 'edit', 'String','360',...
                   'Position', [230 340 40 20],'Callback',@BraytonCycle);
    hT1=uicontrol('Style', 'edit', 'String','300',...
                   'Position', [180 320 40 20],'Callback',@BraytonCycle);
    hT3=uicontrol('Style','edit', 'String','800',...
                   'Position', [230 320 40 20],'Callback',@BraytonCycle);
    hmdot=uicontrol('Style', 'edit', 'String','1000',...
                   'Position', [180 300 40 20],'Callback',@BraytonCycle); 
    
    hEff=uicontrol('Style','text', 'String','0','backgroundcolor','w',...
                   'Position', [150 260 40 20]);
    hPm=uicontrol('Style','text','String','0','backgroundcolor','w',...
                  'Position',[150 240 40 20]);
    
    BraytonCycle;
    
    
    function BraytonCycle(~,~)
        cla;
        P1 = str2double(get(hP1,'String'));
        P2 = str2double(get(hP2,'String'));
        T1 = str2double(get(hT1,'String'));
        T3 = str2double(get(hT3,'String'));
        mdot = str2double(get(hmdot,'String'));
        
        Cp = 1.005;     % Constant pressure Specific Heat in kJ/Kg K
        Cv = 0.717;     % constant Volume specific heat in kJ/kg K
        gamma = Cp/Cv;  % ratio of Specific heat
        T0 = 200 ;      % The reference temperature for entropy
        P0 = 100 ;      % The reference pressure for entropy
        
        % State 1 Compressor isentropic compression
        T2 = T1*((P2/P1)^((gamma-1)/gamma));
        Wcomp = Cp*(T2-T1);         % Work in compressor
        s1 = (Cp*log(T1/T0))-(((gamma-1)/gamma)*(log(P1/P0)));

        % State 2 Combustion chamber constant prsssure heat addition
        s2 = s1;
        Qin = Cp*(T3-T2);           % Heat to Combustion chamber
        P3 = P2;
        T23 = linspace(T2,T3,10);   % range of temperature
        P23 = linspace (P2, P3, 10);% range of pressure
        s23 = s1+(Cp.*log(T23./T2))-(((gamma-1)/gamma).*(log(P23./P2)));
        
        % State 3 Turbine inlet isentropic expansion
        P3 = P2;
        P4 = P1;
        T4 = T3*((P4/P3)^((gamma-1)/gamma));
        Wturbine = Cp*(T3-T4);      % Work out from turbine
        s3  = (Cp*log( T3/T0))-(((gamma-1)/gamma)*(log(P3/P0)));

        % State 4 Exhaust constant pressure heat rejection
        s4 = s3;
        T41 = linspace(T4,T1,10);   % range of temperature
        P41 = linspace (P4,P1,10);  % range of pressure
        s41 = s3+(Cp.*log( T41./T4))-(((gamma-1)/gamma).*(log(P41./P4))); 
        % Qout = Cp*(T4-T1);

        Eff = ((Wturbine-Wcomp)/Qin)*100;   % thermal efficiency
        Pm = (Wturbine-Wcomp)*mdot;         % Turbine Mechanical power output
        set(hEff,'String',num2str(Eff,'%.1f'));
        set(hPm,'String',num2str(Pm,'%.0f'));
        
        % Plot T-s diagram 1-2 State line
        plot([s1 s2],[T1 T2],'y','LineWidth',3);
        % Plot T-s diagram 2-3 State line
        hold on;
        plot(s23,T23,'r','LineWidth',3);
        % Plot T-s diagram 3-4 State line
        plot([s3 s4],[T3 T4],'y','LineWidth',3);
        % Plot T-s diagram 4-1 State line
        plot(s41,T41,'b','LineWidth',3);
        % Label State number
        text(s1,T1-10,' 1');
        text(s2,T2+30,' 2');
        text(s3,T3,' 3');
        text(s4,T4-10,' 4');
        title('T-s Diagram');
        xlim([s1-0.1 s4+0.1]);
        ylim([273 T3+100]);
        xlabel('Entropy (kJ/kg K)');
        ylabel('Temperature (K)');
    end
end