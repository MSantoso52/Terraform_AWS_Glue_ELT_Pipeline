from pyspark.sql.functions import regexp_replace, col, when, lit, to_timestamp
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'input_bucket', 'output_bucket'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Extract: Read from input S3 (JSON)
input_path = f"s3://{args['input_bucket']}/sales_record.json"
dynamic_frame = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": [input_path]},
    format="json",
    format_options={"multiline": "true"}
)

# Convert to DataFrame for transformations
df = dynamic_frame.toDF()

# Filter: rows where customer_info.age > 18 or age is null
df = df.filter((col("customer_info.age").isNull()) | (col("customer_info.age") > 18))

# Transform: Clean and correct data types
df = df.withColumn("total_price", regexp_replace(col("total_price.string"), "[^0-9.]", "").cast("double"))
df = df.withColumn("quantity", col("quantity.int").cast("int"))
df = df.withColumn("price_per_unit", col("price_per_unit").cast("double"))
df = df.withColumn("customer_info", df.customer_info.withField("age", col("customer_info.age").cast("int")))
df = df.withColumn("order_date", to_timestamp(col("order_date")))

# Handle null or missing values
df = df.withColumn("payment_method", when(col("payment_method").isNull(), lit("Unknown")).otherwise(col("payment_method")))
df = df.withColumn("customer_info", df.customer_info.withField("age", when(col("customer_info.age").isNull(), lit(0)).otherwise(col("customer_info.age"))))

# Remove duplicates based on order_id
df = df.dropDuplicates(subset=["order_id"])

# Add a new column (is_adult as string, explicitly cast to string)
df = df.withColumn("is_adult", lit("True").cast("string"))

# Convert back to DynamicFrame
transformed = DynamicFrame.fromDF(df, glueContext, "transformed")

# Load: Write to output S3 as Parquet
output_path = f"s3://{args['output_bucket']}/transformed_data/"
glueContext.write_dynamic_frame.from_options(
    frame=transformed,
    connection_type="s3",
    connection_options={"path": output_path},
    format="parquet"
)

job.commit()