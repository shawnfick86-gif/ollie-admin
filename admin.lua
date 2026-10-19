
-- ============================================
-- OLLIE ADMIN  �  KEY SYSTEM + PANEL
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local isPremium = false

-- ============================================
-- YOUR GENERATED KEYS
-- ============================================
local VALID_KEYS = {
    ["OLLIE-RSIBT-X8PQB"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-3G9P4-E1B7R"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-JZHC3-J9LKY"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-F9T0S-7VPGV"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-IX4U4-KXUPG"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-RLK5F-ZTR6O"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-P5DVH-1Q56O"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-TTVX6-V2LZX"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-UKJ5N-O1X2S"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-J5TE5-EU9ZY"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-5BZ09-EUKA7"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-896YE-1GS4E"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-CTS1M-5E64W"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-272MI-L6X9D"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-FUEEX-TO2PL"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-JBBH8-BBFB9"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-1L795-N2URC"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-MPMX9-HJKJ9"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-Q73AB-9833I"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-ZW8X0-1JJMY"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-40S1P-CHNOK"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-7YCXM-F8HOJ"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-HDDFC-CR4EY"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-VLAGG-8MRQ4"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-MUL0T-6KKYB"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-GDU6T-UNK78"] = { tier = "1day", expires = 1792453829 },
    ["OLLIE-YGLL3-P4HED"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-QABVR-ANS18"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-L8PNX-VYOI5"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-RBPE2-PDBXX"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-7HEKF-YT4LZ"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-NBOQQ-ILOJS"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-W0KL1-MU7O8"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-MQP1D-DFFEP"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-4YRKL-2ER38"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-IQO2K-9OUFT"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-DNKVD-ZEV5N"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-DSL9S-EYATV"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-LMZ0Z-KU468"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-UDMI0-N4YZ8"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-LCNBF-BYQXJ"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-958EW-L6G9I"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-0M86R-UN1U4"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-WVN2F-9D82F"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-DC8U2-0856E"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-SD7HQ-C6FYO"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-IRT1Z-XVG88"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-PYLCB-QFSZD"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-DXBLD-9SCCB"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-Z6DBI-ME7K2"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-FRRZU-H0IGU"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-JUTKI-P9ZPA"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-MQ9GC-ZWNHU"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-QYJJI-ZEDBR"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-O2VDG-70H67"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-X22OX-Y8XAM"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-MZT0S-3V8M2"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-CGS08-12HH2"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-FEVA5-1N903"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-PDVKV-FJU6X"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-FSCE8-L0DO0"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-YQ9UV-7T9KC"] = { tier = "1day", expires = 1792453830 },
    ["OLLIE-6J33U-N4D7I"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-BFU2R-SRM4Y"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-FI6M5-K6106"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-83M24-VX4SX"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-2OSWZ-6SRD8"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-E37KF-WUZ88"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-56OW3-CLJUJ"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-MM9CI-8AWDH"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-8HBL3-AE4MG"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-5KG6S-1PKBZ"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-0KMFD-ZEFKF"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-66S2N-A0EI4"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-HFMUC-TZFYT"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-0LGH7-28LD3"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-C01P9-XP5RH"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-UJ1QC-8US8Z"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-JHGDY-157BH"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-YTSLM-2PEHT"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-Z23PJ-G3D1C"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-Y9KK8-5PIAY"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-Q13OW-41DFO"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-F593X-EMZ6R"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-1MOY4-OVIIX"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-UOAVC-21652"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-Y2USB-RKMLS"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-M1TQ4-EWNLV"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-3LJXV-GSNGF"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-WXIHU-5ASN5"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-HMPR1-6G77T"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-C8JBD-2R5UN"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-HL4KO-FEYIZ"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-CCO2E-OAGPJ"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-B9HLA-M5PJN"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-MMZNM-LIHJX"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-YK8CR-C9885"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-B62VZ-5RHJL"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-FT941-6KLKT"] = { tier = "1day", expires = 1792453831 },
    ["OLLIE-TFBFK-BTXKY"] = { tier = "1day", expires = 1792453832 },
    ["OLLIE-456V7-W70X8"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-QYMB1-Q692H"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-3YBO9-VTM8N"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-31BBU-EBZYO"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-1EBQM-HYWPT"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-CUBVJ-85QWY"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-IFVII-M1I01"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-078JH-5BSJO"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-4HX90-2RWDJ"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-705UC-Y5R38"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-9Q9GM-ZM8MN"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-3XNLV-QCFGN"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-9BA0Z-YUP1F"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-TWDDQ-C4KM5"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-C3O1G-XKQEU"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-MYDB1-PLIQ0"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-TZVX4-M47D5"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-VYS01-HCXP7"] = { tier = "7day", expires = 1792972590 },
    ["OLLIE-KILE7-DGNZJ"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-3ZU6R-56ITC"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-SJR15-F139E"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-1C03T-J3EU1"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-CNG06-H11HQ"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-D2336-SX722"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-SVODI-983S6"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-YKI3R-DTZ6A"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-3GTEB-M1N3B"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-5ONR9-N7S7D"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-EBHCC-1H035"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-9A2UG-ZOZUJ"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-YQK8F-S466G"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-1WVRA-AC6G0"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-J55KX-5NGZG"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-Z0J37-3E6XY"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-HFTWP-52C15"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-HX5GM-FJKDW"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-ZDP32-4WPMK"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-VYHXL-L500V"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-UMYOB-A45OG"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-P953I-9DY2N"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-CHOEN-UER48"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-WWUW1-G4SU7"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-Z1V7L-HC30E"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-SXZ68-X2K8O"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-V12MQ-7L0KC"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-IZI67-OY24F"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-VXCTK-GIYMK"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-UC9C2-NOTO6"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-26MAB-D5DTX"] = { tier = "7day", expires = 1792972591 },
    ["OLLIE-CV6PG-YNDBM"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-NMHAA-FF6SA"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-CAVKK-6YNM6"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-CROUI-A34C0"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-7LJF5-JD55K"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-CEE6S-EXS6U"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-741N1-U9L0K"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-CTVUF-TCJP1"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-PHSXJ-CD8J6"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-6H6X0-YQKFI"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-AEZHC-88KIY"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-JUDR0-LEEQM"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-OYSO4-C3JLL"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-AGY8N-OXUYI"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-GC6G8-X9Z2Q"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-54S9Q-P104O"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-54HTD-FFEF1"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-UUGBL-40ZUR"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-4URH2-ZDHZ3"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-625LA-KZJ1K"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-KTQAU-ZRXGV"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-EO5QR-MEO47"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-XH7XJ-IKWJ6"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-I5XUX-39LQE"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-RUQCX-4RZL2"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-N1MHY-9R3U0"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-V6LTG-KUSBR"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-RC81B-G19VU"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-NBOYE-I2EOY"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-R8FGR-8C0MG"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-SREL1-IEJ00"] = { tier = "7day", expires = 1792972592 },
    ["OLLIE-R1F1Q-E2IDZ"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-Z40N0-C6G5I"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-NQH2F-4EJEV"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-BDAGO-TTE2L"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-BDOJW-QE069"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-LWXLU-UVB0V"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-9JWI4-KQM22"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-XRVQN-LX5FK"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-8M5OT-PY7EL"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-KXCJQ-DGBD0"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-3PM1Z-NR2D4"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-LVGYN-J4C14"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-MKDVN-KGYUO"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-O806C-DP2M2"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-6K5EE-TT47J"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-NUP53-YFU1F"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-HNAE1-NRDZH"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-93QDI-BOKG3"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-S0QN4-TL0GV"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-3Z2P9-I3YSL"] = { tier = "7day", expires = 1792972593 },
    ["OLLIE-7LYLH-9HWCI"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-SQ5MK-GI9KH"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-33430-5OQXU"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-NM881-3IFNI"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-ODWD7-ZB4ZW"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-5KL3A-KJMPN"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-9JT0S-FMG6U"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-X009R-WHV2C"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-MDRLF-TXHR3"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-85WUC-R25SL"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-9YQC9-JQ7FU"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-FVVRE-CQN57"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-D5FUQ-WO2XW"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-G0SKA-FH5KX"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-MCRG9-6S3KO"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-X2DEQ-SPQ6D"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-L1HL8-Q4WDV"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-9TEXY-0PJXA"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-S19A1-MIJ64"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-0V739-0JZRS"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-87WCV-QFEEU"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-2R9T4-9THFQ"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-WZ0RO-KAR30"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-H423V-C4GG9"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-D86T8-XAG7K"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-FMX4J-ANIZM"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-U14M3-6ONL3"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-W1Q32-OUMSS"] = { tier = "30day", expires = 1794959813 },
    ["OLLIE-37AG8-Q3LLA"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-BIRFM-N29Z4"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-7KQRL-XU440"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-R1JY2-XZPVI"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-X2BWF-E28WA"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-W9QTD-9G40M"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-FNHQC-LW2J6"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-RWW55-0WQFL"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-F5O0T-8JXKH"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-ZIA0L-7WIXX"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-FSIVL-8O5ZD"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-GPJC4-JVL5T"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-WQZ8Z-Q75G6"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-FYILR-DHNST"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-Q0GED-7WJWW"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-2KRQX-7DE5H"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-MVOZN-SIEVT"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-NF4H0-UUIQG"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-74D34-SP3DK"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-PMTNH-1W3E4"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-TCRLK-J8HIA"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-T4I58-DZ4HC"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-PU25U-IGTJ3"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-I2ZNM-I0M1L"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-1XWTD-15GTV"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-GNIQ3-9JFH1"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-UP2LI-35D45"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-6O5AE-05LRJ"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-15QTZ-OH4GA"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-E75R7-IX22V"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-0QPZ9-XUHCL"] = { tier = "30day", expires = 1794959814 },
    ["OLLIE-W9IYF-Q2OUZ"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-AS031-CHLB5"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-B2RP2-J07K0"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-Z74TK-I0DI5"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-ISOAU-7RMSZ"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-OQQZ5-I4CZ1"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-KZ9S7-VM80D"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-N48KG-CXF6D"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-GEA8S-J75CF"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-VNP9B-AVAMY"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-ONXIZ-13BVO"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-RN3SV-XP0NG"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-KDSZI-IADLW"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-EJOHQ-FOVNU"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-DUN7G-E57TL"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-W8WDE-8OW40"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-BGGXF-NAOMJ"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-K6AZS-HC2I5"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-U3TTP-GCUU8"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-NC3NA-ZODAX"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-8M7JV-NOOXN"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-6JSZ6-AVRMQ"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-14RJ1-SWHEY"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-2ROJG-0F4JP"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-HFRSE-29OST"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-OFQ0F-RX9GV"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-FN35N-LE40Y"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-PZ7CN-CIFVN"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-D70DB-GPTMY"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-O418Z-KDIGP"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-721NK-G1J7I"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-DTCGL-IZT1E"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-9LZRY-G7Q5D"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-OHZMD-T6HXK"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-8JHPK-W04NM"] = { tier = "30day", expires = 1794959815 },
    ["OLLIE-EWKCF-H4N5D"] = { tier = "30day", expires = 1794959816 },
    ["OLLIE-B9CR5-WJQU3"] = { tier = "30day", expires = 1794959816 },
    ["OLLIE-M6SV7-JX5DD"] = { tier = "30day", expires = 1794959816 },
    ["OLLIE-IJHSK-JGPG5"] = { tier = "30day", expires = 1794959816 },
    ["OLLIE-RNB4L-93WMP"] = { tier = "30day", expires = 1794959816 },
    ["OLLIE-SIXMB-WYFNC"] = { tier = "30day", expires = 1794959816 },
    ["OLLIE-3240S-ON0QX"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-SFPLF-BQUX5"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-U4MV9-R2GAN"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-F77RG-1KV3K"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-SUF83-M1R3K"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-OQVF0-50K16"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-UR0TQ-R16J4"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-BYD9Q-QJGAV"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-B6EDA-EU3U8"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-BZO5Z-KE8WM"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-1QSCL-7HHCP"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-2FQO1-OPO8R"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-1L04P-IOT8A"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-KV83R-VIIX3"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-XP9TP-1BYJM"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-XSZZE-QDOVV"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-IFF8L-HZJMP"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-2P6KC-01GTJ"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-3SQJ0-3PWW9"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-RV350-QV1EV"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-TLJSI-ZFOVG"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-1Q1K9-XHQBE"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-YNL0H-2AQ3L"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-GBNQ5-LBEHK"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-T7FB3-UTWJ4"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-ARXWF-K4PU2"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-WYC01-M4WBG"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-I32W2-RJOMW"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-57H9U-MYHM0"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-SZS9Z-ZS7YB"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-DUV8Z-MX55C"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-P0J1S-Z99V2"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-GY1Y1-3E791"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-VX56X-BVCAA"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-T3DPW-LOYN7"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-A4UTQ-GOQSP"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-DZH1M-GIS4D"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-QRC07-983YO"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-47UYT-AHCII"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-UR8PY-F0ETC"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-EAZTK-2818W"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-53H0C-DG8R5"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-X8CSY-EOF1A"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-10715-4303C"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-Y4RB6-4UKBL"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-JEM3A-0UMA3"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-660RM-PI6AE"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-VTBJV-WMWEQ"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-XSVWT-8X0NJ"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-5AX47-RH7P2"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-8E3RG-M4APS"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-8GMMY-O572U"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-ITYMJ-2A352"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-AXUJP-IOJ9L"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-YEJX3-C4FWY"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-0J58U-OP28B"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-BJMJ4-EOB9V"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-ZLB9T-WT5VB"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-UK5FA-X4P4W"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-M2FQU-XCH1X"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-2LCOU-QWCFN"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-XSO7T-WOMWC"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-BT6MQ-7MT1C"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-IHYBK-EEDN5"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-AM0UU-DRA5Z"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-U0SSS-2EI2B"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-DLCJM-ZKU8R"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-PYC0V-U07Z0"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-K3KZH-4UEBJ"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-ZDFTQ-C31EY"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-5R9AJ-UCVYW"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-BLD7L-SIPL7"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-89CLM-O4B3K"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-9ODFQ-UGSBP"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-OBYUJ-4JBZ1"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-V5DLE-FVDS4"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-NPUEX-FGHF6"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-KD2IX-V07MK"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-LWKTL-6L08H"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-GCZSM-MPOB8"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-CWJ5K-9A3L1"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-AK67K-8ASKM"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-6I43E-66VF5"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-S9M8C-IL00R"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-2IV79-YDWXK"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-AG5DT-048KZ"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-57UVT-RZI8W"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-KAAKJ-UVDF0"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-UF2CK-5ZW2Q"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-T2AFE-ZMS2S"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-0D00F-Q6RU3"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-UEUZ8-U53PH"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-GYEQZ-78DJF"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-VW5AX-93BAH"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-R1V2F-KV5WE"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-5FEQE-15VTJ"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-GFOJQ-9CU85"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-VFKO2-B9W32"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-F4CUG-CGEHN"] = { tier = "lifetime", expires = 9999999999 },
    ["OLLIE-2RB0R-H1JZ1"] = { tier = "lifetime", expires = 9999999999 },
}

-- ============================================
-- KEY GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = pg

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 220)
Frame.Position = UDim2.new(0.5, -175, 0.5, -110)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = Frame
local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(0, 200, 255); s.Thickness = 1.5; s.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "OLLIE ADMIN"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.8, 0, 0, 40)
TextBox.Position = UDim2.new(0.1, 0, 0.25, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TextBox.PlaceholderText = "OLLIE-XXXXX-XXXXX"
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.Code
TextBox.TextSize = 14
TextBox.BorderSizePixel = 0
TextBox.Parent = Frame
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 6); tc.Parent = TextBox

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0.8, 0, 0, 40)
Button.Position = UDim2.new(0.1, 0, 0.55, 0)
Button.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
Button.Text = "VERIFY KEY"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Button.BorderSizePixel = 0
Button.Parent = Frame
local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = Button

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 40)
Status.Position = UDim2.new(0, 0, 0.8, 0)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(255, 60, 60)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = Frame

Button.MouseButton1Click:Connect(function()
    local enteredKey = TextBox.Text
    local keyData = VALID_KEYS[enteredKey]
    
    if not keyData then
        Status.TextColor3 = Color3.fromRGB(255, 60, 60)
        Status.Text = "Invalid Key."
        return
    end
    
    local now = os.time()
    if now > keyData.expires then
        Status.TextColor3 = Color3.fromRGB(255, 100, 60)
        Status.Text = "This key has expired."
        return
    end
    
    Status.TextColor3 = Color3.fromRGB(0, 255, 100)
    Status.Text = "Key Valid! Tier: " .. keyData.tier
    task.wait(1)
    ScreenGui:Destroy()
    
    -- ============================================
    -- LOAD ADMIN PANEL (PASTE YOUR SCRIPT URL HERE)
    -- ============================================
    isPremium = true
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/admin_panel.lua"))()
end)
