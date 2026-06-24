clc; clear; close all;

%% =========================================================================
%  MASTER SCRIPT: PENGOLAHAN DATA PASANG SURUT STASIUN PANJANG
%% =========================================================================

cd('C:\0_sealevel\datas\tiderun');
disp('Direktori kerja aktif di C:\0_sealevel\datas\tiderun');

file_list = {'0006PANJ01_2015.txt','0006PANJ01_2016.txt','0006PANJ01_2017.txt','0006PANJ01_2018.txt','0006PANJ01_2019.txt','0006PANJ01_2020.txt','0006PANJ01_2021.txt', '0006PANJ01_2022.txt', '0006PANJ01_2024.txt'};
tahun_list = [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2024];
lintang_panjang = -5.46999; 

all_time = []; all_elev_m = [];
fprintf('Membaca data teks mentah BIG...\n');
for i = 1:length(file_list)
    fid = fopen(file_list{i}, 'r');
    data = textscan(fid, '%s %s %f', 'HeaderLines', 14);
    fclose(fid);
    
    str_time = strcat(data{1}, {' '}, data{2});
    waktu_temp = datetime(str_time, 'InputFormat', 'dd/MM/yyyy HH:mm:ss');
    elev_temp_m = data{3} / 100;
    
    all_time = [all_time; waktu_temp];
    all_elev_m = [all_elev_m; elev_temp_m];
end

disp('Tahap 1: Mengeksekusi T_Tide Keseluruhan untuk SLA In-Situ (Meter)...');
waktu_awal = min(all_time);
waktu_akhir = max(all_time);

time_continuous = (waktu_awal : hours(1) : waktu_akhir)';
elev_continuous_m = NaN(length(time_continuous), 1);

[~, Locb] = ismember(all_time, time_continuous);
elev_continuous_m(Locb) = all_elev_m; 

[~, pout_all_m] = t_tide(elev_continuous_m, 'interval', 1, ...
    'start time', datenum(time_continuous(1)), ...
    'latitude', lintang_panjang, 'synthesis', 1, 'output', 'none');

residu_hourly_m = elev_continuous_m - pout_all_m;
TT_hourly = timetable(time_continuous, residu_hourly_m, 'VariableNames', {'SLA_InSitu_Meter'});
TT_monthly = retime(TT_hourly, 'monthly', @(x) mean(x, 'omitnan'));

writetimetable(TT_monthly, '1_Output_SLA_Panjang_Bulanan_Meter.csv');
disp('--> Berhasil: File "1_Output_SLA_Panjang_Bulanan_Meter.csv" telah dibuat.');

%% ANALISIS ELEVASI & KOMPONEN TAHUNAN (SATUAN SENTIMETER)
disp('Tahap 2: Menganalisis Parameter Pasut Tahunan (Sentimeter)...');

t_tahun = []; t_M2 = []; t_S2 = []; t_K1 = []; t_O1 = [];
t_N2 = []; t_K2 = []; t_P1 = []; t_Q1 = [];
t_F = []; t_tipe = {}; t_HHWL = []; t_MHWL = []; 
t_MSL = []; t_MLWL = []; t_LLWL = [];

for i = 1:length(file_list)
    fprintf('   Memproses Data Tahun %d...\n', tahun_list(i));
    
    fid = fopen(file_list{i}, 'r');
    data = textscan(fid, '%s %s %f', 'HeaderLines', 14);
    fclose(fid);
    
    waktu_thn = datetime(strcat(data{1}, {' '}, data{2}), 'InputFormat', 'dd/MM/yyyy HH:mm:ss');
    elev_cm = data{3}; 
    
    [tidestruc, pout_cm] = t_tide(elev_cm, 'interval', 1, ...
        'start time', datenum(waktu_thn(1)), ...
        'latitude', lintang_panjang, 'synthesis', 1, 'output', 'none');
    
    nama_konstanta = cellstr(tidestruc.name);
    amplitudo_cm = tidestruc.tidecon(:,1);
    
    A_M2 = amplitudo_cm(strcmp(strtrim(nama_konstanta), 'M2'));
    A_S2 = amplitudo_cm(strcmp(strtrim(nama_konstanta), 'S2'));
    A_K1 = amplitudo_cm(strcmp(strtrim(nama_konstanta), 'K1'));
    A_O1 = amplitudo_cm(strcmp(strtrim(nama_konstanta), 'O1'));
    
    A_N2 = amplitudo_cm(strcmp(strtrim(nama_konstanta), 'N2'));
    A_K2 = amplitudo_cm(strcmp(strtrim(nama_konstanta), 'K2'));
    A_P1 = amplitudo_cm(strcmp(strtrim(nama_konstanta), 'P1'));
    A_Q1 = amplitudo_cm(strcmp(strtrim(nama_konstanta), 'Q1'));
    
    if isempty(A_N2), A_N2 = NaN; end
    if isempty(A_K2), A_K2 = NaN; end
    if isempty(A_P1), A_P1 = NaN; end
    if isempty(A_Q1), A_Q1 = NaN; end
    
    F = (A_K1 + A_O1) / (A_M2 + A_S2);
    if F <= 0.25, tipe = 'Semidiurnal';
    elseif F > 0.25 && F <= 1.5, tipe = 'Mixed Semidiurnal';
    elseif F > 1.5 && F <= 3.0, tipe = 'Mixed Diurnal';
    else, tipe = 'Diurnal'; end
    
    MSL_Z0_cm = mean(elev_cm, 'omitnan');
    tide_model_cm = pout_cm + MSL_Z0_cm;
    
    idx_hw = find(tide_model_cm(2:end-1) > tide_model_cm(1:end-2) & tide_model_cm(2:end-1) > tide_model_cm(3:end)) + 1;
    all_HWL = tide_model_cm(idx_hw);
    
    idx_lw = find(tide_model_cm(2:end-1) < tide_model_cm(1:end-2) & tide_model_cm(2:end-1) < tide_model_cm(3:end)) + 1;
    all_LWL = tide_model_cm(idx_lw);
    
    HHWL_cm = max(elev_cm, [], 'omitnan');
    LLWL_cm = min(elev_cm, [], 'omitnan');
    MHWL_cm = mean(all_HWL, 'omitnan');
    MLWL_cm = mean(all_LWL, 'omitnan');
    
    t_tahun = [t_tahun; tahun_list(i)];
    t_M2 = [t_M2; A_M2]; t_S2 = [t_S2; A_S2]; t_K1 = [t_K1; A_K1]; t_O1 = [t_O1; A_O1];
    
    t_N2 = [t_N2; A_N2]; t_K2 = [t_K2; A_K2]; t_P1 = [t_P1; A_P1]; t_Q1 = [t_Q1; A_Q1]; 
    
    t_F = [t_F; F]; t_tipe = [t_tipe; {tipe}];
    t_HHWL = [t_HHWL; HHWL_cm]; t_MHWL = [t_MHWL; MHWL_cm];
    t_MSL = [t_MSL; MSL_Z0_cm]; t_MLWL = [t_MLWL; MLWL_cm]; t_LLWL = [t_LLWL; LLWL_cm];
end

Output_Matriks = table(t_tahun, t_M2, t_S2, t_N2, t_K2, t_K1, t_O1, t_P1, t_Q1, t_F, t_tipe, ...
    t_HHWL, t_MHWL, t_MSL, t_MLWL, t_LLWL, ...
    'VariableNames', {'Tahun', 'A_M2_cm', 'A_S2_cm', 'A_N2_cm', 'A_K2_cm', 'A_K1_cm', 'A_O1_cm', 'A_P1_cm', 'A_Q1_cm', 'Formzahl', 'Tipe_Pasut', ...
    'HHWL_cm', 'MHWL_cm', 'MSL_cm', 'MLWL_cm', 'LLWL_cm'});

writetable(Output_Matriks, '2_Output_Ringkasan_Pasut_Tahunan_CM.csv');
disp('SEMUA PROSES SELESAI!');
