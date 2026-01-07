/**
 * @description     Test class for ATR_oldRDPortfolioWarningBannerCont.
 *                  Validates the logic for fetching an Opportunity related to a given RD Portfolio.
 * @author          nipun.jain@atrium.ai
 * @since           April 2025
 */
@isTest
public class ATR_oldRDPortfolioWarningBannerContTest {

    /**
     * @description     Sets up test data including users, RD Portfolio, Account, and Opportunity 
     *                  for use in test methods.
     */
    @testSetup
    public static void setupMethod() {
        Profile pf = [Select Id from Profile where Name = 'Ascensus Standard User - Minimum Access'];
        User testingUser = createUser('testingUser@ascensus.com', 'Testing User', pf.Id);
        insert testingUser;
        
        PermissionSetGroup psGroup = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'Ascensus_Standard_User_PSG' LIMIT 1];
        
        Test.calculatePermissionSetGroup(psGroup.Id);
        
        PermissionSetAssignment psgAssignment = new PermissionSetAssignment();
        psgAssignment.AssigneeId = testingUser.Id;
        psgAssignment.PermissionSetGroupId = psGroup.Id;
        insert psgAssignment;

        List<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('Legacy_R_D_Portfolio_Read_Access')];
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();

        for (PermissionSet ps: psList) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = testingUser.Id;
            psa.PermissionSetId = ps.Id;
            psaList.add(psa);
        }

        insert psaList;

        // PermissionSet legacyRdPortfolioPS = [SELECT Id FROM PermissionSet WHERE Name = 'Legacy_R_D_Portfolio_Read_Access' LIMIT 1];
        // PermissionSetAssignment psa1 = new PermissionSetAssignment();
        // psa1.AssigneeId = testingUser.Id;
        // psa1.PermissionSetId = legacyRdPortfolioPS.Id;
        // insert psa1;
        
        User leadChemist = createUser('leadChemist@ascensus.com', 'Assigned Lead Chemist', pf.Id);
        insert leadChemist;
                
        System.runAs(testingUser) {
            RD_Portfolio__c portfolio = new RD_Portfolio__c();
            portfolio.Name = 'test project';
            portfolio.Lead_Chemist__c = leadChemist.Id;
            insert portfolio;

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
            opp.Original_RD_Portfolio__c = portfolio.Id;
            insert opp;
        }
    }
    
    /**
     * @description     Tests the getChildOpportunity method to ensure the correct Opportunity 
     *                  is returned for the given RD Portfolio.
     */
    @isTest
    public static void testController() {
        User user = [SELECT Id FROM User WHERE UserName = 'testingUser@ascensus.com' LIMIT 1];
        RD_Portfolio__c portfolio = [SELECT Id FROM RD_Portfolio__c WHERE Name = 'test project' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        System.runAs(user) {
            Opportunity returnedOpp = ATR_oldRDPortfolioWarningBannerCont.getChildOpportunity(portfolio.Id);
            System.assertEquals(returnedOpp.Id, opp.Id, 'Opportunity Id not matching.');
        }
    }
    
    /**
     * @description     Helper method to create a User with provided details.
     * @param           userName   The username (also used for email) of the User.
     * @param           lastName   The last name (and alias base) of the User.
     * @param           profileId  The Profile Id to assign to the User.
     * @return          User       The constructed User instance (not inserted).
     */
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