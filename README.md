# Docker Tutorial Using Apache Spark

This tutorial shows how we can create docker images with software dependencies required to test new software. We can easily test different relases and compare functionality or run quick POC's in technology we are testing

**We are simply going to build a docker image using the spark binariesfrom sparks offical binaries releases and install python so we can use pyspark. We will then and then run a quick demo on spark**

Link to the spark binaries can be found here - [Spark Releases](https://archive.apache.org/dist/spark/)

## 1. BUILDING THE IMAGE

### 1.1 Build the docker image
```shell
docker build -t keithleosmith/docker-pyspark:2.4.5 .
```
### 1.1 Push to Docker Hub (OPTIONAL)
```shell
docker login
docker push keithleosmith/docker-pyspark:2.4.5
```

### 1.3 Exec into the image
```shell
docker run -it keithleosmith/docker-pyspark:2.4.5 bash
```

## 2. TESTING SPARK

You should now be inthe linux shell of the spark image you just built or pulled and its time to use spark

### 2.1 PYTHON Open the spark shell 
```shell
cd /opt/spark/bin
./pyspark
```
Run this python spark test
```python
df1 = spark.read.json("file:///opt/spark//examples/src/main/resources/people.json")
df1.printSchema()
df1.show()
# call createOrReplaceTempView first if you want to query this DataFrame via sql
df1.createOrReplaceTempView("people")
df2 = spark.sql("select name, age from people")
df2.show()
#finally
exit()
```

### 2.2 SCALA Open the spark shell 
```shell
cd /opt/spark/bin
./spark-shell
```
Run this spark scala test
```scala
import org.apache.commons.io.IOUtils
import java.net.URL
import org.apache.spark.sql.SparkSession
import java.nio.charset.Charset

//val spark = SparkSessionbuilder().appName("MySparkApp").getOrCreate()
//val sc = spark.sparkContext

val bankText = sc.parallelize(
    IOUtils.toString(
        new URL("https://s3.amazonaws.com/apache-zeppelin/tutorial/bank/bank.csv"),
        Charset.forName("utf8")).split("\n"))

case class Bank(age: Integer, job: String, marital: String, education: String, balance: Integer)

val bank = bankText.map(s => s.split(";")).filter(s => s(0) != "\"age\"").map(
    s => Bank(s(0).toInt, 
            s(1).replaceAll("\"", ""),
            s(2).replaceAll("\"", ""),
            s(3).replaceAll("\"", ""),
            s(5).replaceAll("\"", "").toInt
        )
).toDF()
bank.show()

//Now try using SQL
bank.registerTempTable("bank")
val query = spark.sql("select age, count(1) value from bank  where age < 30  group by age order by age")
query.show()
```

## 3. DEPLYING TO KUBERNETES
to be continued.....