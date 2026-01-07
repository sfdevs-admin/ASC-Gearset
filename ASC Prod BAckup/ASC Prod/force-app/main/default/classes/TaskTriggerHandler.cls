/**
 * @description This class handles the trigger logic for Task.
 * @Author Atrium - Nipun Jain
 * @date Oct 2024
 */

 public class TaskTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert(){
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE INSERT ***');
    }
    
    public override void beforeUpdate() {
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE UPDATE ***');
    }
    
    public override void beforeDelete() {
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE DELETE ***');
        TaskTriggerHandlerHelper.updateMilestoneCount((Map<Id, Task>)Trigger.oldMap, (Map<Id, Task>)Trigger.oldMap, 'Delete');
    }
    
    public override void afterInsert() {
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER INSERT ***');
        TaskTriggerHandlerHelper.updateMilestoneCount((Map<Id, Task>)Trigger.newMap, (Map<Id, Task>)Trigger.newMap, 'Insert');
        TaskTriggerHandlerHelper.updateRdNextAction((Map<Id, Task>)Trigger.newMap);
    }
    
    public override void afterUpdate() {
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER UPDATE ***');
        TaskTriggerHandlerHelper.updateMilestoneCount((Map<Id, Task>)Trigger.newMap, (Map<Id, Task>)Trigger.oldMap, 'Update');
        TaskTriggerHandlerHelper.updateRdNextAction((Map<Id, Task>)Trigger.newMap);
    }
    
    public override void afterDelete() {
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER DELETE ***');
        TaskTriggerHandlerHelper.updateRdNextAction((Map<Id, Task>)Trigger.oldMap);
    }
}