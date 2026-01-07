global class B2B_CreateNewProductsBatch implements Database.Batchable<SObject> {
    global String customLabelDays = Label.New_Product_Last_N_Days; 
    global string newProductCategoryId = label.New_Product_Category_Id;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Intro_Date__c,createdDate,StockKeepingUnit FROM Product2 WHERE Intro_Date__c = LAST_N_DAYS:' + customLabelDays;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Product2> scope) {
        Set<Id> newProductIds = new Set<Id>();
        if(!scope.isempty()){
            for(Product2 newProducts : scope){
                //system.debug('IntroDate==>'+ newProducts.Intro_Date__c);
                newProductIds.add(newProducts.Id);
            }
            Map<Id,String> catergoryIdtoStringMap = new Map<Id,String>();
            
            List<ProductCategory> newProductCategoryList =  [Select Id,External_Id__c,ParentCategoryId from ProductCategory where Id = :newProductCategoryId];
            for(ProductCategory newProductCategory : newProductCategoryList){
                catergoryIdtoStringMap.put(newProductCategory.Id,newProductCategory.External_Id__c);
                
            }
            
            Map<Id, ProductCategoryProduct> existingLinks = new Map<Id, ProductCategoryProduct>();
            List<ProductCategoryProduct> productCategoryProductList = [SELECT Id,ProductId FROM ProductCategoryProduct WHERE ProductId IN :newProductIds AND ProductCategoryId = :newProductCategoryId];
            for(ProductCategoryProduct link: productCategoryProductList){
                existingLinks.put(link.ProductId, link);
            }
            
            List<ProductCategoryProduct> newLinks = new List<ProductCategoryProduct>();
            for (Product2 product : scope) {
                /*Date productCreationDate = product.Intro_Date__c ;
                system.debug('productCreationDate==>'+ productCreationDate);
                Integer productAgeInDays = productCreationDate.daysBetween(Date.today());
                system.debug('productAgeInDays==>'+ productAgeInDays);*/
                
                if ( ! existingLinks.containsKey( product.Id ) ) {
                    newLinks.add(new ProductCategoryProduct(
                        
                        ProductId = product.Id,
                        ProductCategoryId = newProductCategoryId,
                        External_Id__c = product.StockKeepingUnit + '-' + catergoryIdtoStringMap.get(newProductCategoryId)
                        
                    ));
                    
                }
            }
            if(!newLinks.isempty()){
                insert newLinks;
                //system.debug('newLinks====>'+ newLinks);
            }
            
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        try {
            String webstoreId = [SELECT Id,name FROM WebStore where name =: 'Ascensus'].Id;
            //system.debug('WebstoreId==>'+ webstoreId);
            ConnectApi.CommerceSearchIndex csi = ConnectApi.CommerceSearchSettings.createCommerceSearchIndex(webstoreId);
            //System.debug('Commerce Search Index created successfully: ' + csi);
        } catch (Exception e) {
            
            //System.debug('Error creating Commerce Search Index: ' + e.getMessage());
        }
    }
}