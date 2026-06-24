clc; clear; close all;

%% =========================================================================
%        ANALISIS TREN KENAIKAN MUKA AIR LAUT (SLA)
%% =========================================================================

cd('C:\0_sealevel\datas\tiderun');
outputFolder = 'C:\0_sealevel\datas\tiderun\export';
disp('Memuat data deret waktu SLA Satelit...');

sat_data = readtable('3_Output_SLA_Satelit_Bulanan.csv');
sat_data.Properties.VariableNames{1} = 'Waktu';

waktu = sat_data.Waktu;
sla_meter = sat_data.SLA_Satelit_Meter;

tahun_desimal = year(waktu) + (month(waktu) - 0.5) / 12;

% koef_regresi(1) adalah 'a' (slope/kemiringan dalam meter/tahun)
% koef_regresi(2) adalah 'b' (intercept/titik potong sumbu Y)
koef_regresi = polyfit(tahun_desimal, sla_meter, 1);
a_slope = koef_regresi(1);
b_intercept = koef_regresi(2);

sla_prediksi_tren_meter = polyval(koef_regresi, tahun_desimal);

fprintf('\n======================================================\n');
fprintf('       PERSAMAAN REGRESI LINEAR TREN SLA              \n');
fprintf('======================================================\n');
fprintf('Bentuk Persamaan : y = ax + b\n');
fprintf('Nilai a (Slope)  : %.6f meter/tahun\n', a_slope);
fprintf('Nilai b (Inter.) : %.6f meter\n', b_intercept);
fprintf('------------------------------------------------------\n');
fprintf('Persamaan Akhir  : y = %.6fx + (%.6f)\n', a_slope, b_intercept);
fprintf('Laju Kenaikan    : %.2f mm/tahun\n', a_slope * 1000);
fprintf('======================================================\n');

Tabel_Tren = table(waktu, sla_meter, sla_prediksi_tren_meter, ...
    'VariableNames', {'Bulan_Tahun', 'SLA_Satelit_Meter', 'SLA_Tren_Linear_Meter'});

writetable(Tabel_Tren, '4_Output_Tren_SLA_Bulanan.csv');
fprintf('\n--> [BERHASIL] File "4_Output_Tren_SLA_Bulanan.csv" telah dibuat.\n');
disp('File ini berisi nilai ketinggian SLA asli dan nilai ketinggian regresi (y) per bulannya.');

figure('Name', 'Persamaan Regresi Tren SLA', 'Position', [200 200 800 400]);
set(gcf, 'Position', get(0, 'Screensize'));

plot(waktu, sla_meter, 'Color', [0.3 0.6 0.9], 'LineWidth', 1.5); hold on;
plot(waktu, sla_prediksi_tren_meter, 'r--', 'LineWidth', 2.5);

title('Grafik Trend Linear Kenaikan Muka Air Laut', 'FontSize', 14);
ylabel('SLA (Meter)', 'FontSize', 11);
xlabel('Tahun', 'FontSize', 11);
grid on;

teks_persamaan = sprintf('y = %.6fx + (%.6f)\nLaju = %.2f mm/thn', a_slope, b_intercept, a_slope * 1000);
annotation('textbox', [0.15 0.75 0.25 0.1], 'String', teks_persamaan, ...
    'FitBoxToText', 'on', 'BackgroundColor', 'white', 'EdgeColor', 'black');
hold off;
exportgraphics(gcf, fullfile(outputFolder, 'trendanalysis.png'), 'Resolution', 300);
