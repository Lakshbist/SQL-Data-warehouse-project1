/*
   ================================================================================================
   Stored Procedure - Load silver layer (Bronze -> Silver)
   ================================================================================================
   Script Purpose - 
      This stored procedure performs the ETL(Extract, Transform, Load) process to populate the 
      'Silver' schema tables from 'bronze' schema.
    Actions performed - 
       - Truncates silver table 
       - Inserts transformed and cleansed data from bronze into silver tables.

   Parameters:
      None.
      This stored procedure does not accepts any parameters or returns any values.

   Usage Example - Exec silver.load_silver;

*/

create or alter procedure silver.load_silver as 
Begin 
        declare @start_time datetime , @end_time datetime, @batch_starttime datetime,
                @batch_endtime datetime

      Begin Try 
         set @batch_starttime = getdate();
         Print'==============================================================================='
         Print'Loading Silver Layer'
         Print'==============================================================================='

         Print'--------------------------------------------------------------------------------'
         Print'Loading CRM Tables'
         Print'--------------------------------------------------------------------------------'
           
        set @start_time = getdate();
        print '>> Truncating table   : silver.crm_cust_info';
        Truncate table silver.crm_cust_info;

        print '>> Inserting Data into: silver.crm_cust_info';
        insert into silver.crm_cust_info
        (
             cst_id,
             cst_key,
             cst_firstname,
             cst_lastname,
             cst_marital_status,
             cst_gndr,
             cst_create_date
        )
        select 
                cst_id,
                cst_key,
                trim(cst_firstname) as cst_firstname, -- Trimming unwanted spaces
                trim(cst_lastname) as cst_lastname,
        case 
             when upper(trim(cst_marital_status)) = 'S' then 'Single'
             when upper(trim(cst_marital_status)) = 'M' then 'Married'
             else 'n/a'
        end  cst_marital_status,

        case 
             when upper(trim(cst_gndr)) = 'F' then 'Female' --In case of any extra spaces and case difference.
             when upper(trim(cst_gndr)) = 'M' then 'Male' 
             else 'n/a'
        end cst_gndr,
        cst_create_date
        from (
		        select *,
		        row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
		        from bronze.crm_cust_info
        )t
        where flag_last = 1;
        set @end_time = getdate();
        print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' Seconds';
        Print'---------------------------------------------------------------------------------';

        set @start_time = getdate();
        print '>> Truncating table   : silver.CRM_prd_info';
        Truncate table silver.crm_prd_info;

        print '>> Inserting Data into: silver.CRM_prd_info';
        insert into silver.crm_prd_info
        (
              prd_id,
              cat_id,
              prd_key,
              prd_nm,
              prd_cost,
              prd_line,
              prd_start_dt,
              prd_end_dt
        )

        select 
                prd_id,
                replace(substring(prd_key,1,5),'-','_') as cat_id, 
                substring(prd_key,7,len(prd_key)) as prd_key, 
                prd_nm, 
                isnull(prd_cost,0) as prd_cost, 
        case upper(trim(prd_line))
             When 'M' then 'Mountain'
             When 'R' then 'Road'
             When 'S' then 'Other sales'
             When 'T' then 'Touring'
             else 'n/a'
        end  prd_line,
                cast(prd_start_dt as date) as prd_start_dt,
                cast(lead(prd_start_dt) over(partition by prd_key order by prd_start_dt) - 1 as date ) as prd_end_dt
        from bronze.crm_prd_info;
        set @end_time = getdate();
        print'Load duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' Seconds';
        Print'------------------------------------------------------------------------------'

  
        set @start_time = getdate();
        print '>> Truncating table   : silver.crm_sales_details';
        Truncate table silver.crm_sales_details;

        print '>> Inserting Data into: silver.crm_sales_details';
        insert into silver.crm_sales_details 
        (
                sls_ord_num,
                sls_prd_key,
                sls_cust_id,
                sls_ord_dt,
                sls_ship_dt,
                sls_due_dt,
                sls_sales,
                sls_quantity,
                sls_price
        )

        select 
               sls_ord_num,
               sls_prd_key,
               sls_cust_id,
        case 
             when sls_ord_dt = 0 or len(sls_ord_dt) !=8 then NULL
             else cast(cast(sls_ord_dt as varchar) as date)
        end sls_ord_dt,
        case 
             when sls_ship_dt = 0 or len(sls_ship_dt) !=8 then NULL
             else cast(cast(sls_ship_dt as varchar) as date)
        end sls_ship_dt,
        case 
             when sls_due_dt = 0 or len(sls_due_dt) !=8 then NULL
             else cast(cast(sls_due_dt  as varchar) as date)
        end sls_due_dt,
        case 
             when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
             then sls_quantity * sls_price
             else sls_sales
        end sls_sales,
        sls_quantity,
        case 
             when sls_price is null or sls_price <=0 then sls_sales / nullif(sls_quantity,0)
             else sls_price
        end sls_price
        from bronze.crm_sales_details;

        --select * from silver.crm_sales_details
        set @end_time = getdate();
        print'load Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' Seconds';

        Print'-------------------------------------------------------------------------------'
        Print'Loading ERP tables'
        Print'-------------------------------------------------------------------------------'

        set @start_time = getdate();
        -- Clean and Load Bronze.erp_CUST_AZ12
        print '>> Truncating table   : silver.erp_CUST_AZ12';
        Truncate table silver.erp_CUST_AZ12;

        print '>> Inserting Data into: silver.erp_CUST_AZ12';
        Insert into silver.erp_CUST_AZ12
        (    
             CID, 
             Bdate,
             Gen
        )

        select 
        case 
             when cid like 'NAS%' then substring(cid,4,len(cid))
             else cid
        end CID,
        case 
              when bdate > getdate() then null
              else bdate 
        end Bdate,
        case 
             when upper(trim(gen)) in ( 'F','FEMALE') then 'Female'
             when upper(trim(gen)) in ( 'M','MALE') then 'Male'
             else 'n/a'
        end gen
        from bronze.erp_cust_az12;

        set @end_time = getdate();
        print'Load Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' Seconds';
        Print'------------------------------------------------------------------------------'

        
        set @start_time = getdate();
        print '>> Truncating table   : silver.erp_LOC_A101';
        truncate table silver.erp_LOC_A101;

        print '>> Inserting Data into: silver.erp_LOC_A101';
        insert into silver.erp_LOC_A101
        (
                CID,
                cntry
        )
        select  
                replace(CID ,'-','') as CID,
        case 
             when trim(cntry) = 'DE' then 'Germany'
             when trim(cntry) in ('US','USA') then 'United States'
             when cntry is null or trim(cntry) = '' then 'n/a'
             else trim(cntry)
        end cntry
        from bronze.erp_LOC_A101
        set @end_time = getdate();
        Print'Load Duration ' + cast(datediff(Second,@start_time,@end_time) as nvarchar) + ' Seconds';
        Print'------------------------------------------------------------------------------'

        
       set @start_time =getdate();
       print '>> Truncating table   : silver.erp_PX_CAT_G1V2'
       Truncate table silver.erp_PX_CAT_G1V2
          
        print '>> Inserting Data into: silver.erp_PX_CAT_G1V2'
        insert into silver.erp_PX_CAT_G1V2
        (
          ID, 
          CAT,
          subcat,
          Maintenance
        )
        select 
              ID, 
              CAT,
              subcat,
              Maintenance
        from bronze.erp_PX_CAT_G1V2;

        set @end_time = getdate();
        print'Load Duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' Seconds';
        Print'-------------------------------------------------------------------------------'

        set @batch_endtime = getdate();
        Print'Loading silver layer ends here';
        print'Load Duration ' + cast(datediff(second,@batch_starttime,@batch_endtime) as nvarchar) + ' Seconds';

   End try
   begin catch
             print'==========================================================================='
             Print'Error occured during loading bronze layer';
             Print'Error Message' + error_message();
             Print'Error Message'  + cast(error_number() as varchar);
             Print'Error Message'   + cast(error_state() as varchar); 
             print'==========================================================================='
   end catch 
End;
