/**
 * @description Helper class for handling logic related to Opportunity Line Item Schedules (Revenue Scheduling).
 * It processes insert, update, and delete events on OpportunityLineItemSchedule records and recalculates 
 * corresponding annual revenue fields on the related Opportunity records.
 * 
 * The REVENUE_FIELDS_MAP maps calendar years to the respective custom revenue fields on Opportunity.
 *
 * @author nipun.jain@atrium.ai
 * @since May 2025
 */
public without sharing class OppLineItemSchdTriggerHelper {

    /**
     * Mapping of calendar year to the corresponding custom revenue field API name on Opportunity.
     */    
    final private static Map<Integer, String> REVENUE_FIELDS_MAP = new Map<Integer, String> { 
            2021 => 'OpportunityLineItem.Opportunity.X2021_Revenue__c', 
            2022 => 'OpportunityLineItem.Opportunity.X2022_Revenue_K__c', 
            2023 => 'OpportunityLineItem.Opportunity.X2023_Revenue_K__c', 
            2024 => 'OpportunityLineItem.Opportunity.X2024_Revenue_K__c', 
            2025 => 'OpportunityLineItem.Opportunity.X2025_Revenue_K__c', 
            2026 => 'OpportunityLineItem.Opportunity.X2026_Revenue_K__c', 
            2027 => 'OpportunityLineItem.Opportunity.X2027_Revenue_K__c', 
            2028 => 'OpportunityLineItem.Opportunity.X2028_Revenue_K__c', 
            2029 => 'OpportunityLineItem.Opportunity.X2029_Revenue_K__c', 
            2030 => 'OpportunityLineItem.Opportunity.X2030_Revenue__c' 
    };

    /**
     * @description
     * Main entry point to update Opportunity revenue fields based on changes in OpportunityLineItemSchedule records.
     * 
     * @param newScheduleMap Map of new OpportunityLineItemSchedule records.
     * @param oldScheduleMap Map of old OpportunityLineItemSchedule records.
     * @param operation operation The DML operation being performed ('INSERT', 'UPDATE', or 'DELETE').
     */
    public static void updateOpportunityFinancials(
        Map<Id, OpportunityLineItemSchedule> newScheduleMap, 
        Map<Id, OpportunityLineItemSchedule> oldScheduleMap, 
        String operation
    ) {
        Set<Id> lineItemIds = new Set<Id>();

        switch on operation {
            when 'INSERT' {
                for(OpportunityLineItemSchedule schedule: newScheduleMap.values()) {
                    lineItemIds.add(schedule.OpportunityLineItemId);
                }
            }
            when 'UPDATE' {
                for(Id scheduleId : newScheduleMap.keySet()) {
                    if(newScheduleMap.get(scheduleId).Revenue != oldScheduleMap.get(scheduleId).Revenue ||
                      newScheduleMap.get(scheduleId).ScheduleDate != oldScheduleMap.get(scheduleId).ScheduleDate) {
                          lineItemIds.add(oldScheduleMap.get(scheduleId).OpportunityLineItemId);
                      }
                }
            }
            when 'DELETE' {
                for(OpportunityLineItemSchedule schedule: oldScheduleMap.values()) {
                    lineItemIds.add(schedule.OpportunityLineItemId);
                }
            }
        }
        
        List<Opportunity> parentOpportunities = getParentOpportunities(lineItemIds);
        List<Opportunity> updatedOpportunity = calculateOpportunityFinancials(parentOpportunities);
        
        if(!updatedOpportunity.isEmpty()) {
            Database.update(updatedOpportunity, false, AccessLevel.USER_MODE);
        }
    }
    
    /**
     * @description
     * Retrieves the parent Opportunity records associated with the given set of OpportunityLineItem (OLI) IDs.
     * 
     * @param lineItemIds Set of OpportunityLineItem record IDs whose parent Opportunities need to be fetched.
     * @return List of Opportunity records that are parents of the provided line items.
     */
    private static List<Opportunity> getParentOpportunities(Set<Id> lineItemIds) {
        return [SELECT Id
               FROM Opportunity
               WHERE Id IN
               (
                   SELECT OpportunityId
                   FROM OpportunityLineItem
                   WHERE Id IN: lineItemIds
               )
               AND RecordType.DeveloperName = 'R_D_Portfolio'
               WITH SECURITY_ENFORCED];
    }
 
    /**
	 * @description Aggregates total revenue from schedule line items for each year,
     * divides the total by 1000, rounds it, and stores it on a corresponding Opportunity field.
     *
     * @param opportunityIds The list of Opportunities to process.
     * @return A list of Opportunity sObjects ready for DML update.
     */
    private static List<Opportunity> calculateOpportunityFinancials(List<Opportunity> opportunityIds) {
        Map<Id, Opportunity> updatedOpportunityMap = new Map<Id, Opportunity>();
        
        for(Opportunity opp: opportunityIds) {
            if(!updatedOpportunityMap.containsKey(opp.Id)) {
                Opportunity newOpp = new Opportunity(Id = opp.Id);
                
                for(String financialRev: REVENUE_FIELDS_MAP.values()) {
                    String financialFieldAPI = financialRev.substringAfterLast('.');
                    newOpp.put(financialFieldAPI, NULL);
                }
                
                updatedOpportunityMap.put(newOpp.Id, newOpp);
            }
        }
        
        String query = 'SELECT OpportunityLineItem.OpportunityId, CALENDAR_YEAR(ScheduleDate) scheduleYear, SUM(Revenue) totalRevenue '
                        + 'FROM OpportunityLineItemSchedule '
                        + 'WHERE OpportunityLineItem.OpportunityId IN :opportunityIds '
                        + 'GROUP BY OpportunityLineItem.OpportunityId, CALENDAR_YEAR(ScheduleDate) '
            			+ 'ORDER BY CALENDAR_YEAR(ScheduleDate)';
        
        for (AggregateResult ar : Database.query(String.escapeSingleQuotes(query))) {
            
            Id oppId = (Id)ar.get('OpportunityId');
            Integer year = (Integer)ar.get('scheduleYear');
            Decimal totalRevenue = (Decimal)ar.get('totalRevenue');
            
            if (REVENUE_FIELDS_MAP.containsKey(year)) {
                Opportunity oppToUpdate = updatedOpportunityMap.get(oppId);
                String financialFieldAPI = REVENUE_FIELDS_MAP.get(year).substringAfterLast('.');
                
                if (totalRevenue != null && totalRevenue != 0) {
                    Decimal revenueInThousands = totalRevenue / 1000;
                    Decimal finalValue = revenueInThousands.setScale(2, RoundingMode.HALF_UP);
                    oppToUpdate.put(financialFieldAPI, finalValue);
                }
            }
        }
        
        return updatedOpportunityMap.values();
    }
}