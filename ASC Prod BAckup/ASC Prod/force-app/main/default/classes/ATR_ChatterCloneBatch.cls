/**
 * @description Batch class to clone Chatter FeedItems and associated FeedComments 
 *              from original RD Portfolios to their respective cloned portfolios.
 * @author nipun.jain@atrium.ai
 * @since April 2025
 */
public with sharing class ATR_ChatterCloneBatch implements Database.Batchable<SObject> {
    
    private Map<Id, Id> oldToNewPortfolioMap = new Map<Id, Id>();

    /**
     * @description Constructor that initializes the old-to-new portfolio mapping using the
     *              Original_RD_Portfolio__c field on the Opportunity object.
     */
    public ATR_ChatterCloneBatch() {
        for(Opportunity portfolio : [SELECT Id, Original_RD_Portfolio__c
                                     FROM Opportunity 
                                     WHERE Original_RD_Portfolio__c != NULL
                                     WITH SYSTEM_MODE]) {
            oldToNewPortfolioMap.put(portfolio.Original_RD_Portfolio__c, portfolio.Id);   
        }     
    }

    /**
     * @description Start method of the batch job to fetch FeedItems associated with original portfolios.
     * 
     * @param bc The batch context provided by the system.
     * @return QueryLocator pointing to FeedItems to be processed.
     */
    public Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, CreatedDate, ParentId, Body, Title, IsRichText, CreatedById, LinkUrl, RelatedRecordId
                                        FROM FeedItem
                                        WHERE
                                        ParentId IN: oldToNewPortfolioMap.keySet() AND
                                        Type != 'TrackedChange']);
    }

    /**
     * @description Execute method that clones FeedItems and their associated FeedComments to the new portfolios.
     * 
     * @param bc The batch context provided by the system.
     * @param feedItems List of FeedItems fetched in the start method to be processed in this batch.
     */
    public void execute(Database.BatchableContext bc, List<FeedItem> feedItems) {
        Map<Id, FeedItem> oldToNewFeedPlaceholders = new Map<Id, FeedItem>();
        List<FeedItem> feedsToInsert = buildFeedItemsToInsert(feedItems, oldToNewFeedPlaceholders);
    
        if(!feedsToInsert.isEmpty()) {
            List<Database.SaveResult> feedSaveResults = Database.insert(feedsToInsert, false);
            Map<Id, Id> oldToNewFeedIds = processFeedInsertResults(feedSaveResults, feedsToInsert, oldToNewFeedPlaceholders);
        
            if (!oldToNewFeedIds.isEmpty()) {
                List<FeedComment> commentsToInsert = buildFeedCommentsToInsert(oldToNewFeedIds);
                if (!commentsToInsert.isEmpty()) {
                    List<Database.SaveResult> commentResults = Database.insert(commentsToInsert, false);
                    processCommentInsertResults(commentResults, commentsToInsert);
                } else {
                    System.debug(LoggingLevel.INFO, 'ChatterCopier: No new FeedComments needed insertion.');
                }
            }
    
        }
    
    }
    
    /**
     * @description Constructs a list of cloned FeedItems based on the original FeedItems list.
     *              Populates a placeholder map to track the relationship between original and cloned FeedItems.
     *
     * @param originals List of original FeedItems to be cloned.
     * @param placeholderMap A map that will store the relationship between original FeedItem IDs and their clones.
     *
     * @return A list of cloned FeedItems ready for insertion.
     */
    private List<FeedItem> buildFeedItemsToInsert(List<FeedItem> originals, Map<Id, FeedItem> placeholderMap) {
        List<FeedItem> newFeeds = new List<FeedItem>();
        for (FeedItem original : originals) {
            FeedItem copy = new FeedItem();
            copy.CreatedDate = original.CreatedDate;
            copy.ParentId = oldToNewPortfolioMap.get(original.ParentId);
            copy.Body = original.Body;
            copy.Title = original.Title;
            copy.IsRichText = original.IsRichText;
            copy.CreatedById = original.CreatedById;
            copy.LinkUrl = original.LinkUrl;
            copy.RelatedRecordId = original.RelatedRecordId;
    
            newFeeds.add(copy);
            placeholderMap.put(original.Id, copy);
        }
        return newFeeds;
    }
    
    /**
     * @description Processes the results of FeedItem insert operations, maps original FeedItem IDs to new ones,
     *              and logs any insertion errors.
     *
     * @param results List of SaveResults returned from the FeedItem insert operation.
     * @param inserted List of FeedItems that were attempted to be inserted.
     * @param placeholders A map linking original FeedItem IDs to their corresponding cloned FeedItems.
     *
     * @return A map of original FeedItem IDs to their newly inserted FeedItem IDs.
     */
    private Map<Id, Id> processFeedInsertResults(
        List<Database.SaveResult> results,
        List<FeedItem> inserted,
        Map<Id, FeedItem> placeholders
    ) {
        Map<Id, Id> oldToNewChattermapping = new Map<Id, Id>();
        Integer successCount = 0;
    
        for (Integer i = 0; i < results.size(); i++) {
            Database.SaveResult res = results[i];
            FeedItem newItem = inserted[i];
            Id oldId = getOriginalIdFromPlaceholder(newItem, placeholders);
    
            if (res.isSuccess()) {
                if (oldId != null) {
                    oldToNewChattermapping.put(oldId, res.getId());
                    successCount++;
                    System.debug(LoggingLevel.INFO, 'ChatterCopier: Created FeedItem ' + res.getId() + ' from ' + oldId);
                }
            } else {
                String context = 'FeedItem from ' + oldId;
                logInsertErrors(res, context, i);
            }
        }
    
        return oldToNewChattermapping;
    }
    
    /**
     * @description Retrieves the original FeedItem ID that corresponds to a given cloned FeedItem from the placeholder map.
     *
     * @param newItem The cloned FeedItem.
     * @param placeholders The map that tracks the relationship between original and cloned FeedItems.
     *
     * @return The original FeedItem ID if found; otherwise, null.
     */
    private Id getOriginalIdFromPlaceholder(FeedItem newItem, Map<Id, FeedItem> placeholders) {
        for (Id oldId : placeholders.keySet()) {
            if (placeholders.get(oldId) == newItem) {
                return oldId;
            }
        }
        return null;
    }
    
    /**
     * @description Constructs a list of cloned FeedComments based on existing FeedComments and their mapped new FeedItem IDs.
     *
     * @param oldToNewFeedIds A map of original FeedItem IDs to their corresponding cloned FeedItem IDs.
     *
     * @return A list of cloned FeedComments ready for insertion.
     */
    private List<FeedComment> buildFeedCommentsToInsert(Map<Id, Id> oldToNewFeedIds) {
        List<FeedComment> newComments = new List<FeedComment>();
        for (FeedComment original : [
            SELECT Id, FeedItemId, CreatedDate, CommentBody, IsRichText, CreatedById, ParentId
            FROM FeedComment
            WHERE FeedItemId IN :oldToNewFeedIds.keySet()
            WITH SYSTEM_MODE
            ORDER BY CreatedDate ASC
        ]) {
            FeedComment comment = new FeedComment();
            comment.CreatedDate = original.CreatedDate;
            comment.FeedItemId = oldToNewFeedIds.get(original.FeedItemId);
            comment.CommentBody = original.CommentBody;
            comment.IsRichText = original.IsRichText;
            comment.CreatedById = original.CreatedById;
            newComments.add(comment);
        }
        return newComments;
    }
    
    /**
     * @description Processes the results of FeedComment insert operations and logs any errors.
     *
     * @param results List of SaveResults returned from the insert operation.
     * @param inserted List of FeedComments that were attempted to be inserted.
     */
    private void processCommentInsertResults(List<Database.SaveResult> results, List<FeedComment> inserted) {
        Integer successCount = 0;
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                successCount++;
            } else {
                logInsertErrors(results[i], 'FeedComment', i);

            }
        }
        System.debug(LoggingLevel.INFO,
            'ChatterCopier: Inserted ' + successCount + ' out of ' + inserted.size() + ' new FeedComments.'
        );
    }
    
    /**
     * @description Logs detailed error messages for failed DML insert operations in the batch.
     *              Combines object type and optional context into a readable log string to keep
     *              parameter count within PMD-compliant limits.
     *
     * @param res The Database.SaveResult containing the errors to log.
     * @param errorContext A descriptive string identifying the context (e.g., 'FeedItem from 001xx000003DNEz').
     * @param index The index of the failed item in the list being inserted.
     */
    private void logInsertErrors(Database.SaveResult res, String errorContext, Integer index) {
        String errorDetails = '';
        for (Database.Error err : res.getErrors()) {
            errorDetails += err.getStatusCode() + ': ' + err.getMessage()
                + ' (Fields: ' + String.join(err.getFields(), ', ') + '); ';
        }
        System.debug(
            LoggingLevel.ERROR,
            'ChatterCopier Error: Failed to insert ' + errorContext
            + ' at index ' + index + '. Errors: ' + errorDetails
        );
    }
        

    /**
     * @description Finish method executed once all batches are processed.
     * 
     * @param bc The batch context provided by the system.
     */
    public void finish (Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO,  'ChatterCopier: Finished inserting ');
    }
}