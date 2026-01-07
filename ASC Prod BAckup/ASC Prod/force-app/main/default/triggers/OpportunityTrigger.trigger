/**
 * @description Trigger for Opportunity.
 * @Author Atrium - nipun.jain@atrium.ai
 * @date Feb 2025
 */

trigger OpportunityTrigger on Opportunity (before insert, before update, after update, after insert, before delete, after delete, after undelete) {
	new OpportunityTriggerHandler().run();
}