@isTest
public class EmailNotification_T {
    
    @isTest
    static void testEmailSend(){
        
        String subject = 'Test subject';
        String body = 'Test body';
        
        Test.startTest();
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');
        
        EmailNotification.sendToCurrentUser(subject, body);
        
        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
        Test.stopTest();
        
    }

}