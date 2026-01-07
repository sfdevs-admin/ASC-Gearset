/**
 * @description     Controller class used to retrieve the Opportunity linked 
 *                  to a given Original RD Portfolio. This is be used to show a 
 *                  warning banner in the UI if such an Opportunity exists.
 * @author          nipun.jain@atrium.ai
 * @since           April 2025
 */
public with sharing class ATR_oldRDPortfolioWarningBannerCont {
    
    /**
     * @description     Retrieves the  Opportunity that has the given Portfolio Id 
     *                  in the 'Original_RD_Portfolio__c' lookup field.
     * @param           portfolioId     Id of the RD Portfolio 
     * @return          Opportunity     matching Opportunity record or null if none found.
     */
    @AuraEnabled (cacheable=false)
    public static Opportunity getChildOpportunity(Id portfolioId) {
        List<Opportunity> childOpportunity = [SELECT Id, Name FROM Opportunity WHERE Original_RD_Portfolio__c =: portfolioId WITH USER_MODE LIMIT 1];
        return childOpportunity.isEmpty() || portfolioId == NULL ? NULL : childOpportunity[0];
    }
}