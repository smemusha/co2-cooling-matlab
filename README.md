# My Scripts – CO₂ cooling analysis (MATLAB)

MATLAB scripts for the ATLAS ITk Pixel Outer Barrel CO₂ cooling work: capillary
testing in B180, evaporator/longeron studies and supporting thermofluid
calculations. Needs REFPROP (`refpropm`) and the CoBra functions.

## Folders

| Folder | Contents |
|---|---|
| `01_Capillaries` | `EXP_*` = analysis of measured SCADA data, `TH_*` = REFPROP models |
| `02_Evaporators_Longerons` | Evaporator HTC/dP, dry-out and block thermal tests |
| `03_Pipes_Vessels_HeatTransfer` | Bend dP, pipe/vessel dP, helix heat exchanger, heat leak |
| `04_Cycles_Turbine` | Axial turbine, Brayton and transcritical CO₂ cycles |
| `05_NRV` | Non-return valve test results |
| `06_Utilities` | `capillary_lib` (shared functions), `cprintf`, `NISTreader`, `gohome` |

## Capillary test reports (`01_Capillaries`)

| Script | Output |
|---|---|
| `EXP_dP_vs_flow_REPORT` | dP vs mass flow per capillary, fit through origin, Excel report |
| `EXP_final_length_REPORT` | Final length for the target dP at the target flow |
| `EXP_expected_dP_REPORT` | Expected dP at the current (cut) length |

Each report script takes **one input**, `campaignFolder`, containing:

- the SCADA csv exports (found automatically by their header),
- the `*Timestamps*.xlsx` files (stable windows and capillary IDs),
- `lengths.xlsx` with columns `Capillary | Test length (mm) | Current length (mm)`.

The Excel report is written to the same folder.

## Model scripts

`TH_dP_ID_scan`, `TH_dP_vs_length`, `TH_length_for_dP` and `TH_dP_vs_flow` all
use `06_Utilities/capillary_lib/cap_dP_march.m` (Darcy–Weisbach single phase,
Friedel two phase, constant enthalpy).

## Setup

`startup.m` adds REFPROP, CoBra Scripts and this folder (without `_Archive`) to
the MATLAB path when MATLAB starts.

`_Archive` folders keep superseded versions for reference.

Author: Sara Memushaj. Shared for academic and non-commercial use.
