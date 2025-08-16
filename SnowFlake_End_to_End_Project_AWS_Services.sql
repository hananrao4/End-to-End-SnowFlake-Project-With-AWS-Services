CREATE OR REPLACE SCHEMA PROJECT_Snowflake;


-------------JSON file Format------------------------------

CREATE OR REPLACE  FILE FORMAT HRMS.PROJECT_Snowflake.Json_File_Format
TYPE=Json

-----------------------------AWS_S3_INT----------------------


CREATE OR REPLACE STORAGE INTEGRATION AWS_S3_INT
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE 
STORAGE_AWS_ROLE_ARN ='arn:aws:iam::276824024614:role/Snow-Flake-Full-Access-S3'
STORAGE_ALLOWED_LOCATIONS = ('s3://data-snowflake-integration/')

------------------CREATE Stage----------------------------------

CREATE OR REPLACE STAGE HRMS.PROJECT_Snowflake.AWS_Json_Stag
STORAGE_INTEGRATION = AWS_S3_INT
URL = 's3://data-snowflake-integration/'
FILE_FORMAT = HRMS.PROJECT_Snowflake.Json_File_Format

DESC INTEGRATION AWS_S3_INT

LIST @AWS_Json_Stag


----------------CREATE TABLE (Json) -----------------------------------

CREATE OR REPLACE Table Json_Data_Table
(
Product_details  VARIANT
);


----------------COPY (data) INTO JSON Table( RAW TABLE)--------------


COPY INTO Json_Data_Table FROM @AWS_Json_Stag
FILES=('product-details.json')



------------------------Snowpipe-----------------------------

CREATE OR REPLACE PIPE PIPE_PROPERTY_SALES
AUTO_INGEST=TRUE
AS
COPY INTO Json_Data_Table FROM @AWS_Json_Stag
FILES=('product-details.json')

---------------------------BI Table-----------------------------------------
CREATE OR REPLACE SCHEMA BI;

CREATE OR REPLACE TABLE HRMS.BI.Iphone11Models (
    ID VARCHAR(20) PRIMARY KEY,
    COLOR VARCHAR(20),
    PRODUCT_GRADE VARCHAR(20),
    SERVICE_PROVIDER VARCHAR(50),
    SIZE VARCHAR(10),
    BRAND VARCHAR(20),
    CPU_MODEL VARCHAR(20),
    MEMORY_STORAGE_CAPACITY VARCHAR(20),
    MODEL_NAME VARCHAR(50),
    Refresh_date date
);



-------------------CREATE TASKs and INSERT data into Json Table-------------------------------------------


CREATE or REPLACE SCHEMA Schedule;

CREATE OR REPLACE TASK TASK_CREATE_TABLE  
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON 6 15 * * * Asia/Riyadh'  -- Every 10 minutes in Saudi time
AS
BEGIN
    
    TRUNCATE TABLE IF EXISTS HRMS.BI.Iphone11Models;

    INSERT INTO HRMS.BI.Iphone11Models
    
    SELECT
    feature.key::string AS ID,
    feature.value:color::string AS Color,
    feature.value:product_grade::string AS Product_Grade,
    feature.value:service_provider::string AS Service_Provider,
    feature.value:size::string AS Size,
    product_details:data:product_details:"Brand"::STRING AS brand,
    product_details:data:product_details:"CPU Model"::STRING AS CPU_Model,
    product_details:data:product_details:"Memory Storage Capacity"::STRING AS Memory_Storage_Capacity,
    product_details:data:product_details:"Model Name"::STRING AS Model_Name,
    CURRENT_DATE as Refresh_date

    
FROM Json_Data_Table,
LATERAL FLATTEN(product_details:data:all_product_variations) AS feature;

END;
