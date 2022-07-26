function [f1_use, f2_use] = getf1f2(K_use)
    K=[40, 48, 56, 64, 72, 80, 88, 96, 104, 112, 120, ...      
    128, 136, 144, 152, 160, 168, 176, 184, 192, 200, 208, 216, 224, 232,...
    240, 248, 256, 264, 272, 280, 288, 296, 304, 312, 320, 328, 336, 344,...
    352, 360, 368, 376, 384, 392, 400, 408, 416, 424, 432, 440, 448, 456,...
    464, 472, 480, 488, 496, 504, 512, 528, 544, 560, 576, 592, 608, 624,...
    640, 656, 672, 688, 704, 720, 736, 752, 768, 784, 800, 816, 832, 848,...
    864, 880, 896, 912, 928, 944, 960, 976, 992, 1008, 1024, 1056, 1088,...
    1120, 1152, 1184, 1216, 1248, 1280, 1312, 1344, 1376, 1408, 1440, 1472,...
    1504, 1536, 1568, 1600, 1632, 1664, 1696, 1728, 1760, 1792, 1824, 1856,...
    1888, 1920, 1952, 1984, 2016, 2048, 2112, 2176, 2240, 2304, 2368, 2432,...
    2496, 2560, 2624, 2688, 2752, 2816, 2880, 2944, 3008, 3072, 3136, 3200,...
    3264, 3328, 3392, 3456, 3520, 3584, 3648, 3712, 3776, 3840, 3904, 3968,...
    4032, 4096, 4160, 4224, 4288, 4352, 4416, 4480, 4544, 4608, 4672, 4736,...
    4800, 4864, 4928, 4992, 5056, 5120, 5184, 5248, 5312, 5376, 5440, 5504,...
    5568, 5632, 5696, 5760, 5824, 5888, 5952, 6016, 6080, 6144];
    f1=[3, 7, 19, 7, 7, 11, 5, 11, 7, 41, 103,...
    15, 9, 17, 9, 21, 101, 21, 57, 23, 13, 27, 11, 27, 85, 29, 33, 15, 17, 33,...
    103, 19, 19, 37, 19, 21, 21, 115, 193, 21, 133, 81, 45, 23, 243, 151, 155,...
    25, 51, 47, 91, 29, 29, 247, 29, 89, 91, 157, 55, 31, 17, 35, 227, 65, 19,...
    37, 41, 39, 185, 43, 21, 155, 79, 139, 23, 217, 25, 17, 127, 25, 239, 17,...
    137, 215, 29, 15, 147, 29, 59, 65, 55, 31, 17, 171, 67, 35, 19, 39, 19, 199,...
    21, 211, 21, 43, 149, 45, 49, 71, 13, 17, 25, 183, 55, 127, 27, 29, 29, 57,...
    45, 31, 59, 185, 113, 31, 17, 171, 209, 253, 367, 265, 181, 39, 27, 127,...
    143, 43, 29, 45, 157, 47, 13, 111, 443, 51, 51, 451, 257, 57, 313, 271, 179,...
    331, 363, 375, 127, 31, 33, 43, 33, 477, 35, 233, 357, 337, 37, 71, 71, 37,...
    39, 127, 39, 39, 31, 113, 41, 251, 43, 21, 43, 45, 45, 161, 89, 323, 47, 23,...
    47, 263];
    f2=[10, 12, 42, 16, 18, 20, 22, 24, 26, 84,...
    90, 32, 34, 108, 38, 120, 84, 44, 46, 48, 50, 52, 36, 56, 58, 60, 62, 32,...           
    198, 68, 210, 36, 74, 76, 78, 120, 82, 84, 86, 44, 90, 46, 94, 48, 98, 40,...
    102, 52, 106, 72, 110, 168, 114, 58, 118, 180, 122, 62, 84, 64, 66, 68, 420,...
    96, 74, 76, 234, 80, 82, 252, 86, 44, 120, 92, 94, 48, 98, 80, 102, 52, 106,...
    48, 110, 112, 114, 58, 118, 60, 122, 124, 84, 64, 66, 204, 140, 72, 74, 76,...
    78, 240, 82, 252, 86, 88, 60, 92, 846, 48, 28, 80, 102, 104, 954, 96, 110,...
    112, 114, 116, 354, 120, 610, 124, 420, 64, 66, 136, 420, 216, 444, 456,...
    468, 80, 164, 504, 172, 88, 300, 92, 188, 96, 28, 240, 204, 104, 212, 192,...
    220, 336, 228, 232, 236, 120, 244, 248, 168, 64, 130, 264, 134, 408, 138,...
    280, 142, 480, 146, 444, 120, 152, 462, 234, 158, 80, 96, 902, 166, 336,...
    170, 86, 174, 176, 178, 120, 182, 184, 186, 94, 190, 480];

    %获取对应的f1，f2
    index = find(K == K_use);
    f1_use = f1(index);
    f2_use = f2(index);
end