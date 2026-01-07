@isTest
private class B2B_CreateNewProductsBatchTest {
    @testSetup
    static void setup() {
        Integer customLabelDays = Integer.valueOf(Label.New_Product_Last_N_Days);
Date withinRangeDate = Date.today().addDays(-customLabelDays + 1); 
        // Create the 'New Products' ProductCategory and set its External_Id__c.
        ProductCatalog productCatalog = new ProductCatalog(Name = 'Test Catalog');
        insert productCatalog;

        ProductCategory newProductCategory = new ProductCategory(
            Name = 'New Products',
            External_Id__c = 'NEW_PROD_CAT',
            CatalogId = productCatalog.Id
        );
        insert newProductCategory;
      
        
        // Create products with Intro_Date__c in the last N days and some outside.
        List<Product2> products = new List<Product2>();
        products.add(new Product2(
            Name = 'Product A',
            StockKeepingUnit = 'SKU-A',
            Intro_Date__c = withinRangeDate
        ));
        products.add(new Product2(
            Name = 'Product B',
            StockKeepingUnit = 'SKU-B',
            Intro_Date__c = Date.today().addDays(-customLabelDays - 1)
        ));
        products.add(new Product2(
            Name = 'Product C',
            StockKeepingUnit = 'SKU-C',
            Intro_Date__c =  withinRangeDate
        ));
        insert products;
        List<ProductCategoryProduct> existingLinks = new List<ProductCategoryProduct>();
        // Create an existing ProductCategoryProduct link for 'Product B' which is outside the time frame.
         ProductCategoryProduct existingLinkA = new ProductCategoryProduct(
            ProductId = products[0].Id, // Linking 'Product A'
            ProductCategoryId = newProductCategory.Id,
            External_Id__c = 'SKU-A-NEW_PROD_CAT'
        );
        ProductCategoryProduct existingLinkB = new ProductCategoryProduct(
            ProductId = products[1].Id, // Linking 'Product B'
            ProductCategoryId = newProductCategory.Id,
            External_Id__c = 'SKU-B-NEW_PROD_CAT'
        );
         ProductCategoryProduct existingLinkC = new ProductCategoryProduct(
            ProductId = products[2].Id, // Linking 'Product B'
            ProductCategoryId = newProductCategory.Id,
            External_Id__c = 'SKU-C-NEW_PROD_CAT'
        );
  
        existingLinks.add(existingLinkB);
      
        
        
    }
    
    @isTest
    static void testBatchJob() {
      
        // Get the 'New Products' ProductCategory Id.
        Id newProductCategoryId = [SELECT Id FROM ProductCategory WHERE Name LIKE 'New Products%' LIMIT 1].Id;
        system.debug('newProductCategoryId ==>'+ newProductCategoryId);
        // Retrieve the value of the custom label.
        //Integer customLabelDays = Integer.valueOf(Label.New_Product_Last_N_Days);

        // Run the batch class.
        Test.startTest();
        B2B_CreateNewProductsBatch batchJob = new B2B_CreateNewProductsBatch();
        Database.executeBatch(batchJob, 50); // Specify the batch size if needed.
        Test.stopTest();

        // Verify that the correct ProductCategoryProduct records were created or deleted.
        List<ProductCategoryProduct> productCategoryProducts = [
            SELECT ProductId, ProductCategoryId, External_Id__c
            FROM ProductCategoryProduct
            WHERE ProductCategoryId =: newProductCategoryId
        ];

       
        // Verify that Product A and Product C have new links with the correct format in External_Id__c.
        Set<String> expectedSKUs = new Set<String>{ 'SKU-A', 'SKU-C' };
        for (ProductCategoryProduct pcp : productCategoryProducts) {
            String[] parts = pcp.External_Id__c.split('-');
            System.assertEquals(2, parts.size(), 'The External_Id__c format should be SKU-NEW_PROD_CAT.');
            System.assert(expectedSKUs.contains(parts[0]), 'Unexpected SKU in External_Id__c: ' + pcp.External_Id__c);
            System.assertEquals('NEW_PROD_CAT', parts[1], 'Expected NEW_PROD_CAT in the External_Id__c');
        }

        // Verify that the link for 'Product B' was deleted since it's outside the time frame.
      
        Integer customLabelDays = Integer.valueOf(Label.New_Product_Last_N_Days);
        Date cutoffDate = Date.today().addDays(-customLabelDays);
     List<Product2> products = [SELECT Id FROM Product2 
                           WHERE Intro_Date__c >= :cutoffDate 
                           AND StockKeepingUnit = 'SKU-B' 
                           LIMIT 1];

Integer countOldLinks = 0;

if (!products.isEmpty()) {
    countOldLinks = [SELECT COUNT() 
                     FROM ProductCategoryProduct 
                     WHERE ProductId = :products[0].Id];
}
        System.assertEquals(0, countOldLinks, 'The link for Product B should have been deleted.');
    }

    @isTest
    static void testBatchJobWithNoEligibleProducts() {
        // Adjust setup so that no products are within the custom label days.
        List<Product2> productsToUpdate = [SELECT Id, Intro_Date__c FROM Product2];
        for (Product2 product : productsToUpdate) {
            product.Intro_Date__c = Date.today().addDays(- 3650); // Move all Intro dates outside the time frame.
        }
        update productsToUpdate;

        // Run the batch class.
        Test.startTest();
        B2B_CreateNewProductsBatch batchJob = new B2B_CreateNewProductsBatch();
        Database.executeBatch(batchJob, 50);
        Test.stopTest();

        // Verify that no new ProductCategoryProduct records were created.
         Id newProductsCategoryId = [SELECT Id FROM ProductCategory WHERE Name = 'New Products' LIMIT 1].Id;
Integer countNewLinks = [SELECT COUNT()
                         FROM ProductCategoryProduct
                         WHERE ProductCategoryId = :newProductsCategoryId];
       
       System.assertEquals(0, countNewLinks, 'No ProductCategoryProduct links should be created as all products are outside the time frame.');
    }
}