/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 09-06-2025
 * @last modified by  : Mradul Maheshwari
 **/
@isTest
public class B2B_BreadcrumbsTest {
  @isTest
  static void testGetCategories_Success() {
    // Create mock Product2
    Product2 prod = new Product2(
      Name = 'Test Product',
      Parent_Sku__c = 'TESTSKU'
    );
    insert prod;
    ProductCatalog productCatalog = new ProductCatalog(Name = 'Test Catalog');
    insert productCatalog;

    // Create mock ProductCategory
    ProductCategory parentCat = new ProductCategory(
      Name = 'Material Science',
      CatalogId = productCatalog.Id
    );
    insert parentCat;

    ProductCategory childCat = new ProductCategory(
      Name = 'Catalysts',
      ParentCategoryId = parentCat.Id,
      CatalogId = productCatalog.Id
    );
    insert childCat;

    // Create ProductCategoryProduct
    ProductCategoryProduct pcp = new ProductCategoryProduct(
      ProductId = prod.Id,
      ProductCategoryId = childCat.Id,
      External_Id__c = 'TEST-EXT-ID'
    );
    insert pcp;

    // Run method
    Test.startTest();
    List<ProductCategoryProduct> result = B2B_Breadcrumbs.getCategories(
      prod.Id
    );
    Test.stopTest();

    System.assertNotEquals(null, result);
    System.assertEquals(1, result.size());
    System.assertEquals(prod.Id, result[0].ProductId);
  }

  @isTest
  static void testGetCategories_ExceptionPath() {
    // Intentionally pass invalid ID to trigger catch block
    Test.startTest();
    try {
      B2B_Breadcrumbs.getCategories(null);
      System.assert(false, 'Expected exception was not thrown');
    } catch (AuraHandledException ex) {
      System.debug(ex.getMessage().contains('null'));
    }
    Test.stopTest();
  }
}