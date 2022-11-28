@isTest
public class SendPDFInvites_T {
	@isTest
    private static void sendInvitationsTest(){
        
        Id recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TCS Center').getRecordTypeId();
        
        webm__Webmerge_Document__c newDoc = new webm__Webmerge_Document__c();
        insert newDoc;
        
        Account newAcct1 = new Account(Name = 'Household');
        insert newAcct1;
        
        Account newAcct2 = new Account(Name = 'Online', RecordTypeId = recordType);
        insert newAcct2;
        
        Contact newCon = new Contact(FirstName = 'Test', LastName = 'Contact',
                                     Email = 'test@gmail.com',
                                     AccountId = newAcct1.Id,
                                     Enrollment_Learning_Center__c = newAcct2.Id);
        insert newCon;
        
        newAcct1.hed__Primary_Contact__c = newCon.Id;
        
        update newAcct1;
        
        Campaign newCampaign = new Campaign(Name = 'Test Campaign');
        insert newCampaign;
        
        CampaignMember newMem = new CampaignMember(CampaignId = newCampaign.Id, 
                                                   ContactId = newCon.Id);
        
        webm__Webmerge_Mapping__c newMap = new webm__Webmerge_Mapping__c(webm__Webmerge_Document_Id__c = newDoc.Id, 
                                                                         webm__Salesforce_Object_Name__c = 'Contact');
        insert newMap;        
        
        SendPDFInvites.Param param = new SendPDFInvites.Param();
        
        param.campId = newCampaign.Id;
        param.webmergeMapId = newMap.Id;
        param.tcsCenterName = 'Online';
        
        SendPDFInvites.sendInvitations(new List<SendPDFInvites.Param>{ param });

    }
}