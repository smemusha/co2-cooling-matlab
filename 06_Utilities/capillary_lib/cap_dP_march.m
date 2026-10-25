function r = cap_dP_march(fld, D_mm, m_gs, T_in_C, P_in_bar, eps_m, L_m, dL_m, dP_target)
% CAP_DP_MARCH  Pressure drop along a capillary, section by section (REFPROP + CoBra).
%   Single phase (x <= 0 or x >= 1): DarcyWeisbach, two phase: FriedelCorrelation.
%   Both return a gradient [bar/m], multiplied by the section length dL_m.
%   The enthalpy stays at the inlet value (adiabatic capillary).
%
%   r = cap_dP_march(fld, D_mm, m_gs, T_in_C, P_in_bar, eps_m, L_m, dL_m)
%       fixed length L_m [m]
%   r = cap_dP_march(fld, D_mm, m_gs, T_in_C, P_in_bar, eps_m, [], dL_m, dP_target)
%       march until dP_target [bar] is reached; the last section is
%       interpolated to give the required length r.L_req [m]
%
%   r fields: L [m] (section ends), P [bar] (section inlets + outlet),
%   dP_sec [bar], x [-], T [K], dP_tot [bar], P_out [bar], T_out_C [°C],
%   two_phase (any section two-phase), L_req [m] (target mode only)

    if nargin < 9, dP_target = []; end
    H = refpropm('H', 'T', T_in_C + 273.15, 'P', P_in_bar*1e2, fld);   % J/kg
    D = D_mm*1e-3;                       % m
    A = pi*D^2/4;                        % m^2
    G = (m_gs*1e-3)/A;                   % kg/m^2/s

    if isempty(dP_target)
        n = ceil(L_m/dL_m);
    else
        n = 20000;                       % safety limit
    end
    x = zeros(1,n); T = zeros(1,n); grad = zeros(1,n); dP_sec = zeros(1,n);
    P = zeros(1,n+1); P(1) = P_in_bar;
    cum = 0; i = 0;
    while i < n && (isempty(dP_target) || cum < dP_target)
        i = i + 1;
        [T(i), ~, x(i)] = refpropm('TDQ', 'P', P(i)*1e2, 'H', H, fld);
        if x(i) <= 0 || x(i) >= 1
            [grad(i), ~, ~] = DarcyWeisbach(fld, P(i), H, G, D, A, eps_m);   % bar/m
        else
            [grad(i), ~] = FriedelCorrelation(fld, P(i), x(i), G, D, A);     % bar/m
        end
        dP_sec(i) = grad(i)*dL_m;
        cum = cum + dP_sec(i);
        P(i+1) = P(i) - dP_sec(i);
    end
    x = x(1:i); T = T(1:i); dP_sec = dP_sec(1:i); P = P(1:i+1);
    r.L = dL_m*(1:i);
    r.x = x; r.T = T; r.dP_sec = dP_sec;
    r.two_phase = any(x > 0 & x < 1);

    if ~isempty(dP_target) && cum > dP_target && grad(i) > 0
        % interpolate inside the last section
        dP_needed = dP_target - sum(dP_sec(1:i-1));
        r.L_req = dL_m*(i-1) + dP_needed/grad(i);
        P(i+1) = P(i) - dP_needed;
        dP_sec(i) = dP_needed;
        r.L(i) = r.L_req; r.dP_sec = dP_sec;
    elseif ~isempty(dP_target)
        r.L_req = r.L(end);
    end
    r.P = P;
    r.dP_tot = sum(r.dP_sec);
    r.P_out = P(end);
    r.T_out_C = refpropm('T', 'P', r.P_out*1e2, 'H', H, fld) - 273.15;
end
