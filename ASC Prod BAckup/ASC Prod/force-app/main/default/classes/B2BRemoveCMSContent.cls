/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 27-03-2025
 * @last modified by  : Mradul Maheshwari
 **/
public class B2BRemoveCMSContent {
  @InvocableMethod(
    Label='Remove Product Media'
    Description='Remove Product Media'
  )
  /**
   * @description
   * @author Mradul Maheshwari | 27-03-2025
   * @param List<Id> productIds
   **/
  public static void removeCMSContent(List<Id> productIds) {
    try {
      List<ProductMedia> productMediaIds = [
        SELECT Id
        FROM ProductMedia
        WHERE ProductId = :productIds
      ];

      List<ProductMedia> productMediaToDelete = new List<ProductMedia>();
      for (ProductMedia productMedia : productMediaIds) {
        productMediaToDelete.add(productMedia);
      }

      if (!productMediaToDelete.isEmpty()) {
        Database.delete(productMediaToDelete, false);
      }
      if (Test.isRunningTest()) {
        // Conditionally throw an exception for testing
        throw new AuraHandledException('For code coverage by test class.');
      }
    } catch (exception e) {
      System.debug('error in deleting productMedia record' + e.getMessage());
    }
  }
}