/**
* @author Nipun Jain ( Atrium )
* @date NOV 2024
* @description This batch updates the overdue Milestone for RD Portfolios.
*/
public class OverdueMilestoneBatch implements Database.Batchable<sObject>, Schedulable {
    
    public Set<Id> portfolioIds; 
    
    /**
     * @description Constructor for the batch
    */
    public OverdueMilestoneBatch() {
        portfolioIds = new Set<Id>();
        for(Task dueTasks : [SELECT Id, WhatId FROM Task WHERE ActivityDate = LAST_N_DAYS:1]) {
            if(dueTasks.WhatId != NULL && dueTasks.WhatId.getSObjectType().getDescribe().getName() == 'RD_Portfolio__c') {
                portfolioIds.add(dueTasks.WhatId);
            }
        }
    }
        
    /**
	 * @description Start method to get the records to process
	 * @param bc
 	 * @return database.querylocator
	*/
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Name, Overdue_Milestone__c FROM RD_Portfolio__c WHERE Id IN: portfolioIds';
        return Database.getQueryLocator(query);
    }
    
    /**
     * @description Execute method to process the records
     * @param bc
     * @param relatedPortfolios
	*/
    public void execute(Database.BatchableContext bc, List<RD_Portfolio__c> relatedPortfolios){
        for(RD_Portfolio__c portfolio : relatedPortfolios) {
            portfolio.Overdue_Milestone__c += 1;
        }
        Database.SaveResult[] lsr = Database.update(relatedPortfolios);
    }
    
    /**
     * @description finish method of batch
     * @param bc
    */
    public void finish(Database.BatchableContext bc){
		System.debug(LOGGINGLEVEL.INFO, '*** FINISH METHOD ***');
    }
    
    /**
     * @description execute method of Schedulable
     * @param ctx
    */
    public void execute(SchedulableContext ctx){
        OverdueMilestoneBatch batch = new OverdueMilestoneBatch();
        Database.executebatch(batch,100);
    }
    

}