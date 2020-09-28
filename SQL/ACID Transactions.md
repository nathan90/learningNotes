## [Relational Database ACID Transactions](https://www.youtube.com/watch?v=pomxJOFVcQs)

**Transaction** is a collection of queries. These queries form one Unit of Work.  
eg: Account Deposit will have a sequence of queries(SELECT, UPDATE, UPDATE). We will decide how many queries form a transaction or not, when to begin or to end transaction.  
Commit and rollback are part of the transaction.  

Example of a transaction for a account
| Account_ID | Balance |
|------------|---------|
| 1          | $900    |
| 2          | $600    |

Send $100 from account 1 to account 2  
    
```SQL
BEGIN TX1
SELECT Balance FROM account WHERE Account_ID = 1
UPDATE account SET Balance = Balance - 100 WHERE Account_ID = 1
UPDATE account SET Balance = Balance + 100 WHERE Account_ID = 2
COMMIT TX1
```

### **Atomicity**
A transaction should be atomic. All queries must succeed. If one fails all should roll back  
For example in the above transaction if after one update statement the server fails, the money will be debit from one account but not credited in the next account.  
If the transaction is atomic it will roll back all the queries if one query failed.  

### **Consistency**
There are two types of consistency
* Consistency in data
    * Defined by the user
    * Referential Integrity (foreign keys)
    * Atomicity 
    * Isolation   
* Consistency in reads
  * If a transaction committed a change, will a new transaction immediately see the change? We need to add mutliple replicas for horizontal scalability.
  * The moment you add read replicas, followers and leader nodes, the system becomes inconsistent. Writes only to primary node, secondary nodes will get after some time only
  * Relational and NoSQL databases suffer from this
  * Eventual Consistency
  * [Look into Vitess](https://vitess.io/)
  * NoSQL databases gave up consistency for scalabilty

### **Isolation**
* For a transaction to be isolated, can my in flight transaction see changes made by other transactions?
* Read phenomena
* Isolation Levels

**Isolation levels** are implemented by database to get rid of the **Read Phenomena**

#### Isolation Read Phenomena
* Dirty reads
* Non-repeatable reads 
* Phantom reads
* Lost Updates

Isolation Levels for Inflight transactions
* **Read uncommitted**
    * No isolation, any change from outside visible to the transaction.
    * When transaction is started in a read uncommitted way is not going to perform any isolation. Any external changes happening to the database is going to be visible in the transaction.
    * We will get Dirty reads, phantom reads, non-repeatable reads etc
* **Read committed**
    * Each query in a transaction only sees the committed stuff.
    * Each query sees the committed stuff at the time of the query.
* **Repeatable read**
    * Each query in a transaction only sees the committed updates at the beginning of transaction.
* **Serializable**
    * Transactions are serialized.
    * Locks and shared locks are used

### **Durability**
* Committed transactions must be persisted in a durable non-volatile storage. Redis Memcached are not durable databases
