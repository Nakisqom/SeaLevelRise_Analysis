clear; clc;

fil_nc = 'altimetry.nc';
fil_csv = 'altimetry.csv';

time_raw = ncread(fil_nc, 'time');
time_dt = datetime(1970, 1, 1) + seconds(time_raw);

sla_raw = squeeze(ncread(fil_nc,'sla'));
sla_ts = squeeze(mean(sla_raw, [1 2], 'omitnan'));

table_sla = table(time_dt(:), sla_ts(:), 'VariableNames',{'Time', 'sla'});
writetable(table_sla, fil_csv);

fprintf('Succes', fil_csv);