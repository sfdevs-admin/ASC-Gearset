/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 09-29-2025
 * @last modified by  : Swati Chilap
 * @TestClass         : B2B_AddPBEsToAdjustmentScheduleTest
**/
global class B2B_AddPBEsToAdjustmentSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Integer batchSize = Integer.valueOf(System.Label.B2B_Batch_Size);

        Map<String, String> scheduleCurrencyMap = new Map<String, String>{
            'Volume Discount USD'  => 'USD',
            'Volume Discount Euro' => 'EUR'
        };

        List<String> priceBookIds = new List<String>();
        List<String> priceBookNames = new List<String>();
        // label stores comma-separated names
        if (String.isNotBlank(System.Label.B2B_PriceBook_Names)) {
            priceBookNames = System.Label.B2B_PriceBook_Names.split(',');
        }

        if(!Test.isRunningTest()){
            for (Pricebook2 pb : [SELECT Id FROM Pricebook2 WHERE Name IN :priceBookNames AND IsActive = true]) {
                priceBookIds.add(pb.Id);
            }
        } else {
            priceBookIds.add(Test.getStandardPricebookId());
        }
        String queryString = 
            'SELECT Id, CurrencyIsoCode ' +
            'FROM PricebookEntry ' +
            'WHERE Pricebook2Id IN (\'' + String.join(new List<String>(priceBookIds), '\',\'') + '\') ' +
            'AND CurrencyIsoCode IN (\'' + String.join(new List<String>(scheduleCurrencyMap.values()), '\',\'') + '\') ' +
            'AND IsActive = TRUE ' +
            'AND Id NOT IN (SELECT PricebookEntryId FROM PricebookEntryAdjustment)';


        Database.executeBatch(
            new B2B_AddPBEsToAdjustmentBatch(scheduleCurrencyMap, queryString),
            batchSize
        );
    }
}