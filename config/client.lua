return {
    useTarget = true,
    debugPoly = false,
    useBlips = true,
    pedLoc = vec4(894.93, -179.12, 73.7, 237.09),
    allowedVehicles = {
        { model = 'taxi', rent = 500, defaultPrice = 30.0, startingPrice = 100.0, label = 'Taxi Standard' },
    },
    locations = {
        main = {
            coords = vec4(901.23, -181.78, 73.93, 238.5),
        },
        garage = {
            coords = vec3(901.23, -181.78, 73.93),
        }
    },
    pzLocations = {
        takeLocations = {
            { coord = vec3(258.98, -377.9, 44.7),      height = 17.6, width = 10.2, heading = 69,  minZ = 43.75,  maxZ = 45.55 },
            { coord = vec3(-50.06, -784.57, 44.16),    height = 17.6, width = 10.2, heading = 62,  minZ = 43.21,  maxZ = 45.01 },
            { coord = vec3(238.93, -858.91, 29.67),    height = 17.6, width = 10.2, heading = 71,  minZ = 28.72,  maxZ = 30.52 },
            { coord = vec3(823.4, -1882.96, 29.29),    height = 17.6, width = 10.2, heading = 167, minZ = 28.34,  maxZ = 30.14 },
            { coord = vec3(354.05, -1971.57, 24.43),   height = 17.6, width = 10.2, heading = 236, minZ = 23.48,  maxZ = 25.28 },
            { coord = vec3(-225.61, -2043.63, 27.62),  height = 17.6, width = 10.2, heading = 143, minZ = 26.67,  maxZ = 28.47 },
            { coord = vec3(-1048.72, -2714.2, 13.76),  height = 17.6, width = 10.2, heading = 240, minZ = 12.81,  maxZ = 14.61 },
            { coord = vec3(-776.15, -1280.37, 5.0),    height = 17.6, width = 10.2, heading = 261, minZ = 4.05,   maxZ = 5.85 },
            { coord = vec3(-1180.3, -1304.22, 5.15),   height = 17.6, width = 10.2, heading = 205, minZ = 4.2,    maxZ = 6.0 },
            { coord = vec3(-1326.52, -833.32, 16.85),  height = 17.6, width = 10.2, heading = 225, minZ = 15.9,   maxZ = 17.7 },
            { coord = vec3(-1610.24, -1015.33, 13.07), height = 17.6, width = 10.2, heading = 227, minZ = 12.12,  maxZ = 13.92 },
            { coord = vec3(-1396.85, -583.72, 30.08),  height = 17.6, width = 10.2, heading = 299, minZ = 29.13,  maxZ = 30.93 },
            { coord = vec3(-513.06, -263.2, 35.43),    height = 17.6, width = 10.2, heading = 293, minZ = 34.48,  maxZ = 36.28 },
            { coord = vec3(-756.46, -35.84, 37.69),    height = 17.6, width = 10.2, heading = 297, minZ = 36.74,  maxZ = 38.54 },
            { coord = vec3(-1285.33, 293.67, 64.83),   height = 17.6, width = 10.2, heading = 241, minZ = 63.88,  maxZ = 65.68 },
            { coord = vec3(-806.68, 825.2, 202.81),    height = 21.2, width = 10.2, heading = 276, minZ = 200.46, maxZ = 204.66 },
        },

        dropLocations = {
            { coord = vec3(-1073.21, -265.35, 37.35), height = 21.2, width = 10.2, heading = 296, minZ = 35.0,   maxZ = 39.2 },
            { coord = vec3(-1411.45, -590.98, 29.99), height = 21.2, width = 10.2, heading = 299, minZ = 27.64,  maxZ = 31.84 },
            { coord = vec3(-678.68, -845.54, 23.53),  height = 21.2, width = 10.2, heading = 269, minZ = 21.18,  maxZ = 25.38 },
            { coord = vec3(-159.11, -1565.46, 34.69), height = 21.2, width = 10.2, heading = 321, minZ = 32.34,  maxZ = 36.54 },
            { coord = vec3(442.12, -1685.31, 28.85),  height = 21.2, width = 10.2, heading = 321, minZ = 26.5,   maxZ = 30.7 },
            { coord = vec3(1120.51, -958.97, 46.83),  height = 21.2, width = 10.2, heading = 286, minZ = 44.48,  maxZ = 48.68 },
            { coord = vec3(1240.79, -377.77, 68.61),  height = 21.2, width = 10.2, heading = 249, minZ = 66.26,  maxZ = 70.46 },
            { coord = vec3(923.66, -2226.07, 29.98),  height = 21.2, width = 10.2, heading = 354, minZ = 27.63,  maxZ = 31.83 },
            { coord = vec3(1920.15, 3701.6, 32.26),   height = 21.2, width = 10.2, heading = 299, minZ = 29.91,  maxZ = 34.11 },
            { coord = vec3(1661.91, 4875.87, 41.66),  height = 21.2, width = 10.2, heading = 8,   minZ = 39.31,  maxZ = 43.51 },
            { coord = vec3(-9.46, 6529.92, 30.95),    height = 21.2, width = 10.2, heading = 314, minZ = 28.6,   maxZ = 32.8 },
            { coord = vec3(-3233.12, 1010.33, 11.72), height = 21.2, width = 10.2, heading = 357, minZ = 9.37,   maxZ = 13.57 },
            { coord = vec3(-1604.11, -401.71, 41.95), height = 21.2, width = 10.2, heading = 322, minZ = 39.6,   maxZ = 43.8 },
            { coord = vec3(-586.48, -255.96, 36.53),  height = 21.2, width = 10.2, heading = 31,  minZ = 34.68,  maxZ = 37.48 },
            { coord = vec3(23.51, -60.47, 63.2),      height = 21.2, width = 10.2, heading = 156, minZ = 60.55,  maxZ = 65.75 },
            { coord = vec3(550.26, 172.54, 99.71),    height = 21.2, width = 10.2, heading = 161, minZ = 98.51,  maxZ = 100.91 },
            { coord = vec3(-1048.62, -2540.53, 13.3), height = 21.2, width = 10.2, heading = 151, minZ = 12.9,   maxZ = 14.9 },
            { coord = vec3(-10.06, -544.39, 38.28),   height = 21.2, width = 10.2, heading = 91,  minZ = 36.28,  maxZ = 39.88 },
            { coord = vec3(-7.91, -258.19, 46.49),    height = 21.2, width = 10.2, heading = 71,  minZ = 45.29,  maxZ = 47.69 },
            { coord = vec3(-743.03, 818.9, 213.16),   height = 21.2, width = 10.2, heading = 38,  minZ = 211.96, maxZ = 214.36 },
            { coord = vec3(218.25, 677.55, 188.87),   height = 21.2, width = 10.2, heading = 163, minZ = 187.67, maxZ = 190.07 },
            { coord = vec3(264.47, 1138.41, 221.36),  height = 21.2, width = 10.2, heading = 203, minZ = 220.16, maxZ = 222.56 },
            { coord = vec3(220.47, -1010.7, 28.82),   height = 21.2, width = 10.2, heading = 158, minZ = 28.02,  maxZ = 30.42 },
        }
    },
    cabSpawns = {
        vec4(899.0837, -180.4414, 73.4115, 238.7553),
        vec4(897.1274, -183.3882, 73.3531, 238.4949),
        vec4(903.4929, -191.7166, 73.3883, 60.5255),
        vec4(904.9221, -188.7516, 73.4204, 60.5921),
        vec4(906.9083, -186.0502, 73.6249, 58.2671),
        vec4(908.7374, -183.2168, 73.7542, 57.1579),
        vec4(911.3865, -163.0307, 73.9763, 194.4093),
        vec4(913.5932, -159.4309, 74.3888, 193.9838),
        vec4(916.0979, -170.6549, 74.0125, 100.604),
        vec4(918.3217, -167.1944, 74.2036, 101.5165),
        vec4(920.6716, -163.4763, 74.4108, 96.2972),
    },
    npcSkins = {
        {
            'a_f_m_skidrow_01',
            'a_f_m_soucentmc_01',
            'a_f_m_soucent_01',
            'a_f_m_soucent_02',
            'a_f_m_tourist_01',
            'a_f_m_trampbeac_01',
            'a_f_m_tramp_01',
            'a_f_o_genstreet_01',
            'a_f_o_indian_01',
            'a_f_o_ktown_01',
            'a_f_o_salton_01',
            'a_f_o_soucent_01',
            'a_f_o_soucent_02',
            'a_f_y_beach_01',
            'a_f_y_bevhills_01',
            'a_f_y_bevhills_02',
            'a_f_y_bevhills_03',
            'a_f_y_bevhills_04',
            'a_f_y_business_01',
            'a_f_y_business_02',
            'a_f_y_business_03',
            'a_f_y_business_04',
            'a_f_y_eastsa_01',
            'a_f_y_eastsa_02',
            'a_f_y_eastsa_03',
            'a_f_y_epsilon_01',
            'a_f_y_fitness_01',
            'a_f_y_fitness_02',
            'a_f_y_genhot_01',
            'a_f_y_golfer_01',
            'a_f_y_hiker_01',
            'a_f_y_hipster_01',
            'a_f_y_hipster_02',
            'a_f_y_hipster_03',
            'a_f_y_hipster_04',
            'a_f_y_indian_01',
            'a_f_y_juggalo_01',
            'a_f_y_runner_01',
            'a_f_y_rurmeth_01',
            'a_f_y_scdressy_01',
            'a_f_y_skater_01',
            'a_f_y_soucent_01',
            'a_f_y_soucent_02',
            'a_f_y_soucent_03',
            'a_f_y_tennis_01',
            'a_f_y_tourist_01',
            'a_f_y_tourist_02',
            'a_f_y_vinewood_01',
            'a_f_y_vinewood_02',
            'a_f_y_vinewood_03',
            'a_f_y_vinewood_04',
            'a_f_y_yoga_01',
            'g_f_y_ballas_01',
        },
        {
            'ig_barry',
            'ig_bestmen',
            'ig_beverly',
            'ig_car3guy1',
            'ig_car3guy2',
            'ig_casey',
            'ig_chef',
            'ig_chengsr',
            'ig_chrisformage',
            'ig_clay',
            'ig_claypain',
            'ig_cletus',
            'ig_dale',
            'ig_dreyfuss',
            'ig_fbisuit_01',
            'ig_floyd',
            'ig_groom',
            'ig_hao',
            'ig_hunter',
            'csb_prolsec',
            'ig_joeminuteman',
            'ig_josef',
            'ig_josh',
            'ig_lamardavis',
            'ig_lazlow',
            'ig_lestercrest',
            'ig_lifeinvad_01',
            'ig_lifeinvad_02',
            'ig_manuel',
            'ig_milton',
            'ig_mrk',
            'ig_nervousron',
            'ig_nigel',
            'ig_old_man1a',
            'ig_old_man2',
            'ig_oneil',
            'ig_orleans',
            'ig_ortega',
            'ig_paper',
            'ig_priest',
            'ig_prolsec_02',
            'ig_ramp_gang',
            'ig_ramp_hic',
            'ig_ramp_hipster',
            'ig_ramp_mex',
            'ig_roccopelosi',
            'ig_russiandrunk',
            'ig_siemonyetarian',
            'ig_solomon',
            'ig_stevehains',
            'ig_stretch',
            'ig_talina',
            'ig_taocheng',
            'ig_taostranslator',
            'ig_tenniscoach',
            'ig_terry',
            'ig_tomepsilon',
            'ig_tylerdix',
            'ig_wade',
            'ig_zimbor',
            's_m_m_paramedic_01',
            'a_m_m_afriamer_01',
            'a_m_m_beach_01',
            'a_m_m_beach_02',
            'a_m_m_bevhills_01',
            'a_m_m_bevhills_02',
            'a_m_m_business_01',
            'a_m_m_eastsa_01',
            'a_m_m_eastsa_02',
            'a_m_m_farmer_01',
            'a_m_m_fatlatin_01',
            'a_m_m_genfat_01',
            'a_m_m_genfat_02',
            'a_m_m_golfer_01',
            'a_m_m_hasjew_01',
            'a_m_m_hillbilly_01',
            'a_m_m_hillbilly_02',
            'a_m_m_indian_01',
            'a_m_m_ktown_01',
            'a_m_m_malibu_01',
            'a_m_m_mexcntry_01',
            'a_m_m_mexlabor_01',
            'a_m_m_og_boss_01',
            'a_m_m_paparazzi_01',
            'a_m_m_polynesian_01',
            'a_m_m_prolhost_01',
            'a_m_m_rurmeth_01',
        }
    }
}
