public class LotteryProcess {
	//@InvocableVariable(required=true) public String recordId;
    @InvocableMethod(label = 'Run Lottery' description = 'Run the lottery process.')
    public static void RunLottery(List<String> recordId){
        
        // Getting running Term
        List<hed__Term__c> runningTerm = new List<hed__Term__c>();
        runningTerm = [SELECT Id, Lottery_Run__c
                      FROM hed__Term__c
                      WHERE id = :recordId
                      LIMIT 1];
        runningTerm[0].Lottery_Run__c = True;
        update runningTerm;
        
        // Getting associated variables
        List<Account> eligibleFamilies = getEligibleFamilies();
        List<Integer> lotteryPool = generateLotteryPool(eligibleFamilies.size());
        List<Integer> assignedNumbers = new List<Integer>();
        Integer originalSize = eligibleFamilies.size();
        
        //[1,2,3,4] Lottery Numbers
        //[a,b,c,d] Families
        
        Integer randomNumber = 0;
        for(Integer i = 0; i < originalSize; i++){
            
            randomNumber = Integer.valueof(Math.random() * lotteryPool.size());
        	
            eligibleFamilies[i].Lottery_Term__c = runningTerm[0].id;
            eligibleFamilies[i].Lottery_Number__c = lotteryPool[randomNumber];
            eligibleFamilies[i].Lottery_Eligible__c = False;
            
            lotteryPool[randomNumber] = lotteryPool[lotteryPool.size() - 1];
            lotteryPool.remove(lotteryPool.size() - 1);
        }
        update eligibleFamilies;
    }
    
    public static List<Account> getEligibleFamilies(){
        List<Account> eligibleFamilies = new List<Account>();
        eligibleFamilies = [SELECT Id, Lottery_Number__c, Lottery_Eligible__c, Lottery_Term__c 
                            FROM Account
                            WHERE Lottery_Eligible__c = True];
        return eligibleFamilies;
    }
    
    public static List<Integer> generateLotteryPool(Integer numFamilies){
        List<Integer> lotteryPool = new List<Integer>();
        for (Integer i=0; i< numFamilies; i++){
            lotteryPool.add(i+1);
        }
        return lotteryPool;
    }
    
    
}