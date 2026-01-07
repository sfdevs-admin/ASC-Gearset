/**
 * @description Test class for Task Trigger.
 * @Author Atrium - Nipun Jain
 * @date Nov 2024
 */

@isTest
public class TaskTriggerTest {

    @isTest
    /**
     * @description Test method to test the task trigger.
     */
    public static void testMethodFirst() {
        User u = createUser(
            'systemAdmin@asc.com.test', 
            'System Admin', 
            [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id
        );
        insert u;

        System.runAs(u) {
            
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
            insert opp;
            
            List<RD_Portfolio__c> portfolios = new List<RD_Portfolio__c>();

            RD_Portfolio__c folio = new RD_Portfolio__c();
            folio.Name = 'test project';
            folio.Lead_Chemist__c = u.Id;
            folio.Project_NPV__c = 100;
            portfolios.add(folio);
            insert portfolios;

            List<Task> tasks = new List<Task>();
            Task firstTask = new Task();
            firstTask.Subject = 'Call';
            firstTask.OwnerId = u.Id;
            firstTask.ActivityDate = System.today().addDays(1);
            firstTask.Priority = 'Normal';
            firstTask.Status = 'Open';
            firstTask.WhatId = portfolios[0].Id;
            tasks.add(firstTask);

            Task secondTask = new Task();
            secondTask.Subject = 'Call';
            secondTask.OwnerId = u.Id;
            secondTask.ActivityDate = System.today().addDays(1);
            secondTask.Priority = 'Normal';
            secondTask.Status = 'Completed';
            secondTask.WhatId = portfolios[0].Id;
            tasks.add(secondTask);
            
            Task thirdTask = new Task();
            thirdTask.Subject = 'Call Opp';
            thirdTask.OwnerId = u.Id;
            thirdTask.ActivityDate = System.today().addDays(1);
            thirdTask.Priority = 'Normal';
            thirdTask.Status = 'Open';
            thirdTask.WhatId = opp.Id;
            tasks.add(thirdTask);

            insert tasks;

            RD_Portfolio__c portfolio = [SELECT Id, Open_Milestone__c FROM RD_Portfolio__c WHERE Name = 'test project' LIMIT 1];
            System.assertEquals(1, portfolio.Open_Milestone__c, 'Open Milestone count should be 1');

            tasks[0].status = 'Completed';
            tasks[1].status = 'Open';
            update tasks;

            delete tasks;
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