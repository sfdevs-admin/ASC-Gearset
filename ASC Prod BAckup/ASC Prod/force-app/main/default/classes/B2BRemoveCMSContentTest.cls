/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 27-03-2025
 * @last modified by  : Mradul Maheshwari
 **/
@isTest
public class B2BRemoveCMSContentTest {
  @isTest
  static void testRemoveCMSContent_noMedia() {
    Product2 product = new Product2(
      Name = 'Product With No Media',
      IsActive = true
    );
    insert product;

    Test.startTest();
    B2BRemoveCMSContent.removeCMSContent(new List<Id>{ product.Id });
    Test.stopTest();

    System.assertEquals(
      0,
      [SELECT COUNT() FROM ProductMedia WHERE ProductId = :product.Id]
    );
  }

  @isTest
  static void testRemoveCMSContent_emptyInput() {
    Test.startTest();
    B2BRemoveCMSContent.removeCMSContent(new List<Id>());
    Test.stopTest();

    System.assert(true, 'Should handle empty input without error.');
  }
}