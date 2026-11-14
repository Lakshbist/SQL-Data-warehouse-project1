/* 
     ===============================================================================================
     Stored Procedure : Load Bronze layer (Source -> Bronze)
     ===============================================================================================
     Script Purpose:
           This procedure loads data into the 'bronze' schema from external CSv files.
           It performs the following actions - 
           - Truncates the bronze tables before loading data.
           - Uses the 'Bulk Insert' command to load data from csv files to bronze tables.

     Parameters : 
        None.
              This stored procedure does not accepts any parameters or returns any values.  
     Usage Example :
       EXEC bronze.load_bronze;
    =================================================================================================
*/

create or alter procedure bronze.load_bronze as 
begin 
       declare @start_time  datetime, @end_time  datetime,@batch_starttime datetime, 
                                     @batch_endtime datetime
  begin try

       set @batch_starttime = getdate();
       print'==================================================================='
       print'Loading Bronze Layer'
       Print'==================================================================='


       print'------------------------------------------------------------------'
       print'Loading CRM tables'
       print'------------------------------------------------------------------'

       set @start_time = getdate();

        print'>> Truncating table : bronze.crm_cust_info ';
        truncate table bronze.crm_cust_info;

        print'>>inserting data into : bronze.crm_cust_info';
        bulk insert bronze.crm_cust_info
        from 'D:\SQL\CRM_Datasets\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        with 
              (
                   Firstrow = 2, 
                   Fieldterminator = ',',
                   tablock   
              );

        set @end_time = getdate();
        print'Load duration :' + cast(datediff(second,@start_time, @end_time) as nvarchar) + ' seconds';
        print'-----------------------------------------------------------------' 
    
       set @start_time = getdate();

        print '>>Truncating table - bronze.crm_prd_info';
        truncate table bronze.crm_prd_info;
    
        print '>>Inserting data into - bronze.crm_prd_info';
        bulk insert bronze.crm_prd_info
        from 'D:\SQL\CRM_Datasets\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        with 
              (
                   Firstrow = 2,
                   Fieldterminator = ',',
                   tablock   
              );

        set @end_time = getdate()
        print'Load duration : ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' Seconds';
        print'-----------------------------------------------------------------'

   
        set @start_time = getdate();
    
        print'>>Truncating table - bronze.crm_sales_details';
        truncate table bronze.crm_sales_details;
    
        print'>>Inserting into table - bronze.crm_sales_details';
        bulk insert bronze.crm_sales_details
        from 'D:\SQL\CRM_Datasets\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        with 
              (
                   Firstrow = 2, 
                   Fieldterminator = ',',
                   tablock   
              );

        set @end_time = getdate();
        print'Load duration : ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' Seconds';
        print'-----------------------------------------------------------------'

        print'-----------------------------------------------------------------'
        print'Loading ERP tables'
        print'-----------------------------------------------------------------'
    
        set @start_time = getdate();
    
        print'>>Truncating table - bronze.erp_CUST_AZ12';
        truncate table bronze.erp_CUST_AZ12;

        print'>>Inserting into table - bronze.erp_CUST_AZ12';
        bulk insert bronze.erp_CUST_AZ12
        from 'D:\SQL\CRM_Datasets\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        with 
              (
                   Firstrow = 2, 
                   Fieldterminator = ',',
                   tablock   
              );

        set @end_time = getdate();
        print'Load duration : ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' Seconds';
        print'-----------------------------------------------------------------'
    
        set @start_time = getdate();
    
        print'>>Truncating table - bronze.erp_LOC_A101';
        truncate table bronze.erp_LOC_A101;
    
        print'>>Inserting into table - bronze.erp_LOC_A101';
        bulk insert bronze.erp_LOC_A101
        from 'D:\SQL\CRM_Datasets\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        with 
              (
                   Firstrow = 2, 
                   Fieldterminator = ',',
                   tablock   
               );

        set @end_time = getdate();
        print'Load duration : ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' Seconds';
        print'-----------------------------------------------------------------'

        set @start_time = getdate();
    
        print'>>Truncating table - bronze.erp_PX_CAT_G1V2';
        truncate table bronze.erp_PX_CAT_G1V2;
    
        Print '>>Inserting into table - bronze.erp_PX_CAT_G1V2';
        bulk insert bronze.erp_PX_CAT_G1V2
        from 'D:\SQL\CRM_Datasets\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        with 
              (
                   Firstrow = 2, 
                   Fieldterminator = ',', 
                   tablock   
              );

        set @end_time = getdate();
        print 'Load duration : ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'
        print'------------------------------------------------------------------'
    
        
        set @batch_endtime = getdate();
        print'Loading Bronze layer ends here'
        Print'Load Duration :' + cast(datediff(second,@batch_starttime,@batch_endtime) as nvarchar) + ' Seconds'
end try
begin catch
        Print'=================================================================='
        Print'Error occured during loading of bronze layer'
        Print'Error message' + error_message();
        Print'Error message' + cast(error_number() as nvarchar);
        Print'Error message' + cast(Error_state() as nvarchar);
        Print'=================================================================='
end catch 
end;
