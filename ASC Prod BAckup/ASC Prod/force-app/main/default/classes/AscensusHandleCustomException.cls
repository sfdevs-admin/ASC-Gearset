/**
 * @description       : 
 * @author            : Mradul Maheshwari
 * @group             : 
 * @last modified on  : 17-12-2025
 * @last modified by  : Mradul Maheshwari
**/
public class AscensusHandleCustomException extends Exception {
    
    public static void LogException(Exception e, String category, String subcategory)
    {
        try
        {
            String stackTrace = e.getStackTraceString().substringBefore('\n');
            String className = stackTrace.substringAfter('.').substringBefore('.');	
            String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
                
            //Governer Limit of executingQuery 
            String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
            String DMLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            String DMLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
            String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
          
            //Log information in object
            Ascensus_Custom_Exception__c exc = new Ascensus_Custom_Exception__c();
            exc.Name = e.getTypeName().abbreviate(80);
            exc.Govt_Limit_in_Executing_Code__c = String.format('{0}\n{1}\n{2}\n{3}',new List<string>{QueryLimit, DMLimit,DMLStat,CPUT});
            exc.Exception_Message__c = e.getMessage().abbreviate(32767);
            exc.Exception_Type__c = e.getTypeName().abbreviate(254);
            exc.Line_Number__c = e.getLineNumber();
            exc.Stack_Trace__c = e.getStackTraceString().abbreviate(32767);
            exc.Method_Name__c=methodName;
            exc.ClassName__c=className;
            exc.Category__c = category;
            exc.Sub_Category__c = subcategory;
            database.insert(exc);            
        } 

        finally{
        }            
    } 

    /**
    * @description 
    * @author Mradul Maheshwari | 18-03-2025 
    * @param name 
    * @param exceptionMessage 
    * @param className 
    * @param methodName 
    **/
    public static void createLogErrorRecord(String name , String exceptionMessage , String className , String methodName) {
     
        Ascensus_Custom_Exception__c newErrorRecord = new Ascensus_Custom_Exception__c(
        Exception_Message__c = exceptionMessage,
        Name = name,
        ClassName__c = className ,
            Method_Name__c = methodName
            );
        Database.insert(newErrorRecord, false);
    }


    public static void LogCustomException(Exception e, Map<String, Object> inputParams, String category, String subcategory)
    {
        try
        {
            String stackTrace = e.getStackTraceString().substringBefore('\n');
            String className = stackTrace.substringAfter('.').substringBefore('.');	
            String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
                
            //Governer Limit of executingQuery 
            String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
            String DMLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            String DMLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
            String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
          
            //Log information in object
            Ascensus_Custom_Exception__c exc = new Ascensus_Custom_Exception__c();
            exc.Name = e.getTypeName().abbreviate(80);
            exc.Govt_Limit_in_Executing_Code__c = String.format('{0}\n{1}\n{2}\n{3}',new List<string>{QueryLimit, DMLimit,DMLStat,CPUT});
            exc.Exception_Message__c = e.getMessage().abbreviate(32767);
            exc.Exception_Type__c = e.getTypeName().abbreviate(254);
            exc.Line_Number__c = e.getLineNumber();
            exc.Stack_Trace__c = e.getStackTraceString().abbreviate(32767);
            exc.Method_Name__c=methodName;
            exc.ClassName__c=className;
            exc.Category__c = category;
            exc.Sub_Category__c = subcategory;

            if (inputParams != null && !inputParams.isEmpty()) {
                exc.B2B_Input_Parameter__c = JSON.serializePretty(inputParams).abbreviate(32767);
            }

            database.insert(exc);
        } 
        
        finally{
        }            
    } 
    
    
}