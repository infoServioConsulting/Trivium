public class SendPDFInvites {
    
    public class Param {
        @InvocableVariable(label='Campaign ID')
        public String campId;
        
        @InvocableVariable(label='Mebmerge Mapping ID')
        public String webmergeMapId;
        
        @InvocableVariable(label='TCS Center Name')
        public String tcsCenterName;
      }
    
    static String context;

    @InvocableMethod(label = 'Send PDF Invites' description = 'Send the invitation documents requiring signatures to the contact.')
    public static void sendInvitations(List<Param> params){
        
        Param param = params[0];
        
        List<CampaignMember> campaignMembers = [SELECT ContactId 
                                                FROM CampaignMember 
                                                WHERE CampaignId = :param.campId
                                                AND TCS_Site_for_Flow__c = :param.tcsCenterName];
        
        List<String> recipientIds = new List<String>();
        
        for (CampaignMember cm : campaignMembers) {
            recipientIds.add(cm.ContactId);
        }
        
        webm.WebmergeGenerator.generateDocumentBatch(
            param.webmergeMapId, 
            recipientIds, 
            'Contact'
        );
    }
}