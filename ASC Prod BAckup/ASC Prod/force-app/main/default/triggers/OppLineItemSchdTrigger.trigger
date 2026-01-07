/**
 * @description Trigger for OpportunityLineItemSchedule.
 * @Author nipun.jain@atrium.ai
 * @date Map 2025
 */
trigger OppLineItemSchdTrigger on OpportunityLineItemSchedule (before insert, before update, after update, after insert, before delete, after delete, after undelete) {
    new OppLineItemSchdTriggerHandler().run();
}