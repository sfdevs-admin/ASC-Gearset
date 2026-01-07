/**-----------------------------------------------------------------------------------------------------
* @description Opportunity Trigger Test
 * @Author Atrium - nipun.jain@atrium.ai
 * @date Feb 2025
------------------------------------------------------------------------------------------------------**/
@isTest
public class OpportunityTriggerTest {

    @isTest
    public static void triggerTestingMethod() {
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User leadChemist = createUser('leadChemist@ascensus.com', 'Assigned Lead Chemist', pf.Id);
        insert leadChemist;
        
        User updatedLeadChemist = createUser('updatedLeadChemist@ascensus.com', 'Updated Lead Chemist', pf.Id);
        insert updatedLeadChemist;

        User testingUser = createUser('testingUser@ascensus.com', 'Testing User', pf.Id);
        insert testingUser;
        
        System.runAs(testingUser) {
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            
            Id oppPortfolioRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('R_D_Portfolio').getRecordTypeId();
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            opp.StageName = 'Stage 0 - Idea';
            opp.Project_Status__c = 'Active';
            opp.AccountId = acc.Id;
            opp.CloseDate = Date.Today().addDays(10);
            opp.Product_Family__c = 'DSBH';
            opp.Industry_Segment__c = 'Life Science';
            opp.Probability = 30;
            opp.Project_NPV__c = 100;
            opp.RecordTypeId = oppPortfolioRecordTypeId;
            opp.Lead_Chemist__c = leadChemist.Id;
            insert opp;

            string manualSharing = Schema.OpportunityShare.RowCause.Manual;
            List<OpportunityShare> opportunityShares = [SELECT Id, UserOrGroupId, OpportunityId
                                                        FROM OpportunityShare
                                                        WHERE
                                                        OpportunityId =: opp.Id AND
                                                        RowCause =: manualSharing AND
                                                        UserOrGroupId =: leadChemist.Id];
            System.assertEquals(1, opportunityShares.size(), 'Lead Chemist should have access to the Opportuntity');
            opp.Lead_Chemist__c = updatedLeadChemist.Id;
            update opp;
        }
    }
    
    private static User createUser(String userName, String lastName, Id profileId) {
        User targetUser = new User();
        targetUser.Username = userName;
        targetUser.Email = userName;
        targetUser.LastName = lastName;
        targetUser.Alias = lastName.left(8);
        targetUser.TimeZoneSidKey = 'America/New_York';
        targetUser.LocaleSidKey = 'en_US';
        targetUser.LanguageLocaleKey = 'en_US';
        targetUser.EmailEncodingKey = 'ISO-8859-1';
        targetUser.ProfileId = profileId;

        return targetUser;
    }

}