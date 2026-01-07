/**
 * @description Controller for retrieving related records in Salesforce.
 * @author nipun.jain@atrium.ai
 * @since May 2025
 */
public with sharing class AtrRelatedListController {
    
    private static final String RELATED_RECORD_QUERY = 'SELECT Id, {0} FROM {1} {2}';
    private static final String RD_PRODUCT_NAME = System.Label.RD_Product;

    /**
     * @description Retrieves related records based on the specified object type, field to query, and condition clause.
     *
     * @param objectName The API name of the object to query.
     * @param fieldToQuery The field to retrieve from the related records.
     * @param conditionClause The WHERE clause to filter the records.
     * @return A list of SObject records that match the query.
     */
    @AuraEnabled(cacheable=false)
    public static List<SObject> getRelatedRecord(String objectName, String fieldToQuery, String conditionClause) {
        String query = String.format(RELATED_RECORD_QUERY, new List<String>{fieldToQuery, objectName, conditionClause});

        try {

            List<SObject> records = Database.query(query);
            return records;

        } catch (Exception e) {
            System.debug(LOGGINGLEVEL.ERROR , 'Error retrieving related records: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving related records: ' + e.getMessage());
        }
    }

    /**
     * @description update or delete a record by its Id.
     * @param recordList List of records to delete/update.
     * @param operation Type of DML operation to perform ('DELETE' or 'UPDATE').
     */
    @AuraEnabled(cacheable=false)
    public static void updateOrDeleteRecord(List<SObject> recordList, String operation) {

        try {
            switch on operation {
                when 'DELETE' {
                    Database.delete(recordList, true, AccessLevel.SYSTEM_MODE);
                }
                when 'UPDATE' {
                    Database.update(recordList, true, AccessLevel.SYSTEM_MODE);
                }
            }
        } catch (Exception e) {
            System.debug(LOGGINGLEVEL.ERROR, 'Error deleting record: ' + e.getMessage());
            throw new AuraHandledException('Error deleting record: ' + e.getMessage());
        }
    }

    /**
     * @description Retrieves related Opportunity Line Items for a given Opportunity record.
     * @param recordId The Id of the Opportunity record.
     * @return A list of OpportunityLineItem records related to the specified Opportunity.
     */
    @AuraEnabled(cacheable=false)
    public static List<OpportunityLineItem> getRelatedLineItems(String recordId){

        try {
            return [SELECT Id,
                    Product2.Name,
                    Quantity,
                    UnitPrice,
                    ServiceDate,
                    TotalPrice,
                    Description,
                    (
                        SELECT Id,
                        ScheduleDate,
                        Revenue,
                        Description
                        FROM OpportunityLineItemSchedules
                    )
                    FROM OpportunityLineItem
                    WHERE 
                    OpportunityId = :recordId
                    WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Retrieves the Id of the Product2 record with the name specified in the RD_Product label.
     * @return The Id of the Product2 record.
     */
    @AuraEnabled(cacheable=true)
    public static Id getRDProduct(){
        try {
            return [SELECT Id FROM Product2 WHERE Name =: RD_PRODUCT_NAME]?.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Establishes schedules for Opportunity Line Items based on the provided JSON string.
     * @param scheduleLineItems JSON string representing a list of OpportunityLineItemSchedule records.
     * @param deleteExisting Boolean indicating whether to delete existing schedules before establishing new ones.
     * @param lineItemId The Id of the Opportunity Line Item for which schedules are being established.
     */
    @AuraEnabled(cacheable=false)
    public static void establishSchedules(String scheduleLineItems, Boolean deleteExisting, String lineItemId) {
        try {
            List<OpportunityLineItemSchedule> schedules = (List<OpportunityLineItemSchedule>) JSON.deserialize(scheduleLineItems, List<OpportunityLineItemSchedule>.class);

            if (deleteExisting) {
                List<OpportunityLineItemSchedule> existingSchedules = [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId =: lineItemId WITH SECURITY_ENFORCED];
                if (!existingSchedules.isEmpty()) {
                    Database.delete(existingSchedules, true, AccessLevel.SYSTEM_MODE);
                }
            }

            if(!schedules.isEmpty()) {
                Database.insert(schedules, true, AccessLevel.SYSTEM_MODE);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description Gets the available picklist values for the Schedule Type field.
     * Each entry in the list is a map with 'label' and 'value' keys.
     * @return      List<Map<String, String>> A list of maps, each representing a picklist option.
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getScheduleTypes() {
        List<Map<String, String>> scheduleTypes = new List<Map<String, String>>();
        try {
            Schema.DescribeFieldResult fieldResult = OpportunityLineItemSchedule.Schedule_Type__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

            for (Schema.PicklistEntry entry : picklistValues) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', entry.getLabel());
                option.put('value', entry.getValue());
                scheduleTypes.add(option);
            }
        } catch (Exception e) {
            System.debug(LOGGINGLEVEL.ERROR, 'Error retrieving schedule types: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving schedule types: ' + e.getMessage());
        }
        return scheduleTypes;
    }
}