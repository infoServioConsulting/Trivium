@isTest
public class EnrollmentProcess_JP_T {
    
    @isTest
    public static void RunEnrollmentTest() {
        
        String tcsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TCS Center').getRecordTypeId();
        
        Account physicalLC = new Account(Name='In-Person', RecordTypeId = tcsRecordTypeId);
        Account onlineLC = new Account(Name='Online', RecordTypeId = tcsRecordTypeId);
        insert physicalLC;
        insert onlineLC;
        
        hed__Term__c testTerm = new hed__Term__c(hed__Account__c = physicalLC.Id);
        insert testTerm;
        
        Account returnHH = new Account(Name = 'Returning Household', 
                                       Lottery_Eligible__c = False,
                                       TCS_Learning_Center__c = physicalLC.Id);
        
        Account newHH1 = new Account(Name = 'New Household 1', 
                                   	Lottery_Number__c = 1,
                                    TCS_Learning_Center__c = physicalLC.Id);
        
        Account newHH2 = new Account(Name = 'New Household 2', 
                                   	Lottery_Number__c = 2,
                                    TCS_Learning_Center__c = physicalLC.Id);
        
        insert returnHH;
        insert newHH1;
        insert newHH2;
        
        Contact returnStud = new Contact(FirstName='Returning', 
                                        LastName='Student', 
                                        AccountId=returnHH.Id, 
                                        Is_this_student_returning__c = 'Yes',
                                       	k12kit__Current_Grade_Level__c = 'First Grade',
                                     	Student_Grade_Next_School_Year__c = 'Second Grade');
        
		Contact newStud1 = new Contact(FirstName='New', 
                                     LastName='Student1', 
                                     AccountId=newHH1.Id, 
                                     Is_this_student_returning__c = 'No',
                                     k12kit__Current_Grade_Level__c = 'First Grade',
                                     Student_Grade_Next_School_Year__c = 'Second Grade');
        
		Contact newStud2 = new Contact(FirstName='New', 
                                     LastName='Student2', 
                                     AccountId=newHH2.Id, 
                                     Is_this_student_returning__c = 'No',
                                     k12kit__Current_Grade_Level__c = 'First Grade',
                                     Student_Grade_Next_School_Year__c = 'Second Grade');
        
		insert returnStud;
        insert newStud1;
        insert newStud2;
        
        hed__Application__c returnApp = new hed__Application__c(
            hed__Applicant__c = returnStud.Id,
            hed__Term__c = testTerm.Id,
            Student_Grade_Next_School_Year__c = 'Second Grade'
        );
        
        hed__Application__c newApp1 = new hed__Application__c(
            hed__Applicant__c = newStud1.Id,
            hed__Term__c = testTerm.Id,
            Student_Grade_Next_School_Year__c = 'Second Grade'
        );
        
        hed__Application__c newApp2 = new hed__Application__c(
            hed__Applicant__c = newStud2.Id,
            hed__Term__c = testTerm.Id,
            Student_Grade_Next_School_Year__c = 'Second Grade'
        );
        
        insert returnApp;
        insert newApp1;
        insert newApp2;
        
        Class_Offering__c physicalClass = new Class_Offering__c(
            School_Site__c = physicalLC.Id,
            Capacity__c = 2,
            Term__c = testTerm.Id,
			Grade_Level__c = 'Second Grade'
        );
        
        Class_Offering__c onlineClass = new Class_Offering__c(
            School_Site__c = onlineLC.Id,
            Capacity__c = 5,
            Term__c = testTerm.Id,
			Grade_Level__c = 'Second Grade'
        );
        
        insert physicalClass;
        insert onlineClass;
        
        Test.startTest();

	        EnrollmentProcess_JP.RunEnrollment(new List<Id>{ testTerm.Id });
        
        	List<Class_Offering__c> offerings = [SELECT Id 
                                                     FROM Class_Offering__c 
                                                     WHERE Term__c = :testTerm.Name];
	        
            for (Class_Offering__c o : offerings) {
                if (o.TCS_Learning_Center__c == physicalLC.Name) {
                    System.assertEquals(0, o.In_Person_Availability__c);
                    System.assertEquals(2, o.Enrollment_Counter__c);
                } else if (o.TCS_Learning_Center__c == onlineLC.Name) {
                    System.assertEquals(1, o.Enrollment_Counter__c);
                }
            }   	
        
        Test.stopTest();
    }

}