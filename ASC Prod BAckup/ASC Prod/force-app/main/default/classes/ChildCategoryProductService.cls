/**
 * @description       : 
 * @author            : Mradul Maheshwari
 * @group             : 
 * @last modified on  : 07-08-2025
 * @last modified by  : Mradul Maheshwari
**/
public with sharing class ChildCategoryProductService {
    
      public class ProductWrapper {
        @AuraEnabled public Id categoryId;
        @AuraEnabled public String categoryName;
        
        public ProductWrapper(Id id, String name) {
            this.categoryId = id;
            this.categoryName = name;
            
        }
    }
     @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getChildCategories(Id parentId) {
          List<ProductWrapper> wrapperList = new List<ProductWrapper>();

           //List<ProductWrapper> wrapperList = new List<ProductWrapper>();

        // Step 1: Get all subcategories under the given parent (including grandChildrens)
        List<ProductCategory> directChildrens = [
            SELECT Id, Name FROM ProductCategory WHERE ParentCategoryId = :parentId
        ];

        if (directChildrens.isEmpty()) return wrapperList;

        Set<Id> allCategoryIds = new Set<Id>();
        Map<Id, String> idToNameMap = new Map<Id, String>();

        for (ProductCategory currentCategory : directChildrens) {
            allCategoryIds.add(currentCategory.Id);
            idToNameMap.put(currentCategory.Id, currentCategory.Name);
        }

        // Step 2: Get grandChildrens (children of the above)
        List<ProductCategory> grandChildrens = [
            SELECT Id, Name, ParentCategoryId FROM ProductCategory WHERE ParentCategoryId IN :allCategoryIds
        ];

        for (ProductCategory currentCategory : grandChildrens) {
            allCategoryIds.add(currentCategory.Id);
            // Only add the direct child's name to display
            if (!idToNameMap.containsKey(currentCategory.ParentCategoryId)) continue;
        }

        // Step 3: Get all categories with products from these children/grandChildrens
        List<AggregateResult> productCounts = [
            SELECT ProductCategoryId
            FROM ProductCategoryProduct 
            WHERE ProductCategoryId IN :allCategoryIds
            GROUP BY ProductCategoryId
        ];

        Set<Id> categoryIdsWithProducts = new Set<Id>();
        for (AggregateResult ar : productCounts) {
            categoryIdsWithProducts.add((Id) ar.get('ProductCategoryId'));
        }

        // Step 4: Check which direct children or their grandChildrens had products
        // and return only direct children whose subtree has product(s)
        for (ProductCategory child : directChildrens) {
            Boolean hasProduct = false;

            // Check if direct child has product
            if (categoryIdsWithProducts.contains(child.Id)) {
                hasProduct = true;
            } else {
                // Check if any of its children (grandChildrens of original parent) has product
                for (ProductCategory grandChild : grandChildrens) {
                    if (grandChild.ParentCategoryId == child.Id && categoryIdsWithProducts.contains(grandChild.Id)) {
                        hasProduct = true;
                        break;
                    }
                }
            }

            if (hasProduct) {
                wrapperList.add(new ProductWrapper(child.Id, child.Name));
            }
        }

        return wrapperList;
    }
}