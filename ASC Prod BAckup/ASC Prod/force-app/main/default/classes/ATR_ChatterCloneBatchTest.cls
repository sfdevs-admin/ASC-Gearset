@isTest
public class ATR_ChatterCloneBatchTest {

    @testSetup
    public static void setupMethod() {
        
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User testingUser = createUser('testingUser@ascensus.com', 'Testing User', pf.Id);
        insert testingUser;
        
        User leadChemist = createUser('leadChemist@ascensus.com', 'Assigned Lead Chemist', pf.Id);
        insert leadChemist;

        System.runAs(testingUser) {
            RD_Portfolio__c portfolio = new RD_Portfolio__c();
            portfolio.Name = 'test project';
            portfolio.Lead_Chemist__c = leadChemist.Id;
            insert portfolio;
            
            FeedItem feed = new FeedItem();
            feed.ParentId = portfolio.Id;
            feed.Body = 'Test Body';
            feed.Title = 'Test Title';
            feed.IsRichText = TRUE;
			insert feed;
            
            FeedComment comment = new FeedComment();
            comment.FeedItemId = feed.Id;
            comment.CommentBody = 'Test Comment Body';
            comment.IsRichText = TRUE;
            insert comment;


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
    
    @isTest
    public static void batchTestMethod() {
        User testingUser = [SELECT Id FROM User WHERE UserName = 'testingUser@ascensus.com' LIMIT 1];
        RD_Portfolio__c portfolio = [SELECT Id FROM RD_Portfolio__c WHERE Name = 'test project' LIMIT 1];
        FeedItem feed = [SELECT Id, Body FROM FeedItem WHERE ParentId =: portfolio.Id];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Original_RD_Portfolio__c =: portfolio.Id];
        System.runAs(testingUser) {
            Test.startTest();
            ATR_ChatterCloneBatch cloningBatch = new ATR_ChatterCloneBatch();
            Database.executeBatch(cloningBatch);
            Test.stopTest();
            FeedItem clonedFeed = [SELECT Id, Body FROM FeedItem WHERE ParentId =: opp.Id];
            System.assertEquals(feed.Body, clonedFeed.Body, 'Feed not cloned properly');
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