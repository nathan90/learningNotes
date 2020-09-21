# [Apache Nifi Crash Course](https://www.youtube.com/watch?v=fblkgr1PJ0o)

## What is DataFlow
* Data flow is moving some content from A to B
* Content could be any bytes
  * Logs
  * HTTP
  * XML
  * CSV
  * Images
  * Video
  * Telemetry - Information from sensors

* Producers can be anything that produces the above set of data
* Consumers can be a *User*, *Storage*, *System* and other things
* Connecting data points is easy. It is simple enough to write a process like bash script, Ruby or Python, SQL procedure etc
* Log Files ->  SQL-> Big Data
* The issue is this doesnt scale. Example use case
  * https://www.slideshare.net/LevBrailovskiy/data-ingestion-and-distribution-with-apache-nifi
  * AOL Data Processing
  * AWS -> HDFS
  * 20TB injested/day

### Dataflow Challenges in 3 Categories
| Data                  | Infrastructure          |  People                     |
|-----------------------|-------------------------|-----------------------------|
| Standards             | "Exactly once" delivery | Compliance                  |
| Formats               | Ensuring Security       | "That [person] team [group] |
| Protocols             | Overcoming Security     | Consumers Change             |
| Veracity              | Credential Management   | Requirements Change         |
| Validity              | Network                 | "Exactly Once" Delivery     |
| Schemas               |                         |                             |
| Partitioning/Bundling |                         |                             |

## What is NiFi
NiFi is based on Flow Based Programming
| FBP Term           | NiFi Term          | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|--------------------|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Information Packet | FlowFile           | Each Object moving through the system. It is the atomic unit of data                                                                                                                                                                                                                                                                                                                                                                                                 |
| Black Box          | FlowFile Processor | Performs the work, doing some combination of data routing, transformation, or mediation between systems.  It is the component that is dragged on to the canvas and perfoms some operation. It could be reading from a file from a local system, calling HTTTP connection and getting a response,  writing to Solr, Reading from HDFS etc. Each one performs a very particular function and does it well,  doesn't worry about outside integrations and interactions |
| Bounded Buffer     | Connection         | The linkage between processors, acting as queues and allowing various processes to interact at differing rates.                                                                                                                                                                                                                                                                                                                                                      |
| Scheduler          | Flow Controller    | Maintains the knowledge of how processes are connected, and manages the threads and allocations thereof which all processes use.                                                                                                                                                                                                                                                                                                                                     |
| Subnet             | Process Group      | A set of processes and their connections, which can send and receive data via ports. A process group allows creation of entirely new component simply by composition of its components.                                                                                                                                                                                                                                                                              |
---
### NiFi Key Features
* Guaranteed Delivery - If a source go out and when it comes back online, the data is brought in again. If the destination goes out, we can queue the data up, save it to a local buffer, store it, set it somewhere else, multiple parallel paths to ensure that the data gets where it needs to go and can track it as well
  * Data buffering
  * Backpressure
* Pressure Release
* Prioritized queuing - Prioritize the flow files that are in any given queue at any given time
* Flow Specific QoS
  * Latency vs. Throughput
  * Loss Tolerance
* Data Provenance
* Supports push and pull models
* Recovering/ recording a rolling log of fine-grained history
* Visual command and control
* Flow templates
* Pluggable, multi-tenant security
* Designed for extension
* Clustering

Flow Files are like HTTP Data. It have a **Header** and a **Content**. Header contains key value attributes. These are small and stord in memory most of the time and have immediate access.  

Content could be anything( blank, a Movie etc) and moves through the system with the Flow Files as well. To prevent duplication since it is essentially the same byte, we write it to a content repository, ie a write ahead log. It is also a copy on write log. The data is saved once and a pointer moves with the flow file. If you modify the data ie change format, change encoding then the data is copied and have reference to new data moving through the system. We can trace back to see what the original data looked like. At every step of the operation we can see what the data looked like, and have a time stamp associated with it

NiFi has a deep Ecosystem Integration. 260+ processors, 48 controller services

### Extension / Integration Points

| NiFi Term           | Description                                                                     |
|---------------------|---------------------------------------------------------------------------------|
| Flow File Processor | Push Pull behavior. Custom UI                                                   |
| Reporting Task      | Used to push data from NiFi to some external services(metrics, provenance, etc) |
| Controller Service  | Used to enable reusable components/shared devices throughout the flow           |
| REST API            | Allows external clients to connect to pull information, change behavior, etc    |
---

### NiFi Architecture

![NiFi Architecture](/img/nifiarch.png)

We have **JVM**, it runs a single web server, that's embedded jetty. Outside of jetty, there is the **Flow Controller**. Scheduling and processing overarching systems for NiFi.  
Within the flow controller there are n many processors deployed. It could be a simple flow with 5 processors, or enterprise flows with 10000 processors. Ideally should be organized with process groups

FlowFile repository tracks all of the flow files as they move through the system. It is a very fast repository implementation system. It allows rapid read and write because it needs to have all those flow files available in memory

The content repository can be a little bit slower depending on configuration, It is also a more robust repository. Much larger pieces of data is stored. eg large video files, csv files. Can be few bytes to TB

The provenance repository stores the provenance metadata

In the cluster setup ideally we should have only 9 to 10 nodes. The communication between the Cluster nodes because the data is flowing so frequently between them is really maximized with single digit sized clusters

The nodes in the cluster can be incredibly robust, GB to TBs of RAM on a node and TBs to PB of storage availabe to the node. You want to maximize individual performance of a node and put into a small cluster to weak nodes and large cluster

**Zero Master Cluster Model**  
There is no single node controller master, what we have is any arbitrary node can be elected as the primary node and its the cluster co ordinator and we can separate those roles if needed ie we could have a 5 node cluster and 1 one is the primary node and 1 is the cluster coordinator. If a primary node goes down another one can come into its place

![NiFi Architecture](/img/nifirepo.png)
* In the above case data is not moved, pointers are moved
* Above case is a routeOnAttribute processor
* In the flowfile repository FlowFile1 F<sub>1</sub> is pointing to C<sub>1</sub>
* In the content repository only Content1 C<sub>1</sub>
* In the provenance repository we have provenance record  P<sub>1</sub> pointing to F<sub>1</sub>
* After it goes through RouteOnAttribute Processor. It looks at some attribute in the flowfile and send it to many other directions. It is going to perform some kind of routing action based on the content or presence of an attribute
* Once that happened, in the flowfile repository we now have two flow files F<sub>1</sub> and F<sub>2</sub>. There are two records that are stored in the repository, they both point to the same content resource claim C<sub>1</sub>
* We have now 3 provenance records. We had the provenance record before it went through the processor, now we have 2 more that flow file was sent through the processor and now it was routed to one relationship and a clone of that was routed to another relationship

![NiFi Architecture](/img/nificopy.png)
* The above is a case of encryptContent processor
* This processor takes the content of an incoming flowfile and encrypt it with some algorithm, and then write the output to the content of the flowfile coming out of the the relationship
* We have two relationships coming out success and failure
* Failure is actually looping back to the same processor. So that could be because of resource issue, unavailability of threads etc
* After processor completes execution the in the flowfile repository F<sub>1</sub> is crossed out because we modified that data, we have a new flowfile called F<sub>1.1</sub> pointing to content2 C<sub>2</sub>
* Content repository have C<sub>1</sub> and C<sub>2</sub>

![Provenance](/img/provenance.png)

### Record Parsing
* Previously, data had to be divided into individual flowfiles to perform work
* CSV output with 50k lines would need to split, operated on, remerged
* 1 + 50k + 50k + 1 flowfiles = 100k flowfiles
* This was not efficient
* With the introduction of Record Parsing processor now flowfile content can contain many "record" elements
* Read and write with **Reader* and **Writer* Controller Services
* Perform lookups, routing, conversion SQL queries, validation, and more...
* 1 + 1 flowfiles = 2 flowfiles

### Encrypted Provenance Repository

Everything in NiFi is extensible. If you have custom requirements ie need to change the way something happens, almost all of that can be done out of the box. 

* Every provenance event recorded is encrypted with AES G/CM before being persisted to disk
* Decrypted on deserialization for retrieval/query
* Random access via offset seek
* Handling key migration and rotation