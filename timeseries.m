clc; clear; close all;

%% =========================================================================
%               VISUALISASI TIME SERIES PARAMETER (2005-2025)
% =========================================================================

nama_file = 'datas.csv';
outputFolder = 'C:\0_sealevel\datas\ocean';
disp(['Memuat data dari ', nama_file, '...']);

opts = detectImportOptions(nama_file);
opts = setvaropts(opts, 'Date', 'InputFormat', 'dd/MM/yyyy');
data = readtable(nama_file, opts);

waktu     = data.Date;
sla       = data.SLA;
sst       = data.SST;
salinitas = data.SSS;
angin     = data.WIN;
arus      = data.CUR;
nino34    = data.NIN;
dmi       = data.DMI;

%% ================================ SEA SURFACE TEMPERATURE ==================================

figure('Name', 'Time Series Parameter', 'Units', 'normalized', 'Position', [0 0.2 1 0.6]);

plot(waktu, sst, 'r-', 'LineWidth', 1.5, 'Color', [1 0 0]); 
mean_sst = mean(sst, 'omitnan');
yline(mean_sst, 'k--', 'LineWidth', 1.5);
text_mean = sprintf('Rata-rata (%.2f ^\\circC)', mean_sst);
axis tight;
set(gca, 'FontSize', 14);
set(gca, 'Color', [0.96 0.94 0.86]);
ylabel('Sea Surface Temperature (°C)', 'FontWeight', 'bold', 'FontSize', 14);
grid on;
xlim([min(waktu) max(waktu)]);
ylim([min(sst) max(sst)]);
lgd = legend('Sea Surface Temperature', text_mean,'Location', 'best');
lgd.Color = 'w';
lgd.FontSize = 11;
exportgraphics(gcf, fullfile(outputFolder, 'sst.png'), 'Resolution', 300);
disp('Proses plot SST selesai.');




%% ================================ SEA SURFACE SALINITY ==================================

figure('Name', 'Time Series Parameter', 'Units', 'normalized', 'Position', [0 0.2 1 0.6]);

plot(waktu, salinitas, 'b-', 'LineWidth', 1.5, 'Color', [0 0 1]); 
mean_sal = mean(salinitas, 'omitnan');
yline(mean_sal, 'k--', 'LineWidth', 1.5);
text_mean = sprintf('Rata-rata (%.2f PSU)', mean_sal);
axis tight;
set(gca, 'FontSize', 14);
set(gca, 'Color', [0.96 0.94 0.86]);
ylabel('Salinity (PSU)', 'FontWeight', 'bold', 'FontSize', 14);
grid on;
xlim([min(waktu) max(waktu)]);
ylim([min(salinitas) max(salinitas)]);
lgd = legend('Salinity', text_mean,'Location', 'best');
lgd.Color = 'w';
lgd.FontSize = 11;

exportgraphics(gcf, fullfile(outputFolder, 'salinity.png'), 'Resolution', 300);
disp('Proses plot Salinitas selesai.');




%% ================================     WIND     ==================================

figure('Name', 'Time Series Parameter', 'Units', 'normalized', 'Position', [0 0.2 1 0.6]);

plot(waktu, angin, 'k-', 'LineWidth', 1.5, 'Color', [0.13 0.55 0.13]); 
mean_win = mean(angin, 'omitnan');
yline(mean_win, 'k--', 'LineWidth', 1.5);
text_mean = sprintf('Rata-rata (%.2f m/s)', mean_win);
axis tight;
set(gca, 'FontSize', 14);
set(gca, 'Color', [0.96 0.94 0.86]);
ylabel('Kecepatan Angin (m/s)', 'FontWeight', 'bold', 'FontSize', 14);
grid on;
xlim([min(waktu) max(waktu)]);
ylim([min(angin) max(angin)]);
lgd = legend('Kecepatan Angin',text_mean, 'Location', 'best');
lgd.Color = 'w';
lgd.FontSize = 11;

exportgraphics(gcf, fullfile(outputFolder, 'wind.png'), 'Resolution', 300);
disp('Proses plot Kecepatan Angin selesai.');




%% ================================     CUR     ==================================

figure('Name', 'Time Series Parameter', 'Units', 'normalized', 'Position', [0 0.2 1 0.6]);

plot(waktu, arus, 'b-', 'LineWidth', 1.5, 'Color', [1 0 1]); 
mean_cur = mean(arus, 'omitnan');
yline(mean_cur, 'k--', 'LineWidth', 1.5);
text_mean = sprintf('Rata-rata (%.2f m/s)', mean_cur);
axis tight;
set(gca, 'FontSize', 14);
set(gca, 'Color', [0.96 0.94 0.86]);
ylabel('Kecepatan Arus (m/s)', 'FontWeight', 'bold', 'FontSize', 14);
grid on;
xlim([min(waktu) max(waktu)]);
ylim([min(arus) max(arus)]);
lgd = legend('Kecepatan Arus',text_mean, 'Location', 'best');
lgd.Color = 'w';
lgd.FontSize = 11;

exportgraphics(gcf, fullfile(outputFolder, 'current.png'), 'Resolution', 300);
disp('Proses plot Kecepatan Arus selesai.');




%% ================================     ENSO IOD     ==================================

figure('Name', 'Time Series Parameter', 'Units', 'normalized', 'Position', [0 0.2 1 0.6]);

plot(waktu, nino34, 'b-', 'LineWidth', 1.5);hold on;
plot(waktu, dmi, 'r-', 'LineWidth', 1.5);hold on;
yline(0.5, 'r--', 'LineWidth', 1.5); hold on;
yline(-0.5, 'r--', 'LineWidth', 1.5); hold on;
set(gca, 'FontSize', 14);
set(gca, 'Color', [0.96 0.94 0.86]);
ylabel('Index Value', 'FontWeight', 'bold', 'FontSize', 14);
grid on;
xlim([min(waktu) max(waktu)]);
ylim([-2 2.7]);
lgd = legend('Nino 3.4 (ENSO)', 'DMI (IOD)', 'Location', 'southeast');
lgd.Color = 'w';
lgd.FontSize = 11;

posisi_elnino = [0.908 0.52 0.09 0.05]; 
annotation('textbox', posisi_elnino, 'String', 'El Nino / IOD (+)', 'EdgeColor', 'none', ...
    'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center');
posisi_lanina = [0.908 0.35 0.09 0.05]; 
annotation('textbox', posisi_lanina, 'String', 'La Nina / IOD (-)','EdgeColor', 'none', ...
    'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k', ...
    'HorizontalAlignment', 'center');

exportgraphics(gcf, fullfile(outputFolder, 'ensoiod.png'), 'Resolution', 300);
disp('Proses plot ENSO IOD selesai.');
