@isTest
public class AccountEnrollmentDataClear_T {
    
    
    
	@isTest
    public static void batchInvokableTest(){
        
        Account pAccount = new Account(Name='Test');
        insert pAccount;
        
        hed__Term__c term = new hed__Term__c();
        term.hed__Account__c = pAccount.Id;
        insert term;
        List<Account> accts = new List<Account>();
        
        for (Integer x = 0; x < 300; x++) {
            Account a = new Account();
            a.Name = 'Test';
            a.Currently_Enrolled_Family__c = true;
            a.Enrolled_Term__c = term.Id;
        }
        
        insert accts;
        
        List<String> ids = new List<String>();
        
        for (Account a : accts) {
            ids.add(a.Id);
        }

        Test.startTest();      
        
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');
        AccountEnrollmentDataClear.callBatchUpdate();
        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
        
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob LIMIT 1];
        
        System.assertNotEquals(null, job);
        
        Test.stopTest();
        
        accts = [SELECT Currently_Enrolled_Family__c, Enrolled_Term__c FROM Account WHERE Id IN :ids];
        
        for (Account a : accts) {
            if ((a.Currently_Enrolled_Family__c == true) || (a.Enrolled_Term__c != null)) {
                System.assert(false, 'Account not cleared');
            }
        }
    }
    
    @isTest
    public static void batchExecuteTest(){
        
        Account pAccount = new Account(Name='Test');
        insert pAccount;
        
        hed__Term__c term = new hed__Term__c();
        term.hed__Account__c = pAccount.Id;
        insert term;   
        
        List<Account> accts = new List<Account>();
        
        for (Integer x = 0; x < 300; x++) {
            Account a = new Account();
            a.Name = 'Test';
            a.Currently_Enrolled_Family__c = true;
            a.Enrolled_Term__c = term.Id;
        }
        
        insert accts;
        
        List<String> ids = new List<String>();
        
        for (Account a : accts) {
            ids.add(a.Id);
        }
        

        Test.startTest();   
        
            System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');
        	AccountEnrollmentDataClear batch = new AccountEnrollmentDataClear(); 
        	Id batchId = Database.executeBatch(batch);
        
            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                                FROM AsyncApexJob Where ID = :batchId];
        
        	System.assertNotEquals(null, job);
        
        Test.stopTest();
        
        accts = [SELECT Currently_Enrolled_Family__c, Enrolled_Term__c FROM Account WHERE Id IN :ids];
        
        for (Account a : accts) {
            if ((a.Currently_Enrolled_Family__c == true) || (a.Enrolled_Term__c != null)) {
                System.assert(false, 'Account not cleared');
            }
        }
    }
}