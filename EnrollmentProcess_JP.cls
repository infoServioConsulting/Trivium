public class EnrollmentProcess_JP {
    
    // new List to store the classes to enroll
    static List<Class_Enrollment__c> classEnrolls = new List<Class_Enrollment__c>();
    
    // new Map to hold the Class Offering info
    static Map<String, Map<String, String>> currentClassOfferings;
    
    @InvocableMethod(label = 'V2 Run Enrollment' description = 'Run the enrollment process. Code refactor by JPier')
    public static void RunEnrollment(List<Id> termIdList){
                
        // Grabs the current term ID from the termIdList passed in.
        Id currentTermId = termIdList[0];
        
        List<hed__Application__c> returningApplications = [SELECT TCS_Learning_Center__c , 
                                                               hed__Term__c,
                                                               hed__Applicant__c,
                                                               Student_Grade_Next_School_Year__c,
                                                               Is_Returning_Family__c
                                                           FROM hed__Application__c
                                                           WHERE hed__Applicant__r.Is_this_student_returning__c IN ( 'Yes', 'Brand New Student' ) 
                                                           AND hed__Term__c = :currentTermId];
        
        List<hed__Application__c> newApplications = [SELECT 
                                                         TCS_Learning_Center__c, 
                                                         hed__Term__c, 
                                                     	 hed__Applicant__c, 
                                                         Student_Grade_Next_School_Year__c, 
                                                         Lottery_Number__c,
                                                         Is_Returning_Family__c
                                                     FROM hed__Application__c
                                                     WHERE Is_Returning_Family__c = false
                                                     AND Lottery_Number__c != null
                                                     AND hed__Term__c = :currentTermId
                                                     ORDER BY Lottery_Number__c ASC];
        
        // get map of class offerings using a compound key
        currentClassOfferings = getCurrentClassOfferings(currentTermId);
        
        // add class enrollment records to the list for returning apps and new apps separately. This ensures they're processed in order.
        createClassEnrolls(returningApplications);
        createClassEnrolls(newApplications);
        
        insert classEnrolls;
    
    }
    
    public static void createClassEnrolls(List<hed__Application__c> allApps) {
		// loop through the returning applications
        for(hed__Application__c a : allApps){
            // compound key is a mashup of TCS Learning Center, Term (id) and Student Grade (next school year)
            String compoundKey = a.TCS_Learning_Center__c + a.hed__Term__c + a.Student_Grade_Next_School_Year__c;
                // Find the class offering record in the currentClassOfferings map
            	Map<String, String> courseInfo = currentClassOfferings.get(compoundKey);
                if (courseInfo != null) {
                    Integer vacancy = Integer.valueOf(courseInfo.get('vacancy'));
                    if (vacancy > 0) {
                        // Admission emails will be handled via list views and campaigns
                        // Might need the parent email on the class enrollment record, could use a formula or 2
                        
                        classEnrolls.add(new Class_Enrollment__c(Class_Offering__c = courseInfo.get('id'), 
                                                                 Student__c = a.hed__Applicant__c,
                                                                 Is_Returning_Family__c = a.Is_Returning_Family__c));
						
                   } else if (vacancy <= 0) {
                       
                        // If availability is met (at capacity)
                        // 	send email that vacancy has been met
                        // 	set "In-Person Learning Not Available" on class enrollment
                        // 	*****Enroll in the online vesion of their course
                        // 	Email to students via Campaign manually
						                        
                        compoundKey = 'Online' + a.hed__Term__c + a.Student_Grade_Next_School_Year__c;
                       	courseInfo = currentClassOfferings.get(compoundKey);
                       
                        classEnrolls.add(new Class_Enrollment__c(Class_Offering__c = courseInfo.get('id'), 
                                                                 Student__c = a.hed__Applicant__c, 
                                                                 Is_Returning_Family__c = a.Is_Returning_Family__c, 
                                                                 In_Person_Learning_Not_Available__c = true));

                      	// Emails manually sent to those that did not get enrolled
                    }
                    currentClassOfferings.put(compoundKey, new Map<String, String>{ 'vacancy' => '' + (vacancy - 1), 'id' => courseInfo.get('id')});
                }
        	}
    }
    
    // create map from class offerings using compound key
    public static Map<String, Map<String, String>> getCurrentClassOfferings(Id currentTermId){
        
        List<Class_Offering__c> classes = [SELECT In_Person_Availability__c, 
                                           TCS_Learning_Center__c,
                                           Term__c, 
                                           Grade_Level__c	
                                           FROM Class_Offering__c 
                                           WHERE Term__c = :currentTermId
                                           AND TCS_Learning_Center__c != null];
        
        Map<String, Map<String, String>> classMap = new Map<String, Map<String, String>>();
        
        for (Class_Offering__c c : classes) {
            String compoundKey = c.TCS_Learning_Center__c + c.Term__c + c.Grade_Level__c;
            classMap.put(compoundKey, new Map<String, String>{ 
                'vacancy' => '' + c.In_Person_Availability__c, 
                'id' => c.Id,
                'Grade_Level__c' => c.Grade_Level__c
                });
        }
        
        return classMap;
    }
}