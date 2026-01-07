/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 09-29-2025
 * @last modified by  : Swati Chilap
 * @TestClass         : B2B_AddPBEsToAdjustmentBatchTest
**/
global class B2B_AddPBEsToAdjustmentBatch implements Database.Batchable<SObject>, Database.Stateful {

    Map<String, String> scheduleCurrencyMap; // Schedule Name → Currency
    String queryString;

    global B2B_AddPBEsToAdjustmentBatch(Map<String, String> schedCurrencyMap,  String queryStr) {
        this.scheduleCurrencyMap = schedCurrencyMap;
        this.queryString = queryStr;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<PricebookEntry> scope) {
        try {
            if (scope == null || scope.isEmpty()) {
                return;
            }
            // Group PBEs by currency for fast lookup
            Map<String, List<PricebookEntry>> pbByCurrency = new Map<String, List<PricebookEntry>>();
            for (PricebookEntry pbe : scope) {
                if (!pbByCurrency.containsKey(pbe.CurrencyIsoCode)) {
                    pbByCurrency.put(pbe.CurrencyIsoCode, new List<PricebookEntry>());
                }
                pbByCurrency.get(pbe.CurrencyIsoCode).add(pbe);
            }

            // Query all schedules once
            Map<String, Id> scheduleNameToId = new Map<String, Id>();
            for (PriceAdjustmentSchedule sched : [
                SELECT Id, Name 
                FROM PriceAdjustmentSchedule 
                WHERE Name IN :scheduleCurrencyMap.keySet()
            ]) {
                scheduleNameToId.put(sched.Name, sched.Id);
            }

            List<PricebookEntryAdjustment> newAdjustments = new List<PricebookEntryAdjustment>();
            for (String schedName : scheduleCurrencyMap.keySet()) {
                String currencyCode = scheduleCurrencyMap.get(schedName);
                Id schedId = scheduleNameToId.get(schedName);
                if (schedId == null) continue;

                List<PricebookEntry> pbes = pbByCurrency.get(currencyCode);
                if (pbes == null || pbes.isEmpty()) continue;

                for (PricebookEntry pbe : pbes) {
                    newAdjustments.add(new PricebookEntryAdjustment(
                        PriceAdjustmentScheduleId = schedId,
                        PricebookEntryId = pbe.Id
                    ));
                }
            }

            // Bulk insert all new adjustments at once
            if (!newAdjustments.isEmpty()) {
                Database.insert(newAdjustments, false);
                System.debug('Inserted ' + newAdjustments.size() + ' total adjustments for all schedules.');
            } else {
                System.debug('No new adjustments to insert.');
            }
        } catch (Exception e) {
            AscensusHandleCustomException.LogException(e, 'B2B_AddPBEsToAdjustmentBatch', 'execute');
        }
    }


    global void finish(Database.BatchableContext bc) {
        System.debug('Batch finished for all schedules.');
    }
}