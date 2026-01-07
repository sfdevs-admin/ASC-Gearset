/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 10-06-2025
 * @last modified by  : Mradul Maheshwari
 **/
public without sharing class B2B_Breadcrumbs {
  @AuraEnabled
  public static List<ProductCategoryProduct> getCategories(String productId) {
    try {
      String productSku = [
        SELECT Parent_Sku__c
        FROM Product2
        WHERE Id = :productId
      ]
      .Parent_Sku__c;
      List<ProductCategoryProduct> productCategories = [
        SELECT
          ProductCategoryId,
          ProductCategory.Name,
          ProductCategory.ParentCategory.Name,
          External_Id__c,
          ProductId,
          ProductCategory.ParentCategoryId,
          ProductCategory.CreatedDate,
          ProductCategory.ParentCategory.CreatedDate
        FROM ProductCategoryProduct
        WHERE Product.Parent_Sku__c = :productSku
      ];

      return productCategories;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}