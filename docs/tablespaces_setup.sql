SQL> SELECT DBMS_METADATA.GET_DDL('TABLESPACE', tablespace_name) FROM dba_tablespaces;
                                                                                
  CREATE TABLESPACE "SYSTEM" DATAFILE                                           
  '/u01/app/oracle/oradata/ORCL/system01.dbf' SIZE 524288000                    
  AUTOEXTEND ON NEXT 10485760 MAXSIZE 32767M                                    
  LOGGING FORCE LOGGING ONLINE PERMANENT BLOCKSIZE 8192                         
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE DEFAULT                                  
 NOCOMPRESS  SEGMENT SPACE MANAGEMENT MANUAL                                    
   ALTER DATABASE DATAFILE                                                      
  '/u01/app/oracle/oradata/ORCL/system01.dbf' RESIZE 985661440                  
                                                                                
                                                                                
  CREATE TABLESPACE "SYSAUX" DATAFILE                                           
  '/u01/app/oracle/oradata/ORCL/sysaux01.dbf' SIZE 419430400                    
  AUTOEXTEND ON NEXT 10485760 MAXSIZE 32767M                                    
  LOGGING FORCE LOGGING ONLINE PERMANENT BLOCKSIZE 8192                         
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE DEFAULT                                  
 NOCOMPRESS  SEGMENT SPACE MANAGEMENT AUTO                                      
   ALTER DATABASE DATAFILE                                                      
  '/u01/app/oracle/oradata/ORCL/sysaux01.dbf' RESIZE 1426063360                 
                                                                                
                                                                                
  CREATE UNDO TABLESPACE "UNDOTBS1" DATAFILE                                    
  '/u01/app/oracle/oradata/ORCL/undotbs01.dbf' SIZE 26214400                    
  AUTOEXTEND ON NEXT 5242880 MAXSIZE 32767M                                     
  BLOCKSIZE 8192                                                                
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE                                          
   ALTER DATABASE DATAFILE                                                      
  '/u01/app/oracle/oradata/ORCL/undotbs01.dbf' RESIZE 356515840                 
                                                                                
                                                                                
  CREATE TEMPORARY TABLESPACE "TEMP" TEMPFILE                                   
  '/u01/app/oracle/oradata/ORCL/temp01.dbf' SIZE 33554432                       
  AUTOEXTEND ON NEXT 655360 MAXSIZE 32767M                                      
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1048576                                  
                                                                                
                                                                                
  CREATE TABLESPACE "USERS" DATAFILE                                            
  '/u01/app/oracle/oradata/ORCL/users01.dbf' SIZE 5242880                       
  AUTOEXTEND ON NEXT 1310720 MAXSIZE 32767M                                     
  LOGGING ONLINE PERMANENT BLOCKSIZE 8192                                       
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE DEFAULT                                  
 NOCOMPRESS  SEGMENT SPACE MANAGEMENT AUTO                                      
                                                                                
SQL> SPOOL OFF;
