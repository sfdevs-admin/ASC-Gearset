/**
 * @description This is the test class for the RdPortfolioRedirectController class.
 * @Author Atrium - nipun.jain@atrium.ai
 * @date Mar 2025
 */
@isTest
public class RdPortfolioRedirectControllerTest {

    @isTest
    public static void testRedirectMethod() {
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User testingUser = createUser('testingUser@ascensus.com', 'Testing User', pf.Id);
        insert testingUser;

        System.runAs(testingUser) {        
            String listViewUrl = '/lightning/o/Opportunity/list?filterName=' + System.Label.RDPortfolioOppListView;
            PageReference pgRedirect = RdPortfolioRedirectController.redirect();
            System.assertEquals(listViewUrl, pgRedirect.getUrl(), 'Redirection URL Incorrect');
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