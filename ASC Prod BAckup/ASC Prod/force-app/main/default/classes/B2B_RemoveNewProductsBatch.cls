global class B2B_RemoveNewProductsBatch implements Database.Batchable<SObject> {
    global String customLabelDays = Label.New_Product_Last_N_Days;
    global string newProductCategoryId = label.New_Product_Category_Id;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id, Product.Name, ProductId, ProductCategoryId FROM ProductCategoryProduct WHERE ProductCategoryId = \'' + newProductCategoryId + '\'' ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ProductCategoryProduct> scope) {
        
        Set<Id> productIds = new Set<Id>();
        
        
        for (ProductCategoryProduct link : scope) {
            productIds.add(link.ProductId);
        }
        Map<Id, Product2> productsMap = new Map<Id, Product2>([
            SELECT Id, Intro_Date__c FROM Product2 WHERE Id IN :productIds
        ]);
        List<ProductCategoryProduct> recordsToDelete = new List<ProductCategoryProduct>();
        Integer last_N_Days = Integer.valueOf(customLabelDays);
        for (ProductCategoryProduct link : scope) {
            Product2 product = productsMap.get(link.ProductId);
            if (product != null && product.Intro_Date__c != null) {
                
                Date productCreationDate = product.Intro_Date__c;
                Integer productAgeInDays = productCreationDate.daysBetween(Date.today());
                //system.debug('ProductAgeInDays==>'+ productAgeInDays);
                
                
                if (productAgeInDays > last_N_Days) {
                    recordsToDelete.add(link);
                    //system.debug('recordsToDelete ==>'+ recordsToDelete);
                }
            }
        }
        if(!recordsToDelete.isEmpty()){
            delete recordsToDelete;
        }
        
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        // Log or perform any post-processing actions if necessary

        //System.debug('B2B_RemoveNewProductsBatch completed.');
    }
}