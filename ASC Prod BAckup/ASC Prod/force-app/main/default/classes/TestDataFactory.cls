/**
 * @description This class is used to create test data.
 * @author nishant.surana@atrium.ai
 * @date May 2025
 */
@IsTest
public with sharing class TestDataFactory {

    /**
     * @description Creates a user with the specified parameters.
     * @param userName The username of the user.
     * @param lastName The last name of the user.
     * @param profileId The profile ID of the user.
     * @param doInsert Boolean flag to indicate whether to insert the user or not.
     * @return The created User object.
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static User createUser(String userName, String lastName, Id profileId, Boolean doInsert) {
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
        
        if (doInsert) {
            insert targetUser;
        }

        return targetUser;
    }
    
    /**
     * @description Creates a Account with the specified parameters.
     * @param accName The Name of the account.
     * @param doInsert Boolean flag to indicate whether to insert the user or not.
     * @return The created Account object.
     */
    public static Account createAccount(String accName, Boolean doInsert) {
        Account acc = new Account();
        acc.Name = accName;
        
        if (doInsert) {
            insert acc;
        }
        return acc;
    }

    /**
     * @description Creates a Opportunity with the specified parameters.
     * @param oppName The Name of the Opportunity.
     * @param acc The aprent account of the Opportunity.
     * @param recordType Record Type Developername of the Opportunity.
     * @param doInsert Boolean flag to indicate whether to insert the user or not.
     * @return The created Opportunity object.
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')    
    public static Opportunity createOpportunity(
        String oppName, 
        Account acc, 
        String recordType, 
        Boolean doInsert
    ) {
        Id portfolioRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('R_D_Portfolio').getRecordTypeId();
        Id salesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        
        Opportunity opp = new Opportunity();
        opp.Name = oppName;
        opp.StageName = recordType == 'R_D_Portfolio' ? 'Stage 0 - Idea' : 'Universe';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today().addDays(10);
        opp.RecordTypeId = recordType == 'R_D_Portfolio' ? portfolioRecordTypeId : salesRecordTypeId;
        
        if (doInsert) {
            insert opp;
        }
        return opp;

    }

    /**
     * @description Creates a Product2 record.
     * @param productName The name of the product.
     * @param scheduleType Schedule type of the Product (REVENUE or QUANTITY).
     * @param doInsert Boolean flag to indicate whether to insert the product or not.
     * @return The created Product2 object.
     */
    public static Product2 createProduct(String productName, String scheduleType, Boolean doInsert) {
        Product2 prod = new Product2();
        prod.Name = productName;
        prod.IsActive = true;
            
        if(scheduleType == 'REVENUE') {
            prod.CanUseRevenueSchedule = TRUE;
            prod.RevenueScheduleType = 'Divide';
            prod.RevenueInstallmentPeriod = 'Monthly';
            prod.NumberOfRevenueInstallments = 10;
        } 
        /*
         ** NOTE: Since the Quantity scheduling is not enabled in org, so this part is commented.
        else if (scheduleType == 'QUANTITY') {
            prod.CanUseQuantitySchedule = TRUE;
            prod.QuantityScheduleType = 'Divide';
            prod.QuantityInstallmentPeriod = 'Monthly';
            prod.NumberOfQuantityInstallments = 10;
        } 
		*/ 

        if (doInsert) {
            insert prod;
        }
        return prod;
    }
    
    /**
     * @description Creates a custom Pricebook2 record.
     * @param pricebookName The name of the custom price book.
     * @param doInsert Boolean flag to indicate whether to insert the price book or not.
     * @return The created Pricebook2 object.
     */
    public static Pricebook2 createCustomPricebook(String pricebookName, Boolean doInsert) {
        Pricebook2 pb = new Pricebook2(
            Name = pricebookName,
            IsActive = true
        );
        if (doInsert) {
            insert pb;
        }
        return pb;
    }

    /**
     * @description Creates a PricebookEntry for a given Product2 in a specified Pricebook2.
     * @param pricebookId The ID of the Pricebook2 (custom or standard).
     * @param productId The ID of the Product2.
     * @param doInsert Boolean flag to indicate whether to insert the PricebookEntry or not.
     * @return The created PricebookEntry object.
     */
    public static List<PricebookEntry> createPricebookEntry(Id pricebookId, Id productId, Boolean doInsert) {
        
        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = standardPricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        List<PricebookEntry> entries = new List<PricebookEntry>();
        PricebookEntry standarPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = productId,
            UnitPrice = 0.00,
            IsActive = true
        );
        entries.add(standarPricebookEntry);

        if(pricebookId != NULL) {
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = productId,
                UnitPrice = 0.00,
                IsActive = true
            );
            entries.add(pbe);
        }
        
        if (doInsert) {
            insert entries;
        }
        return entries;
    }

    /**
     * @description Creates an Opportunity Line Item with the specified parameters.
     * @param opportunityId The ID of the parent Opportunity.
     * @param pricebookEntryId The ID of an existing PricebookEntry to use. 
     * @param doInsert Boolean flag to indicate whether to insert the opportunity line item or not.
     * @return The created OpportunityLineItem object.
     */
    public static OpportunityLineItem createOpportunityLineItem(Id opportunityId, Id pricebookEntryId, Boolean doInsert) {

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opportunityId,
            PricebookEntryId = pricebookEntryId,
            Quantity = 10,
            UnitPrice = 100,
            ServiceDate = Date.today()
        );
        
        if (doInsert) {
            insert oli;
        }
        return oli;
    }

        /**
     * @description Creates an OpportunityLineItemSchedule record.
     * @param opportunityLineItemId The ID of the parent OpportunityLineItem.
     * @param type The type of schedule ('Revenue' or 'Quantity').
     * @param doInsert Boolean flag to indicate whether to insert the schedule or not.
     * @return The created OpportunityLineItemSchedule object.
     */
    public static OpportunityLineItemSchedule createOpportunityLineItemSchedule(
        Id opportunityLineItemId, 
        String type, 
        Boolean doInsert
    ) {
        OpportunityLineItemSchedule olis = new OpportunityLineItemSchedule();
        olis.OpportunityLineItemId = opportunityLineItemId;
        olis.ScheduleDate = System.today();
        olis.Type = type; 

        if (type == 'Revenue') {
            olis.Revenue = 1000;
        } else if (type == 'Quantity') {
            olis.Quantity = 50;
        }
        
        if (doInsert) {
            insert olis;
        }
        return olis;
    }

}