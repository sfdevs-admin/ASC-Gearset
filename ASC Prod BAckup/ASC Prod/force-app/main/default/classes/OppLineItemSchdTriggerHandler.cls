/**
 * @description This class handles the trigger logic for OpportunityLineItemSchedule.
 * @Author nipun.jain@atrium.ai
 * @date Map 2025
 */
public class OppLineItemSchdTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert(){
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE INSERT ***');
    }
    
    public override void beforeUpdate() {
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE UPDATE ***');
    }
    
    public override void beforeDelete() {
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE DELETE ***');
    }
    
    public override void afterInsert() {
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER INSERT ***');
        
        OppLineItemSchdTriggerHelper.updateOpportunityFinancials(
            (Map<Id, OpportunityLineItemSchedule>)Trigger.newMap, 
            (Map<Id, OpportunityLineItemSchedule>)Trigger.newMap, 
            'INSERT'
        );
    }
    
    public override void afterUpdate() {
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER UPDATE ***');
        
        OppLineItemSchdTriggerHelper.updateOpportunityFinancials(
            (Map<Id, OpportunityLineItemSchedule>)Trigger.newMap, 
            (Map<Id, OpportunityLineItemSchedule>)Trigger.oldMap, 
            'UPDATE'
        );
    }
    
    public override void afterDelete() {
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER DELETE ***');
        
        OppLineItemSchdTriggerHelper.updateOpportunityFinancials(
            (Map<Id, OpportunityLineItemSchedule>)Trigger.oldMap, 
            (Map<Id, OpportunityLineItemSchedule>)Trigger.oldMap, 
            'DELETE'
        );
    }

}