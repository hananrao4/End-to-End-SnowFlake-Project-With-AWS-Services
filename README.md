📖 Overview

This project builds an automated data pipeline to fetch data from an E-Commerce API, land it in AWS S3, load it into Snowflake using Snowpipe, and transform it into BI-ready tables. Finally, the data is visualized using Power BI or Tableau.

🔄 Architecture Flow

•	E-Commerce API → Source of sales/order/inventory data.

•	AWS Lambda (scheduled by EventBridge) → Calls API at scheduled intervals.

•	S3 Bucket → Stores raw JSON response files.

•	Snowpipe → Automatically ingests data from S3 into Snowflake.

•	Snowflake Raw Tables → Store ingested raw JSON data.

•	Snowflake BI Tables → Transformed and structured tables.

•	Snowflake Task Schedule → Automates refresh/update of Raw and BI tables.

•	Power BI / Tableau → Connects to BI tables for reporting and dashboards.

⚙️ Components

•	AWS Services
•	EventBridge (scheduling API calls)

•	Lambda (fetch API data, push to S3)

•	S3 Bucket (JSON storage)

•	Snowflake

•	Snowpipe (data ingestion from S3 → Snowflake)

•	Raw Tables (API schema-based ingestion)

•	BI Tables (modeled tables for analytics)

•	Tasks (automated refresh of tables)

•	BI Tools

o	Power BI / Tableau
