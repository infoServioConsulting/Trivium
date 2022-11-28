@isTest
public class LotteryProcess_T {
	
    @isTest
    public static void runLotteryTest() {
        Account parentAccount = new Account(Name='Parent Account');
        insert parentAccount;
        
        hed__Term__c testTerm = new hed__Term__c(hed__Account__c = parentAccount.Id);
        insert testTerm;
        
        insert new Account(Name = 'Test1 Household', Lottery_Eligible__c = True);
        insert new Account(Name = 'Test2 Household', Lottery_Eligible__c = True);
        insert new Account(Name = 'Test3 Household', Lottery_Eligible__c = True);
        insert new Account(Name = 'Test4 Household', Lottery_Eligible__c = True);
        insert new Account(Name = 'Test5 Household', Lottery_Eligible__c = True);
        insert new Account(Name = 'Test6 Household', Lottery_Eligible__c = False);
        insert new Account(Name = 'Test7 Household', Lottery_Eligible__c = False);
        insert new Account(Name = 'Test8 Household', Lottery_Eligible__c = False);
        insert new Account(Name = 'Test9 Household', Lottery_Eligible__c = False);
        insert new Account(Name = 'Test10 Household', Lottery_Eligible__c = False);
        
        Integer lotteryNoCt = 0;
        Map<Decimal, String> numberMap = new Map<Decimal, String>();
        
        LotteryProcess.runLottery(new List<String>{('' + testTerm.id)});
        
        List<Account> testAccounts = [SELECT Id, Lottery_Number__c, Lottery_Eligible__c, Lottery_Term__c FROM Account];
        
        for (Account a : testAccounts) {
            if (a.Lottery_Number__c > 0) {
                System.assertEquals(testTerm.id, a.Lottery_Term__c);
                System.assertEquals(false, a.Lottery_Eligible__c);
                
                lotteryNoCt = lotteryNoCt + 1;
                numberMap.put(a.Lottery_Number__c, '');
                
            } else {
                System.assertEquals(null, a.Lottery_Term__c);
            }
        }
        
        System.assertEquals(lotteryNoCt, numberMap.keySet().size());
        
    }
}