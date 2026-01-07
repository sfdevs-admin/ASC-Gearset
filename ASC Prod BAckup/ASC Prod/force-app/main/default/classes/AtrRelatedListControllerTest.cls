@isTest
public with sharing class AtrRelatedListControllerTest {

    private static final String MANAGER_PS_NAME = 'RD_Project_Manager_Permissions';
    private static final String USER_PS_NAME = 'RD_Project_User_Permissions';
    
    @testSetup
    private static void setupMethod() {
        
        User standardUser = TestDataFactory.createUser(
            'ascensusStandrd@asc.com.test', 
            'Standard User', 
            [SELECT Id FROM Profile WHERE Name = 'Ascensus Standard User - Minimum Access' LIMIT 1].Id,
            false
        );
        insert standardUser;

        PermissionSetGroup psGroup = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'Ascensus_Standard_User_PSG' LIMIT 1];
        
        Test.calculatePermissionSetGroup(psGroup.Id);
        
        PermissionSetAssignment psgAssignment = new PermissionSetAssignment();
        psgAssignment.AssigneeId = standardUser.Id;
        psgAssignment.PermissionSetGroupId = psGroup.Id;
        insert psgAssignment;

        PermissionSet managerPS = [SELECT Id FROM PermissionSet WHERE Name =: MANAGER_PS_NAME LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(
        	PermissionSetId = managerPS.Id,
            AssigneeId = standardUser.Id
        );
        insert psa;
        
        PermissionSet userPS = [SELECT Id FROM PermissionSet WHERE Name =: USER_PS_NAME LIMIT 1];
        PermissionSetAssignment psaUser = new PermissionSetAssignment(
        	PermissionSetId = userPS.Id,
            AssigneeId = standardUser.Id
        );
        insert psaUser;

        System.runAs(standardUser) {

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

            OpportunityLineItemSchedule scheduleLine = TestDataFactory.createOpportunityLineItemSchedule(
            	lineItem.Id,
                'Revenue',
                FALSE
            );
            insert scheduleLine;

        }
    }

    @isTest
    private static void testControllerMethods() {
        
        User standardUser = [SELECT Id FROM User WHERE Username = 'ascensusStandrd@asc.com.test' LIMIT 1];
        Opportunity portfolio = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        OpportunityLineItem lineItem = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :portfolio.Id LIMIT 1];

        System.runAs(standardUser) {
            // Test getRelatedRecord method
            List<SObject> relatedRecords = AtrRelatedListController.getRelatedRecord(
                'OpportunityLineItemSchedule',
                'Revenue, Description, ScheduleDate',
                'WHERE OpportunityLineItem.OpportunityId = \'' + portfolio.Id + '\' ORDER BY ScheduleDate DESC'
            );
            System.assertEquals(1, relatedRecords.size(), 'Related records should not be empty');


            // Test updateOrDeleteRecord method
            relatedRecords[0].put('Revenue', 1000);
            AtrRelatedListController.updateOrDeleteRecord(relatedRecords, 'UPDATE');
            OpportunityLineItemSchedule updatedRecord = [SELECT Revenue FROM OpportunityLineItemSchedule WHERE Id = :relatedRecords[0].Id];
            System.assertEquals(1000.00, updatedRecord.Revenue, 'Revenue should be updated to 1000.00');

            OpportunityLineItemSchedule schedule = new OpportunityLineItemSchedule(
                OpportunityLineItemId = lineItem.Id,
                Revenue = 5000,
                ScheduleDate = System.today().addDays(30),
                Description = 'Test Schedule',
                Type='Revenue'
            );
            List<OpportunityLineItemSchedule> scheduleToInsert = new List<OpportunityLineItemSchedule>{schedule};
            AtrRelatedListController.establishSchedules(JSON.serialize(scheduleToInsert), true, lineItem.Id);

            AtrRelatedListController.getRDProduct();

            AtrRelatedListController.getScheduleTypes();
            
            List<OpportunityLineItemSchedule> schedules = [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId = :lineItem.Id];
            AtrRelatedListController.updateOrDeleteRecord(new List<SObject>{schedules[0]}, 'DELETE');

            // Test getRelatedLineItems method
            List<OpportunityLineItem> lineItems = AtrRelatedListController.getRelatedLineItems(portfolio.Id);
            System.assertEquals(1, lineItems.size(), 'Line items should not be empty');

            try {
            	AtrRelatedListController.getRelatedRecord('', '', '');
            }   
            catch(Exception ex) {
				System.debug(LOGGINGLEVEL.ERROR, 'FAILING TEST--SUCCESSFULL'+ ex.getMessage());
            }
        }
    }
}