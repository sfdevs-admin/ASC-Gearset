/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 09-29-2025
 * @last modified by  : Swati Chilap
**/
@IsTest
public class B2B_AddPBEsToAdjustmentBatchTest {
    private static final String PRODUCT_NAME = 'Test Product';
    private static final String PRODUCT_NAME_2 = 'Test Product1';
    @TestSetup
    static void setup() {
        insert new List<PriceAdjustmentSchedule>{
            new PriceAdjustmentSchedule(Name = 'Volume Discount USD'),
            new PriceAdjustmentSchedule(Name = 'Volume Discount Euro')
        };

        B2B_TestDataFactory.createProduct(PRODUCT_NAME,true);
        B2B_TestDataFactory.createProduct(PRODUCT_NAME_2,true);
        
    }

    @isTest
    static void testBatchDirectly() {
        Map<String, String> schedCurrencyMap = new Map<String, String>{
            'Volume Discount USD'  => 'USD',
            'Volume Discount Euro' => 'EUR'
        };

        Id pbId = Test.getStandardPricebookId();

        String queryString = 
            'SELECT Id, CurrencyIsoCode ' +
            'FROM PricebookEntry ' +
            'WHERE Pricebook2Id = \'' + pbId + '\' ' +
            'AND CurrencyIsoCode IN (\'' + String.join(new List<String>(schedCurrencyMap.values()), '\',\'') + '\') ' +
            'AND IsActive = TRUE';

        Test.startTest();
        Database.executeBatch(new B2B_AddPBEsToAdjustmentBatch(schedCurrencyMap, queryString), 50);
        Test.stopTest();

        List<PricebookEntryAdjustment> adjustments = [
            SELECT Id FROM PricebookEntryAdjustment
        ];
        System.assertEquals(2, adjustments.size(), 'Two adjustments should be created for test PBEs.');
    }
}