/**
 * @description This class handles the trigger logic for Opportunity.
 * @Author Atrium - nipun.jain@atrium.ai
 * @date Feb 2025
 */

public class OpportunityTriggerHandler extends TriggerHandler {
    public override void beforeInsert(){
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE INSERT ***');
    }
    
    public override void beforeUpdate() {
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE UPDATE ***');
    }
    
    public override void afterInsert() {
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER INSERT ***');

        List<Opportunity> updatedLeadChemistOpps = getTargettedOpportunities(
                                                new Map<Id, Opportunity>(), 
                                                (Map<Id, Opportunity>) Trigger.newMap, 
                                                new List<String>{'Lead_Chemist__c'}
                                            );

        if(!updatedLeadChemistOpps.isEmpty()) {
            OpportunityTriggerHandlerHelper.addNewSharing(updatedLeadChemistOpps);
        }
    }
    
    public override void afterUpdate() {
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER UPDATE ***');

        List<Opportunity> updatedLeadChemistOpps = getTargettedOpportunities(
                                                        (Map<Id, Opportunity>) Trigger.oldMap, 
                                                        (Map<Id, Opportunity>) Trigger.newMap, 
                                                        new List<String>{'Lead_Chemist__c'}
                                                    );

        if(!updatedLeadChemistOpps.isEmpty()) {
            OpportunityTriggerHandlerHelper.deleteExistingSharing(updatedLeadChemistOpps);
            OpportunityTriggerHandlerHelper.addNewSharing(updatedLeadChemistOpps);
        }
    }

    /**
     * @description Compares old and new versions of Opportunity records to identify those where specific fields have changed.
     * This method iterates through updated opportunities and checks a provided list of field APIs. If any of these fields
     * has been changed from its old value and the new value is not null, the opportunity is added to the result list.
     *
     * @param oldMap A map of Opportunity IDs to their previous sObject versions (typically from Trigger.oldMap).
     * @param newMap A map of Opportunity IDs to their new, updated sObject versions (typically from Trigger.newMap).
     * @param targetttedFields A list of field API names (as Strings) to check for changes.
     *
     * @return A List<Opportunity> containing records from the newMap where at least one of the specified fields has been modified.
     */
    private static List<Opportunity> getTargettedOpportunities(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap, List<String> targetttedFields) {
        List<Opportunity> targettedOpportunities = new List<Opportunity>();

        for (Opportunity newOpp : newMap.values()) {
            for(String fieldApi: targetttedFields) {

                if (newOpp.get(fieldApi) != null && (!(oldMap.containsKey(newOpp.Id)) || oldMap.get(newOpp.Id).get(fieldApi) != newMap.get(newOpp.Id).get(fieldApi))) {
                    targettedOpportunities.add(newOpp);
                    break;
                }
            }
            
        }
        return targettedOpportunities;
    }
}