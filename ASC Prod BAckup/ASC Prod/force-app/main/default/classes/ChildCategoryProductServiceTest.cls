/**
 * @description       : 
 * @author            : Mradul Maheshwari
 * @group             : 
 * @last modified on  : 06-08-2025
 * @last modified by  : Mradul Maheshwari
**/
@isTest
private class ChildCategoryProductServiceTest {

    @isTest
    static void testGetChildCategories_WithProducts() {
        
        ProductCatalog catalog = new ProductCatalog(Name = 'Test Catalog');
        insert catalog;
        ProductCategory parentCategory = new ProductCategory(  Name = 'Parent',
            CatalogId = catalog.Id);
        insert parentCategory;

       
            
        ProductCategory child1 = new ProductCategory(Name = 'Child 1', ParentCategoryId = parentCategory.Id, CatalogId = catalog.Id);
        ProductCategory child2 = new ProductCategory(Name = 'Child 2', ParentCategoryId = parentCategory.Id, CatalogId = catalog.Id);
        insert new List<ProductCategory>{ child1, child2 };

     
        ProductCategory grandChild1 = new ProductCategory(Name = 'Grandchild 1', ParentCategoryId = child1.Id, CatalogId = catalog.Id);
        ProductCategory grandChild2 = new ProductCategory(Name = 'Grandchild 2', ParentCategoryId = child2.Id , CatalogId = catalog.Id);
        insert new List<ProductCategory>{ grandChild1, grandChild2 };

        
        Product2 product1 = new Product2(Name = 'Product 1', IsActive = true);
        insert product1;
        insert new ProductCategoryProduct(ProductId = product1.Id, ProductCategoryId = child1.Id);

        
        Product2 product2 = new Product2(Name = 'Product 2', IsActive = true);
        insert product2;
        insert new ProductCategoryProduct(ProductId = product2.Id, ProductCategoryId = grandChild2.Id);

        
        Test.startTest();
        List<ChildCategoryProductService.ProductWrapper> result =
            ChildCategoryProductService.getChildCategories(parentCategory.Id);
        Test.stopTest();

       
        Set<Id> returnedIds = new Set<Id>();
        for (ChildCategoryProductService.ProductWrapper wrapper : result) {
            returnedIds.add(wrapper.categoryId);
        }

        System.assertEquals(2, result.size(), 'Should return both children');
        System.assert(returnedIds.contains(child1.Id), 'Should contain child1');
        System.assert(returnedIds.contains(child2.Id), 'Should contain child2');
    }

    @isTest
    static void testGetChildCategories_NoChildren() {
        // No child categories exist
       ProductCatalog catalog = new ProductCatalog(Name = 'Solo Catalog');
        insert catalog;

        ProductCategory parentCategory = new ProductCategory(
            Name = 'Lonely Parent',
            CatalogId = catalog.Id
        );
        insert parentCategory;

        Test.startTest();
        List<ChildCategoryProductService.ProductWrapper> result =
            ChildCategoryProductService.getChildCategories(parentCategory.Id);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list if no children');
    }

    @isTest
    static void testGetChildCategories_ChildrenWithoutProducts() {
       
        ProductCatalog catalog = new ProductCatalog(Name = 'No Product Catalog');
    insert catalog;

    
    ProductCategory parentCategory = new ProductCategory(
        Name = 'Parent No Products',
        CatalogId = catalog.Id
    );
    insert parentCategory;
        ProductCategory child1 = new ProductCategory(Name = 'Child No Product', ParentCategoryId = parentCategory.Id, CatalogId = catalog.Id);
        insert child1;

        Test.startTest();
        List<ChildCategoryProductService.ProductWrapper> result =
            ChildCategoryProductService.getChildCategories(parentCategory.Id);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list if children have no products');
    }
}