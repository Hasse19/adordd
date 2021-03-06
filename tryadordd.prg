
//2015 AHF - Antonio H. Ferreira <disal.antonio.ferreira@gmail.com>
//check 01_readme.pdf before using adordd
//any application should work by setting these SETS and
//uploading tables

//ATTENTION BESIDES ACCESS ADORDD DOESNT CREATE THE DATABASE

#include "adordd.ch"
#ifndef __XHARBOUR__
#include "hbcompat.ch"  //27.10.15 jose quintas advise
#endif

 FUNCTION Main()
 LOCAL cSql :=""

    RddRegister("ADORDD",1)
    RddSetDefault("ADORDD")

    //index related sets
    SET ADODBF TABLES INDEX LIST TO {  {"TABLE1",{"FIRST","FIRST"} }, {"TABLE2" ,{"CODID","CODID"}} }

    //if engine does not support logical fields indicate tehm here
    //SET ADO TABLES LOGICAL FIELDS LIST TO  { { "TABLE1", { "SOMEFIELD" } }}

    // IF ENGINE DOES NTO SUPPORT PRECCISE INDICATION OF DECIMALS LIKNE MONEY, ETC PUT THEM HERE
    //SET ADO TABLES DECIMAL FIELDS LIST TO  { { "TABLE1", { "SOMEFIELD",4,"ANOTHERFILED", 6 } }}

    // defining numeric field len used in index expressions WITHOUT PRECISE LEN NOTATION IN SQL TABEL
    //SET ADODBF INDEX LIST FIELDTYPE NUMBER TO


    SET ADO TEMPORAY NAMES INDEX LIST TO {"TMP","TEMP"}

    //these should be considered as UDF as they must either be evaluated in clipper way or
    //change the value of the uderlying data
    SET ADO INDEX UDFS TO {"IF","&","SUBSTR","=="}

    //field recno and deleted related sets
    SET ADO DEFAULT RECNO FIELD TO "HBRECNO"

    //only needed for tables with diferent from the default
    //SET ADO FIELDRECNO TABLES LIST TO {{"TABLE1","????"},{"TABLE2","????"}}
    SET ADO DEFAULT DELETED FIELD TO "HBDELETE"

    //only needed for tables with diferent from the default
    //SET ADO FIELDDELETED TABLES LIST TO {{"TABLE1","?????"},{"TABLE2","???"} }

    //LOCK RELATED SETS
    //CONTROL LOCKING IN ADORDD FOR BOTH TABLE AND RECORD DONT PUT FINAL "\"
    //uncomenet a place folder if lock set on
    //SET ADO LOCK CONTROL SHAREPATH TO  "C:\TEMP" RDD TO "DBFCDX"

    SET ADO FORCE LOCK OFF

    //TABLE NAMES RELATED SETS
    //table names with or without path ex. cpath_tablename or tbalename
    //tables must be created or imported with the same set
    SET ADO TABLENAME WITH PATH OFF
    //if this set is on we need a path
    //SET PATH TO "C:\WHATEVER"

    //SET ADO ROOT PATH TO "actual path" INSTEAD OF "uploaded path"

    //COnNECTION RELATED SETS
    //need to include complete path
    SET ADO DEFAULT DATABASE TO "D:\WHATEVER\TESTADORDD.MDB" SERVER TO "ACCESS" ENGINE TO "ACCESS" USER TO "" PASSWORD TO ""

    // FOR BIG TABLES TRY DIFERENT OPTIONS
    SET ADO CACHESIZE TO 50 ASYNC ON ASYNCNOWAIT ON

    //TABLES PRE OPEN WITH RECORDS >= DURING APP INITIALIZATION TO BE VERY FAST DURING RUNTIME
    // AND WITH VALUES OF MASK IN TABLENAME IF DEFINED
    SET ADO PRE OPEN THRESHOLD TO 500 MASK {"ENC"}

    SET AUTOPEN ON //might be OFF if you wish
    SET AUTORDER TO 1 // first index opened can be other

/*
IF YOU WANT TO TEST IT WITH YOUR OWN TABLES COMMENT THE CODE BELOW AND DO:

 hb_AdoUpload( "YOUR DRIVE WITH PATH FINISHING WITH \", "DBFCDX", "ACCESS OR MYSQL OR OTHER", oOverWrite .F. )

AND WRITE YOUR OWN TESTING ROUTINES
*/

//THIS IS AN IDEA IT HAS NOT BEEN TESTED BUT IT SHOULD WORK

   IF !hb_adoRddExistsTable( ,"table1")
      //need to include complete path defaults to SET ADO DEFAULT DATABA
      DbCreate("table1", ;
                                { { "CODID",   "C", 10, 0  },;
                                  { "FIRST",   "C", 30, 0  },;
                                  { "LAST",    "C", 30, 0  },;
                                  { "AGE",     "N",  8, 0  },;
                                  { "HBRECNO", "+", 11, 0  } ,;
                                  { "HBDELETE",  "L", 1,0  } }, "ADORDD" )
    ENDIF
    IF !hb_adoRddExistsTable( ,"table2")
      //need to include complete path defaults to SET ADO DEFAULT DATABA
      DbCreate( "table2", ;
                                { { "CODID",    "C", 10, 0 },;
                                  { "ADDRESS",  "C", 30, 0 },;
                                  { "PHONE",    "C", 30, 0 },;
                                  { "EMAIL",    "C", 100,0 },;
                                  { "HBRECNO",  "+", 11,0  },;
                                  { "HBDELETE",  "L", 1,0  }}, "ADORDD" )

    ENDIF

     SELE 0
     USE table1 ALIAS "TEST1"

     APPEND BLANK
     test1->First   := "HOMER si no Homer"
     test1->Last    := "Simpson"
     test1->Age     := 45
     test1->codid   := "0001"

     APPEND BLANK
     test1->First   := "Lara"
     test1->Last    := "Croft si no"
     test1->Age     := 32
     test1->codid   := "0002"
     test1->(dbcommit())

     SELE 0
     USE table2 ALIAS "TEST2"

     APPEND BLANK
     test2->address := "742 Evergreen Terrace"
     test2->phone   := "01 2920002"
     test2->email   := "homer@homersimpson.com"
     test2->codid   := "0001"

     APPEND BLANK
     test2->address := "Raymond Street"
     test2->phone   := "0039 29933003"
     test2->email   := "lara@laracroft.com"
     test2->codid   := "0002"
     test2->(dbcommit())

     CLOSE ALL


   SELE 0
   USE table1 ALIAS "TEST1"
   SELE 0
   USE table2 ALIAS "TEST2"

   //LOCKING TRIAL
   GOTO 1

   IF DBRLOCK(1)
      MSGINFO("TABLE 2 RECORD 1 LOCKED! START ANOTHER "+;
              "INSTANCE OF APP BEFORE CLOSING THIS MESSAGE"+;
              " CHECK LOCK!")
      UNLOCK

   ELSE
      MSGINFO("TABLE 2 COULD NOT LOCK RECORD 1")

   ENDIF

   GO TOP

   SELE TEST1
   GO TOP
   MSGINFO("BROWSE DEFAULT ORDER TABLE1")
   Browse()

   SELE TEST2
   GO TOP
   MSGINFO("BROWSE DEFAULT ORDER TABLE2")
   Browse()

   SELE TEST1
   SET RELATION TO CODID INTO TEST2
   MSGINFO("SET RELATION TO CODID FROM TABLE1 TO TABLE2")
   GO TOP
   DO WHILE !EOF()
      MSGINFO("Name "+TEST1->FIRST+" Address "+TEST2->ADDRESS)
      DBSKIP()
   ENDDO

   MSGINFO("BROWSE TABLE1")
   BROWSE()

   MSGINFO("CHANGE ORDER CREATE INDEX ON LAST TABLE1")
   INDEX ON LAST TO TMP
   SET INDEX TO TMP

   BROWSE()

   cSql := "CREATE VIEW CONTACTS AS SELECT TABLE1.FIRST, TABLE1.LAST,"+;
           "TABLE1.AGE, TABLE2.ADDRESS, TABLE2.EMAIL, TABLE1.HBRECNO, TABLE1.HBDELETE "+;
           "FROM TABLE1 LEFT OUTER JOIN TABLE2 ON TABLE1.CODID = TABLE2.CODID"
   MSGINFO("RUNING SQL "+cSql)

   TRY
      hb_GetAdoConnection():EXECUTE(cSql)
   CATCH
      ADOSHOWERROR( hb_GetAdoConnection())
   END

   SELE 0
   USE CONTACTS
   MSGINFO("BROWSING VIEW CONTACTS")
   BROWSE()
   INDEX ON ADDRESS TO TMP2
   SET INDEX TO TMP2
   MSGINFO("INDEXED BY ADRESS")
   BROWSE()

   //WORKING DIRECTLY WITH RECORDSET IN ANOTHER AREA
   MSGINFO("GET RECORDSET FOR TABLE TEST1 "+STR(SELECT("TEST1")) )

   oRs := hb_adoRddGetRecordSet(SELECT("TEST1"))

   oRs:close()
   aa := "SELECT * FROM "+hb_adoRddGetTableName( SELECT("TEST1") )+ " WHERE FIRST = 'Lara'"

   MSGINFO("NEW SELECT FOR RECORDSET TEST1 "+AA)
   oRs:open(aa,hb_adoRddGetConnection(SELECT("TEST1")))

   MSGINFO("CURRENT WORKAREA "+ALIAS())

   MSGINFO("BROWSE RECORDSET ALIAS TEST1")
   TEST1->(BROWSE())

   MSGINFO("DOES TABLE1 EXISTS ON DB ?"+CVALTOCHAR(hb_adoRddExistsTable( ,"Table1") ))
   MSGINFO("DOES TABLE3 EXISTS ON DB ?"+CVALTOCHAR(hb_adoRddExistsTable( ,"Table3") ))
   DbCloseAll()

RETURN nil

