@IsTest
private class B2B_RemoveNewProductsBatchTest {
    
    @TestSetup
    static void setup() {
        
        Product2 oldProduct = new Product2(Name = 'Old Product', Intro_Date__c = Date.today().addDays(-366));
        Product2 newProduct = new Product2(Name = 'New Product', Intro_Date__c = Date.today().addDays(-1));
        insert new List<Product2>{oldProduct, newProduct};
        
      
        String testCategoryId = Label.New_Product_Category_Id;
        
        
        ProductCategoryProduct oldProductLink = new ProductCategoryProduct(ProductId = oldProduct.Id, ProductCategoryId = testCategoryId);
        ProductCategoryProduct newProductLink = new ProductCategoryProduct(ProductId = newProduct.Id, ProductCategoryId = testCategoryId);
        insert new List<ProductCategoryProduct>{oldProductLink, newProductLink};
    }

    @IsTest
    static void testBatchExecution() {
        
        Integer customLabelDays = Integer.valueOf(Label.New_Product_Last_N_Days);
        
      
        List<ProductCategoryProduct> allProductLinks = [SELECT Id, ProductId, ProductCategoryId FROM ProductCategoryProduct];
        System.assertEquals(2, allProductLinks.size(), 'There should be 2 ProductCategoryProduct records initially.');
       
        Test.startTest();
        B2B_RemoveNewProductsBatch batchJob = new B2B_RemoveNewProductsBatch();
        Database.executeBatch(batchJob, 50);
        Test.stopTest();
        
        
        List<ProductCategoryProduct> remainingProductLinks = [SELECT Id, ProductId, ProductCategoryId FROM ProductCategoryProduct];
        
    
        Integer expectedRemainingLinks = 1;
        System.assertEquals(expectedRemainingLinks, remainingProductLinks.size(), 'There should be 1 ProductCategoryProduct record remaining.');
        
        
        Set<Id> remainingProductIds = new Set<Id>();
        for(ProductCategoryProduct link : remainingProductLinks) {
            remainingProductIds.add(link.ProductId);
        }
        List<Product2> remainingProduct = [SELECT Name FROM Product2 WHERE Id IN :remainingProductIds];
        System.assertEquals('New Product', remainingProduct[0].Name, 'The remaining product should be the new product.');
    }
    
    @IsTest
    static void testNoRecordsToDelete() {
       
        Product2 veryNewProduct = new Product2(Name = 'Very New Product', Intro_Date__c = Date.today().addDays(-3));
        insert veryNewProduct;
        
        String testCategoryId = Label.New_Product_Category_Id;
        ProductCategoryProduct veryNewProductLink = new ProductCategoryProduct(ProductId = veryNewProduct.Id, ProductCategoryId = testCategoryId);
        insert veryNewProductLink;
        
      
        Test.startTest();
        B2B_RemoveNewProductsBatch batchJob = new B2B_RemoveNewProductsBatch();
        Database.executeBatch(batchJob, 10);
        Test.stopTest();
        
        
        List<ProductCategoryProduct> remainingProductLinks = [SELECT Id, ProductId, ProductCategoryId FROM ProductCategoryProduct where ProductId = :veryNewProduct.Id ];
        System.assertEquals(1, remainingProductLinks.size(), 'No records should be deleted because all products are within the date range.');
    }
}