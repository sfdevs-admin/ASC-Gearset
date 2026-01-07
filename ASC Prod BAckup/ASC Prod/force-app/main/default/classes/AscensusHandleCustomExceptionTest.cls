/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 10-06-2025
 * @last modified by  : Swati Chilap
 **/
@isTest
public class AscensusHandleCustomExceptionTest {
  public class AscensusCustomException extends Exception {
  }

  @isTest
  static void testLogExceptionWithoutRelatedToId() {
    // Create a new custom exception
    AscensusCustomException testException = new AscensusCustomException(
      'Test exception message'
    );

    // Call the LogException method
    Test.startTest();
    AscensusHandleCustomException.LogException(
      testException,
      'TestCategory',
      'TestSubcategory'
    );
    Test.stopTest();
  }
  @isTest
  static void testCreateLogErrorRecord() {
    Test.startTest();
    AscensusHandleCustomException.createLogErrorRecord(
      'Test Error',
      'This is a test error message',
      'EmailUtility',
      'testMethod'
    );
    Test.stopTest();

    Ascensus_Custom_Exception__c log = [
      SELECT Id
      FROM Ascensus_Custom_Exception__c
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      log,
      'Error log record should have been created.'
    );
  }
    
    @isTest
  static void testLogCustomExceptionWithoutRelatedToId() {
    // Create a new custom exception
    AscensusCustomException testException = new AscensusCustomException(
      'Test exception message'
    );
	
      Map<String, Object> inputParams = new Map<String, Object>{
          'catalogItemNumber' => 'test001'};
    // Call the LogException method
    Test.startTest();
    AscensusHandleCustomException.LogCustomException(
      testException,
       inputParams,
      'TestCategory',
      'TestSubcategory'
    );
    Test.stopTest();
  }


}