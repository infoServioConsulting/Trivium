global class AccountEnrollmentDataClear implements Database.Batchable<sObject> {

    @InvocableMethod(label = 'Clear Account Enrollment Data' description = 'Clears the Currently Enrolled Family and Enrolled Term fields on Accounts.')
    public static void callBatchUpdate(){
        
        EmailNotification.sendToCurrentUser('Account Enrollment Data Clear Initiated', 
                                            'Class Enrollment data is being removed from Account records. See Apex Jobs in setup for batch detail.');
        
        AccountEnrollmentDataClear batch = new AccountEnrollmentDataClear(); 
        database.executeBatch(batch);
        
        // BEFORE enrollment
        // Update “Currently Enrolled Family” checkbox on the account to FALSE
        // and update “Enrolled Term” field on account to null

        // AFTER enrollment
        // When any student is enrolled, check the “Currently Enrolled Family” checkbox on the account to TRUE
        // and update “Enrolled Term” field on the account to the Class Enrollments → Class Offerings.Term
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Currently_Enrolled_Family__c, ' + 
                                            'Enrolled_Term__c ' +                     
                                            'FROM Account ' +
                                            'WHERE Currently_Enrolled_Family__c = true');
    }

    global void execute(Database.BatchableContext BC, List<Account> accts){
        
        for (Account a : accts) {
            a.Currently_Enrolled_Family__c = false;
            a.Enrolled_Term__c = null;
        }
        
        update accts;
    }

    global void finish(Database.BatchableContext BC){
        
        // Send a completion email if not running a test.
            // Get the ID of the AsyncApexJob representing this batch job
           // from Database.BatchableContext.
           // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];           
        // Send an email to the current user to let them know what's happening
        EmailNotification.sendToCurrentUser('Account Enrollment Data Batch Clear - ' + a.Status, 
                                            'The batch Apex job processed ' + a.TotalJobItems +
             								' batches with '+ a.NumberOfErrors + ' failures.');
    }
}