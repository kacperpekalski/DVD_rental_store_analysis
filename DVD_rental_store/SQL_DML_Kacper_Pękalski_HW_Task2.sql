/*
* 	1. Create table ‘table_to_delete’ and fill it with the following query:
**/


CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x; -- generate_series() creates 10^7 rows of sequential numbers from 1 to 10000000 (10^7)



/*
	2. Lookup how much space this table consumes with the following query:
*/


 SELECT *, pg_size_pretty(total_bytes) AS total,
			pg_size_pretty(index_bytes) AS INDEX,
            pg_size_pretty(toast_bytes) AS toast,
            pg_size_pretty(table_bytes) AS TABLE
FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
		FROM (SELECT c.oid,nspname AS table_schema,
                     relname AS TABLE_NAME,
                     c.reltuples AS row_estimate,
                     pg_total_relation_size(c.oid) AS total_bytes,
                     pg_indexes_size(c.oid) AS index_bytes,
                     pg_total_relation_size(reltoastrelid) AS toast_bytes
              FROM pg_class c
              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
              WHERE relkind = 'r'
              ) a
		) a
WHERE table_name LIKE '%table_to_delete%';


-- TOTAL 575 mb
/*
 * 3. Issue the following DELETE operation on ‘table_to_delete’:
*/


DELETE FROM table_to_delete
               WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0; -- removes 1/3 of all rows

-- it took 11 seconds
-- stil 575 mb
               
VACUUM FULL VERBOSE table_to_delete;
-- "public.table_to_delete": found 1348821 removable, 6666667 nonremovable row versions in 73536 pages

-- now it is 383 mb 

/*
Before the DELETE operation, the table size was 575 MB.
After the DELETE operation, the table size remained the same at 575 MB, indicating that the deleted rows were marked as reusable but not yet reclaimed.
After performing VACUUM FULL, the table size decreased significantly to 383 MB, as the vacuum operation removed removable row versions and reorganized the table, reclaiming disk space.
*/


DROP TABLE IF EXISTS table_to_delete;
CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x; -- generate_series() creates 10^7 rows of sequential numbers from 1 to 10000000 (10^7)


/*
 * 4. Issue the following TRUNCATE operation:
*/

TRUNCATE table_to_delete;

/*
 * it took less than 1 second.

The DELETE operation took 11 seconds to remove approximately one-third of the rows.
After the DELETE operation, the table size remained the same at 575 MB.
However, the VACUUM FULL VERBOSE operation significantly reduced the table size to 383 MB.
In contrast, the TRUNCATE operation took less than 1 second to remove all rows.

TRUNCATE operation is significantly faster than DELETE, especially for large tables.
DELETE operation only marks the rows as deleted, keeping them physically in the table until VACUUM operation.
TRUNCATE operation immediately deallocates all storage associated with the table, resulting in faster removal of all data.

Now it is only 8192 bytes of memory taken.
*/

	

