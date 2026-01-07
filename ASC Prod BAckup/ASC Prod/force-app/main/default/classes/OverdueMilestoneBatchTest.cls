/**
 * @description Test class for OverdueMilesstoneBatch.
 * @Author Atrium - Nipun Jain
 * @date Nov 2024
 */

@isTest
public class OverdueMilestoneBatchTest {
    
    @isTest
    public static void testMethodFirst() {
        User u = createUser(
            'systemAdmin@asc.com.test', 
            'System Admin', 
            [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id
        );
        insert u;
        
        System.runAs(u) {
            List<RD_Portfolio__c> portfolios = new List<RD_Portfolio__c>();
            
            RD_Portfolio__c folio = new RD_Portfolio__c();
            folio.Name = 'test project';
            folio.Lead_Chemist__c = u.Id;
            portfolios.add(folio);
            insert portfolios;
            
            List<Task> tasks = new List<Task>();
            Task firstTask = new Task();
            firstTask.Subject = 'Call';
            firstTask.OwnerId = u.Id;
            firstTask.WhatId = portfolios[0].Id;
            firstTask.ActivityDate = System.today().addDays(-1);
            firstTask.Priority = 'Normal';
            firstTask.Status = 'Open';
            tasks.add(firstTask);
            
            Task secondTask = new Task();
            secondTask.Subject = 'Send Quote';
            secondTask.OwnerId = u.Id;
            secondTask.WhatId = portfolios[0].Id;
            secondTask.ActivityDate = System.today().addDays(-1);
            secondTask.Priority = 'Normal';
            secondTask.Status = 'Open';
            tasks.add(secondTask);
            
            insert tasks;
            Test.startTest();
            OverdueMilestoneBatch batch = new OverdueMilestoneBatch();
            Database.ExecuteBatch(batch);
            Test.stopTest();
            
            RD_Portfolio__c portfolio = [SELECT Id, Overdue_Milestone__c FROM RD_Portfolio__c WHERE Name = 'test project' LIMIT 1];
            System.assertEquals(1, portfolio.Overdue_Milestone__c, 'Overdue Milestone count should be 1');
            
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