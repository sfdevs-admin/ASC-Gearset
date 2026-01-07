/**
 * @description This is a helper class for Opportunity trigger.
 * @Author Atrium - nipun.jain@atrium.ai
 * @date Feb 2025
 */
public without sharing class OpportunityTriggerHandlerHelper {
    
    private static string editAccessLevel = 'Edit';
    private static string manualSharing = Schema.OpportunityShare.RowCause.Manual;

    /**
     * @description This method deletes the existing sharing for the given Opportunities.
     * @param opportunities - List of Opportunity records.
     */
    public static void deleteExistingSharing(List<Opportunity> opportunities) {
        List<OpportunityShare> existingSharing = new List<OpportunityShare>();        
        existingSharing = [SELECT Id, UserOrGroupId, RowCause 
                            FROM OpportunityShare 
                            WHERE 
                            OpportunityId IN: opportunities AND 
                            RowCause =: manualSharing 
                            WITH SYSTEM_MODE];
        
        Database.delete(existingSharing, AccessLevel.SYSTEM_MODE);
    }
    
    /**
     * @description This method adds new sharing for the given Opportunities.
     * @param opportunities - List of Opportunity records.
     */
    public static void addNewSharing(List<Opportunity> opportunities) {
        List<OpportunityShare> newSharing = new List<OpportunityShare>();
        Map<Id, Set<Id>> opportunitiesToOnwers = new Map<Id, Set<Id>>();
        for (OpportunityShare existingOwnerSharing: [SELECT Id, UserOrGroupId, OpportunityId 
                                                    FROM OpportunityShare 
                                                    WHERE 
                                                    OpportunityId IN: opportunities AND 
                                                    RowCause !=: manualSharing 
                                                    WITH SYSTEM_MODE]) {
            if (opportunitiesToOnwers.containsKey(existingOwnerSharing.OpportunityId)) {
                opportunitiesToOnwers.get(existingOwnerSharing.OpportunityId).add(existingOwnerSharing.UserOrGroupId);
            }
            else {
                opportunitiesToOnwers.put(existingOwnerSharing.OpportunityId, new Set<Id>{existingOwnerSharing.UserOrGroupId});
            }
        }        
        for (Opportunity opp: opportunities) {
            if (opportunitiesToOnwers.containsKey(opp.Id) && !opportunitiesToOnwers.get(opp.Id).contains(opp.Lead_Chemist__c) && opp.Lead_Chemist__c != NULL) {
                OpportunityShare sharing = new OpportunityShare();
                sharing.OpportunityId = opp.Id;
                sharing.UserOrGroupId = opp.Lead_Chemist__c;
                sharing.RowCause = manualSharing;
                sharing.OpportunityAccessLevel = editAccessLevel;
                newSharing.add(sharing);
            }
        }
        
        Database.insert(newSharing, AccessLevel.SYSTEM_MODE);
    }
}