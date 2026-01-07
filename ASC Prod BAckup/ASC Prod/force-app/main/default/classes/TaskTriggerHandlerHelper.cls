/**
* @description This is a helper class for Task trigger.
* @Author Atrium - Nipun Jain
* @date Oct 2024
*/
public class TaskTriggerHandlerHelper {
    
    /**
* @description This method update number of Open Milestone.
* @param tasks - List of task records.
*/    
    public static void updateMilestoneCount(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap, String operation) { 
        Map<Id, Task> tasksMap = operation == 'Delete' ? oldTaskMap : newTaskMap;
        Set<Id> portfolioIds = new Set<Id>();
        for(Task triggeringTask : tasksMap.values()) {
            portfolioIds.add(triggeringTask.WhatId);
        }
        Map<Id, RD_Portfolio__c> relatedPortfolios = new Map<Id, RD_Portfolio__c>([SELECT Id, Open_Milestone__c, Completed_Milestones__c FROM RD_Portfolio__c WHERE Id IN: portfolioIds]);
        
        for(Id taskId : tasksMap.keyset()) {
            if(tasksMap.get(taskId).WhatId != NULL && tasksMap.get(taskId).WhatId.getSObjectType().getDescribe().getName() == 'RD_Portfolio__c') {
                switch on operation {
                    when 'Insert' {
                        if(newTaskMap.get(taskId).Status == 'Open') {
                            relatedPortfolios.get(newTaskMap.get(taskId).WhatId).Open_Milestone__c += 1;
                        }
                        if(newTaskMap.get(taskId).Status == 'Completed') {
                            relatedPortfolios.get(newTaskMap.get(taskId).WhatId).Completed_Milestones__c += 1;
                        }
                    }
                    when 'Update' {
                        if(newTaskMap.get(taskId).Status == 'Open' && newTaskMap.get(taskId).Status != oldTaskMap.get(taskId).Status) {
                            relatedPortfolios.get(newTaskMap.get(taskId).WhatId).Open_Milestone__c += 1;
                            relatedPortfolios.get(newTaskMap.get(taskId).WhatId).Completed_Milestones__c -= 1;
                        }
                        if(newTaskMap.get(taskId).Status == 'Completed' && newTaskMap.get(taskId).Status != oldTaskMap.get(taskId).Status) {
                            relatedPortfolios.get(newTaskMap.get(taskId).WhatId).Open_Milestone__c -= 1;
                            relatedPortfolios.get(newTaskMap.get(taskId).WhatId).Completed_Milestones__c += 1;
                        }
                    }
                    when 'Delete' {
                        if(oldTaskMap.get(taskId).Status == 'Open') {
                            relatedPortfolios.get(oldTaskMap.get(taskId).WhatId).Open_Milestone__c -= 1;
                        }
                        if(oldTaskMap.get(taskId).Status == 'Completed') {
                            relatedPortfolios.get(oldTaskMap.get(taskId).WhatId).Completed_Milestones__c -= 1;
                        }
                    }
                }
            }
        }
        update relatedPortfolios.values();
    }
    
    public static void updateRdNextAction(Map<Id, Task> taskMap) {
        Set<Id> portfolioIds = new Set<Id>();
        Set<Id> opportunityPortfolioIds = new Set<Id>();
        for(Task triggeringTask : taskMap.values()) {
            if(triggeringTask.WhatId != NULL && triggeringTask.WhatId.getSObjectType().getDescribe().getName() == 'RD_Portfolio__c') {
            	portfolioIds.add(triggeringTask.WhatId);
            }
            if(triggeringTask.WhatId != NULL && triggeringTask.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity') {
            	opportunityPortfolioIds.add(triggeringTask.WhatId);
            }
        }
        Map<Id, String> rdNextActionValues = new Map<Id, String>();
        for(Task relatedTask : [SELECT Id, Subject, WhatId FROM TASK WHERE Status = 'Open' AND ( WhatId IN: portfolioIds OR WhatId IN: opportunityPortfolioIds ) ORDER BY ActivityDate ASC NULLS LAST, CreatedDate ASC]) {
            if(!rdNextActionValues.containsKey(relatedTask.WhatId)) {
                rdNextActionValues.put(relatedTask.WhatId, relatedTask.Subject);
            }
        }
        
        if(portfolioIds.size() > 0) {
            List<RD_Portfolio__c> relatedPortfolios = [SELECT Id, RD_Next_Action__c FROM RD_Portfolio__c WHERE Id IN: portfolioIds];
            for(RD_Portfolio__c portfolio : relatedPortfolios) {
                if(rdNextActionValues.containsKey(portfolio.Id)) {
                    portfolio.RD_Next_Action__c = rdNextActionValues.get(portfolio.Id);
                } else {
                    portfolio.RD_Next_Action__c = 'No Work Planned';
                }
            }
            Database.update(relatedPortfolios, false);
        }
        
        if(opportunityPortfolioIds.size() > 0) {
            Id oppPortfolioRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('R_D_Portfolio').getRecordTypeId();
            List<Opportunity> relatedOppPortfolios = [SELECT Id, RD_Next_Action__c FROM Opportunity WHERE Id IN: opportunityPortfolioIds AND RecordTypeId =: oppPortfolioRecordTypeId];
            for(Opportunity opp : relatedOppPortfolios) {
                if(rdNextActionValues.containsKey(opp.Id)) {
                    opp.RD_Next_Action__c = rdNextActionValues.get(opp.Id);
                } else {
                    opp.RD_Next_Action__c = 'No Work Planned';
                }
            }
            Database.update(relatedOppPortfolios, false);
        }
    }
    
}