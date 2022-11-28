@isTest
public class ContactAccountEnrollmentSync_T {
	@isTest
    public static void callBatchUpdateTest(){

        String tcsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TCS Center').getRecordTypeId();
        
        Account physicalLC = new Account(Name='In-Person', RecordTypeId = tcsRecordTypeId);
        insert physicalLC;
        
        hed__Term__c testTerm = new hed__Term__c(hed__Account__c = physicalLC.Id);
        insert testTerm;
        
        Account returnHH = new Account(Name = 'Returning Household', 
                                       Lottery_Eligible__c = False,
                                       TCS_Learning_Center__c = physicalLC.Id);
        insert returnHH;
        
        Contact returnStud = new Contact(FirstName='Returning', 
                                        LastName='Student', 
                                        AccountId=returnHH.Id, 
                                        Is_this_student_returning__c = 'Yes',
                                       	k12kit__Current_Grade_Level__c = 'First Grade',
                                     	Student_Grade_Next_School_Year__c = 'Second Grade');
        
		insert returnStud;
     
        Class_Offering__c physicalClass = new Class_Offering__c(
            School_Site__c = physicalLC.Id,
            Term__c = testTerm.Id,
			Grade_Level__c = 'Second Grade'
        );
        
        insert physicalClass;
        
        Class_Enrollment__c enrollment = new Class_Enrollment__c(
            Class_Offering__c = physicalClass.id, 
            Student__c = returnStud.Id
        );
        
        insert enrollment;
        
        System.debug(enrollment.id);
        
        Test.startTest();
        
            ContactAccountEnrollmentSync.callBatchUpdate(new List<hed__Term__c>{ testTerm });
            
            Contact con = [SELECT Id, Class_Enrollment__c
                                     FROM Contact
                                     WHERE Id = :returnStud.Id];
            
            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                              TotalJobItems, CreatedBy.Email
                              FROM AsyncApexJob];
        
        Test.stopTest();
        
        System.assertNotEquals(null, job);
        System.assertEquals(enrollment.Id, con.Class_Enrollment__c);        
    }
}