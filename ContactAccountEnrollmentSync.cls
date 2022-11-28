global class ContactAccountEnrollmentSync implements Database.Batchable<sObject> {
    
    @InvocableMethod(label = 'Update Contacts and Accounts with Enrollment Data' description = 'Overwrites Contact fields with data from Class Enrollment records.')
    public static void callBatchUpdate(List<hed__Term__c> termList){
        if (!Test.isRunningTest()) {
            // Get the ID of the AsyncApexJob representing this batch job
           // from Database.BatchableContext.
           // Send an email to the Apex job's submitter notifying of job completion.
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           String[] toAddresses = new String[] { userInfo.getUserEmail() };
           mail.setToAddresses(toAddresses);
           mail.setSubject('Class Enrollment Account & Contact Sync Batch Updates Initiated');
           mail.setPlainTextBody
           ('Contact & Account data is being synced with Class Enrollment records. See Apex Jobs in setup for batch detail.');
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        String currentTermName = termList[0].Name;
        String currentTermId = termList[0].Id;
        
        ContactAccountEnrollmentSync batch = new ContactAccountEnrollmentSync(currentTermName, currentTermId); 
        database.executeBatch(batch);
        
        // BEFORE enrollment
        // Update “Currently Enrolled Family” checkbox on the account to FALSE
        // and update “Enrolled Term” field on account to null

        // AFTER enrollment
        // When any student is enrolled, check the “Currently Enrolled Family” checkbox on the account to TRUE
        // and update “Enrolled Term” field on the account to the Class Enrollments → Class Offerings.Term

    }
    
    private String termName;
    private String termId;   
    
    public ContactAccountEnrollmentSync(String termNameParam, String termIdParam) {
        termName = termNameParam;
        termId = termIdParam;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Offering_Grade_Level__c, ' + 
                                            'I_Accept_Online_Learning__c, ' +
                                            'In_Person_Learning_Not_Available__c, ' +
                                            'Is_Returning_Family__c, ' +
                                            'Class_Offering__r.School_Site__c, ' +
                                            'Term__c, ' +
                                            'Student__c, ' +
                                            'Student_Account_ID_for_Apex__c ' +                       
                                            'FROM Class_Enrollment__c ' +
                                            'WHERE Term__c = \'' + termName + '\'');
    }

    global void execute(Database.BatchableContext BC, List<Class_Enrollment__c> enrollments){
            
        Map<String, String> accountMap = new Map<String, String>();
		List<Account> accountsToUpdate = new List<Account>();
		List<Contact> contactsToUpdate = new List<Contact>();


        for(Class_Enrollment__c e : enrollments){
            accountMap.put(e.Student_Account_ID_for_Apex__c, '');
            
            contactsToUpdate.add(new Contact(
                Id = e.Student__c,
                Class_Enrollment__c = e.Id,
                Grade__c = e.Offering_Grade_Level__c,
                I_Accept_Online_Learning__c = e.I_Accept_Online_Learning__c,
                Is_this_student_returning__c = null,
                In_Person_Learning_Not_Available__c = e.In_Person_Learning_Not_Available__c,
                Enrollment_Learning_Center__c = e.Class_Offering__r.School_Site__c,
                Term__c = e.Term__c
            ));
        }
        
        for (String acctId : accountMap.keySet()) {
            accountsToUpdate.add(new Account(
                Id = acctId,
                Currently_Enrolled_Family__c = true,
                Enrolled_Term__c = termId
            ));
        }
        
        update accountsToUpdate;
        update contactsToUpdate;
    }

    global void finish(Database.BatchableContext BC){
    // Send a completion email if not running a test.
        if (!Test.isRunningTest()) {
            // Get the ID of the AsyncApexJob representing this batch job
           // from Database.BatchableContext.
           // Query the AsyncApexJob object to retrieve the current job's information.
           AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
              TotalJobItems, CreatedBy.Email
              FROM AsyncApexJob WHERE Id =
              :BC.getJobId()];
           // Send an email to the Apex job's submitter notifying of job completion.
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           String[] toAddresses = new String[] { userInfo.getUserEmail() };
           mail.setToAddresses(toAddresses);
           mail.setSubject('Class Enrollment & Contact Sync Batch Updates ' + a.Status);
           mail.setPlainTextBody
           ('The batch Apex job processed ' + a.TotalJobItems +
           ' batches with '+ a.NumberOfErrors + ' failures.');
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
}