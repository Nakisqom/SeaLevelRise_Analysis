clc; clear; close all;

%% =========================================================================
%  SCRIPT QUALITY CONTROL (QC) DATA PASANG SURUT BIG
%% =========================================================================

cd('C:\0_sealevel\datas\tiderun');
file_list = {'0006PANJ01_2015.txt','0006PANJ01_2016.txt','0006PANJ01_2017.txt','0006PANJ01_2018.txt','0006PANJ01_2019.txt','0006PANJ01_2020.txt','0006PANJ01_2021.txt', '0006PANJ01_2022.txt', '0006PANJ01_2024.txt'};

all_time = []; 
all_elev = [];

fprintf('Membaca data untuk Quality Control...\n');
for i = 1:length(file_list)
    fid = fopen(file_list{i}, 'r');
    data = textscan(fid, '%s %s %f', 'HeaderLines', 14);
    fclose(fid);
    
    str_time = strcat(data{1}, {' '}, data{2});
    waktu_temp = datetime(str_time, 'InputFormat', 'dd/MM/yyyy HH:mm:ss');
    elev_temp = data{3}; 
    
    all_time = [all_time; waktu_temp];
    all_elev = [all_elev; elev_temp];
end

waktu_awal = min(all_time);
waktu_akhir = max(all_time);

ideal_time = (waktu_awal : hours(1) : waktu_akhir)';
total_aktual = length(all_time);
total_ideal = length(ideal_time);
jumlah_hilang = total_ideal - total_aktual;

fprintf('\n======================================================\n');
fprintf('               LAPORAN DATA PASUT                  \n');
fprintf('======================================================\n');
fprintf('Waktu Awal Data   : %s\n', datestr(waktu_awal, 'dd-mmm-yyyy HH:MM'));
fprintf('Waktu Akhir Data  : %s\n', datestr(waktu_akhir, 'dd-mmm-yyyy HH:MM'));
fprintf('Total Data Aktual : %d baris observasi\n', total_aktual);
fprintf('Total Data Ideal  : %d baris (jika tanpa putus)\n', total_ideal);
fprintf('Total Data Kosong : %d jam (%.2f%% dari total ideal)\n', jumlah_hilang, (jumlah_hilang/total_ideal)*100);
fprintf('======================================================\n');

[tahun, bulan, ~] = ymd(all_time);
tahun_unik = unique(tahun);

qc_tahun = []; qc_bulan = []; qc_jam_aktual = []; qc_jam_ideal = []; qc_status = {};

fprintf('\n>>> RINCIAN DATA PER TAHUN & BULAN <<<\n');
for i = 1:length(tahun_unik)
    thn_skrg = tahun_unik(i);
    idx_thn = (tahun == thn_skrg);
    jml_thn = sum(idx_thn);
    
    fprintf('------------------------------------------------------\n');
    fprintf('TAHUN %d : Total %d data\n', thn_skrg, jml_thn);
    fprintf('------------------------------------------------------\n');
    
    for bln = 1:12
        idx_bln = (tahun == thn_skrg & bulan == bln);
        jml_bln = sum(idx_bln);
        
        if jml_bln > 0
            hari_dlm_bln = eomday(thn_skrg, bln);
            ideal_bln = hari_dlm_bln * 24;
            
            if jml_bln == ideal_bln
                status = 'LENGKAP';
            else
                status = sprintf('KURANG %d JAM', ideal_bln - jml_bln);
            end
            
            fprintf('  - Bulan %02d : %d observasi [%s]\n', bln, jml_bln, status);
            
            qc_tahun = [qc_tahun; thn_skrg];
            qc_bulan = [qc_bulan; bln];
            qc_jam_aktual = [qc_jam_aktual; jml_bln];
            qc_jam_ideal = [qc_jam_ideal; ideal_bln];
            qc_status = [qc_status; {status}];
        end
    end
end

T_Bulanan = table(qc_tahun, qc_bulan, qc_jam_aktual, qc_jam_ideal, qc_status, ...
    'VariableNames', {'Tahun', 'Bulan', 'Jam_Terekam', 'Jam_Ideal', 'Status_Ketersediaan'});
writetable(T_Bulanan, 'QC_Rekap_Bulanan.csv');
fprintf('\n--> [BERHASIL] File "QC_Rekap_Bulanan.csv" telah dibuat.\n');

fprintf('\n======================================================\n');
fprintf('>>> DETEKSI HARI DENGAN DATA TIDAK LENGKAP (< 24 JAM) <<<\n');
fprintf('======================================================\n');

waktu_harian = dateshift(all_time, 'start', 'day');
[waktu_unik, ~, idx_hari] = unique(waktu_harian);
jml_jam_per_hari = accumarray(idx_hari, 1);

idx_kurang = jml_jam_per_hari < 24;
hari_bermasalah = sum(idx_kurang);

for i = 1:length(waktu_unik)
    if jml_jam_per_hari(i) < 24
        fprintf('Peringatan: %s hanya memiliki %d jam observasi.\n', ...
            datestr(waktu_unik(i), 'dd-mmm-yyyy'), jml_jam_per_hari(i));
    end
end

if hari_bermasalah == 0
    fprintf('Luar biasa! Seluruh hari yang terekam memiliki data penuh 24 jam.\n');
else
    fprintf('\nTotal ada %d hari yang datanya tidak genap 24 jam.\n', hari_bermasalah);
    
    Tanggal_Bermasalah = waktu_unik(idx_kurang);
    Jam_Terekam = jml_jam_per_hari(idx_kurang);
    
    Tanggal_Str = datestr(Tanggal_Bermasalah, 'yyyy-mm-dd');
    
    T_Harian = table(string(Tanggal_Str), Jam_Terekam, ...
        'VariableNames', {'Tanggal', 'Jumlah_Jam_Terekam'});
    writetable(T_Harian, 'QC_Hari_Bermasalah.csv');
    fprintf('--> [BERHASIL] File "QC_Hari_Bermasalah.csv" telah dibuat.\n');
end

fprintf('======================================================\n');
disp('Proses QC dan Ekspor Data Selesai.');