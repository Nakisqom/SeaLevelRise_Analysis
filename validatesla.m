clc; clear; close all;

%% =========================================================================
%        VALIDASI DATA SLA SATELIT VS TIDE GAUGE
%% =========================================================================

cd('C:\0_sealevel\datas\tiderun');
disp('Memuat data satelit dan in-situ...');
outputFolder = 'C:\0_sealevel\datas\tiderun\export';

tide_data = readtable('1_Output_SLA_Panjang_Bulanan_Meter.csv');
sat_data = readtable('3_Output_SLA_Satelit_Bulanan.csv');

tide_data.Properties.VariableNames{1} = 'Waktu';
sat_data.Properties.VariableNames{1} = 'Waktu';

tide_data.Waktu = dateshift(tide_data.Waktu, 'start', 'month');
sat_data.Waktu = dateshift(sat_data.Waktu, 'start', 'month');

merged_data = innerjoin(tide_data, sat_data, 'Keys', 'Waktu');

valid_idx = ~isnan(merged_data.SLA_InSitu_Meter) & ~isnan(merged_data.SLA_Satelit_Meter);
data_valid = merged_data(valid_idx, :);

fprintf('Ditemukan %d bulan data yang beririsan untuk validasi.\n', height(data_valid));

mean_insitu = mean(data_valid.SLA_InSitu_Meter);
mean_satelit = mean(data_valid.SLA_Satelit_Meter);

insitu_anomali = data_valid.SLA_InSitu_Meter - mean_insitu;
satelit_anomali = data_valid.SLA_Satelit_Meter - mean_satelit;

[R, P_val] = corrcoef(insitu_anomali, satelit_anomali);
r_pearson = R(1,2);
p_value = P_val(1,2);

rmse_val = sqrt(mean((insitu_anomali - satelit_anomali).^2));

fprintf('\n========================================\n');
fprintf('        HASIL VALIDASI DATA SLA           \n');
fprintf('========================================\n');
fprintf('Korelasi Pearson (r) : %.4f\n', r_pearson);
fprintf('P-Value              : %.4e\n', p_value);
fprintf('RMSE                 : %.4f Meter\n', rmse_val);
fprintf('========================================\n\n');


figure('Name', 'Validasi SLA Satelit vs In-Situ', 'Position', [100 100 1000 400]);
set(gcf, 'Position', get(0, 'Screensize'));
plot(data_valid.Waktu, insitu_anomali, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4); hold on;
plot(data_valid.Waktu, satelit_anomali, 'r-*', 'LineWidth', 1.5, 'MarkerSize', 4);
title('Perbandingan Fluktuasi SLA (Mean-Centered)');
ylabel('SLA (Meter)');
xlabel('Waktu');
legend('Tide Gauge (In-Situ)', 'Altimetri (Satelit)', 'Location', 'best');
grid on; hold off;
teks_statistik = sprintf('r = %.4f\nRMSE = %.4f m', r_pearson, rmse_val);
text(0.83, 0.11, teks_statistik, 'Units', 'normalized', ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontWeight', 'bold');
hold off;
exportgraphics(gcf, fullfile(outputFolder, 'validate.png'), 'Resolution', 300);

figure('Name', 'Scatter Plot', 'Position', [100 100 1000 400]);
set(gcf, 'Position', get(0, 'Screensize'));
scatter(insitu_anomali, satelit_anomali, 40, 'm', 'filled', 'MarkerEdgeColor', 'k'); hold on;

koef_regresi = polyfit(insitu_anomali, satelit_anomali, 1);
y_fit = polyval(koef_regresi, insitu_anomali);
plot(insitu_anomali, y_fit, 'k--', 'LineWidth', 1.5);

title(sprintf('Scatter Plot Validasi\nr = %.3f | RMSE = %.3f m', r_pearson, rmse_val));
xlabel('SLA In-Situ (Meter)');
ylabel('SLA Satelit (Meter)');
grid on; hold off;
exportgraphics(gcf, fullfile(outputFolder, 'scatterplot.png'), 'Resolution', 300);

disp('Validasi selesai. Silakan cek grafik yang dihasilkan.');