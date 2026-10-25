function [total_dP, phase_state, T_out] = FUNCTION_capillary_sizing_MF_dP(L_total, D_c_in, T_inlet, P_inlet, mass_flows)
% FUNCTION_capillary_sizing_MF_dP
% Calculates total pressure drop, phase state, and outlet temperature
% for a range of mass flow rates through a capillary
%
% INPUTS:
%   L_total     - Capillary length [m]
%   D_c_in      - Inner diameter [mm]
%   T_inlet     - Inlet temperature [°C]
%   P_inlet     - Inlet pressure [bar]
%   mass_flows  - Array of mass flow rates [g/s]
%
% OUTPUTS:
%   total_dP    - Total pressure drop across capillary [bar]
%   phase_state - Flow regime ('1φ' or '2φ') for each mass flow
%   T_out       - Outlet temperature [°C] for each mass flow

    fld = 'CO2';
    Ep_Ti = 1.1e-6; % [m]

    section_length = 1.5e-2; % [m]
    num_sections = ceil(L_total / section_length);

    total_dP = zeros(length(mass_flows), 1);
    T_out = zeros(length(mass_flows), 1);
    phase_state = strings(length(mass_flows), 1);

    % Loop over mass flow rates
    for mf_iter = 1:length(mass_flows)
        m_dot = mass_flows(mf_iter); % [g/s]
        A_cap = pi * ((D_c_in * 1e-3)^2) / 4;
        MFLX = (m_dot * 1e-3) / A_cap; % [kg/m²s]

        % Known inlet conditions
        H = refpropm('H', 'T', T_inlet + 273.15, 'P', P_inlet * 1e2, fld); % [J/kg]

        P_inlet_section(1) = P_inlet;
        dP = zeros(1, num_sections);
        x = zeros(1, num_sections);

        % Loop through segments
        for i = 1:num_sections
            [T(i), ~, x(i)] = refpropm('TDQ', 'P', P_inlet_section(i) * 1e2, 'H', H, fld);

            if x(i) < 0 || x(i) > 1
                [dP_temp, ~, ~] = DarcyWeisbach(fld, P_inlet_section(i), H, MFLX, D_c_in * 1e-3, A_cap, Ep_Ti);
            else
                [dP_temp, ~] = FriedelCorrelation(fld, P_inlet_section(i), x(i), MFLX, D_c_in * 1e-3, A_cap);
            end

            dP(i) = dP_temp * section_length;

            if i < num_sections
                P_inlet_section(i + 1) = P_inlet_section(i) - dP(i);
            end
        end

        dP_tot = sum(dP);
        total_dP(mf_iter) = dP_tot;

        % Outlet pressure and temperature
        P_outlet = P_inlet - dP_tot;
        T_out(mf_iter) = refpropm('T', 'P', P_outlet * 1e2, 'H', H, fld) - 273.15;

        % Determine flow regime
        if any(x > 0 & x < 1)
            phase_state(mf_iter) = "2\phi";
        else
            phase_state(mf_iter) = "1\phi";
        end
    end
end
