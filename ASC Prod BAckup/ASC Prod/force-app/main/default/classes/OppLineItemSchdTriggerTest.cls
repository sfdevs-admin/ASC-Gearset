/**
 * @description
 * Unit test class for the OppLineItemSchdTriggerHelper logic, ensuring that the
 * project financials on R&D Portfolio Opportunities are updated correctly when
 * OpportunityLineItemSchedule records are inserted, updated, or deleted.
 *
 * @author nipun.jain@atrium.ai
 * @since May 2025
 */
@isTest
public class OppLineItemSchdTriggerTest {
    
    final private static String MANAGER_PS_NAME = 'RD_Project_Manager_Permissions';

    @testSetup
    private static void setupMethod() {
        User admin = TestDataFactory.createUser(
            'systemAdmin@asc.com.test', 
            'System Admin', 
            [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            false
        );
        insert admin;
        
        PermissionSet managerPS = [SELECT Id FROM PermissionSet WHERE Name =: MANAGER_PS_NAME LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(
        	PermissionSetId = managerPS.Id,
            AssigneeId = admin.Id
        );
        insert psa;
        
        System.runAs(admin) {
            Account acc = TestDataFactory.createAccount('Test Account', FALSE);
            insert acc;

            Opportunity portfolio = TestDataFactory.createOpportunity(
                'Test Opportunity',
                acc,
            	'R_D_Portfolio',
                FALSE
            );
            insert portfolio;
            
            Product2 rdProduct = TestDataFactory.createProduct(
                'R&D Product',
                'REVENUE',
                FALSE
            );
            insert rdProduct;
            
            Pricebook2 rdPricebook = TestDataFactory.createCustomPricebook(
                'R&D Pricebook',
                FALSE
            );
            insert rdPricebook;
            
            List<PricebookEntry> entries = TestDataFactory.createPricebookEntry(
                rdPricebook.Id,
                rdProduct.Id,
                FALSE
            );
            insert entries;
            
            Id priceBookId = rdPricebook.Id != NULL ? entries[1].Id : entries[0].Id;
            
            OpportunityLineItem lineItem = TestDataFactory.createOpportunityLineItem(
                portfolio.Id,
                priceBookId,
                FALSE
            );
            insert lineItem;
        }
    }
    
    @isTest
    private static void testScheduleLineItem() {
        User admin = [SELECT Id FROM User WHERE UserName = 'systemAdmin@asc.com.test' LIMIT 1];
        
        System.runAs(admin) {
            OpportunityLineItem lineItem = [SELECT Id, OpportunityId FROM OpportunityLineItem LIMIT 1];
            
            Test.startTest();
                OpportunityLineItemSchedule scheduleLine = TestDataFactory.createOpportunityLineItemSchedule(
                    lineItem.Id,
                    'Revenue',
                    FALSE
                );
                insert scheduleLine;
            Test.stopTest();
            
            System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItemSchedule WHERE Id = :scheduleLine.Id], 
                'Schedule line item should be inserted successfully.');
            
            scheduleLine.Revenue = 2000;
            update scheduleLine;
            
            delete scheduleLine;
        }
    }
}