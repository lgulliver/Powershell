# admin namespace
gwmi -query 'select * from MSReportServer_ConfigurationSetting' -namespace root\Microsoft\SqlServer\ReportServer\v9\Admin
gwmi -query 'select * from MSReportManager_ConfigurationSetting' -namespace root\Microsoft\SqlServer\ReportServer\v9\Admin

# normal namespace
gwmi -query 'select * from MSReportServer_Instance' -namespace root\Microsoft\SqlServer\ReportServer\v9
gwmi -query 'select * from MSReportManager_Instance' -namespace root\Microsoft\SqlServer\ReportServer\v9

