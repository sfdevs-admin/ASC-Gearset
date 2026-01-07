/**
 * @description       : 
 * @author            : Mradul Maheshwari
 * @group             : 
 * @last modified on  : 15-05-2025
 * @last modified by  : Mradul Maheshwari
**/
@IsTest
public class B2B_ExactSearchResultControllerTest {
    
    @TestSetup
    static void setupTestData() {
        
        B2B_Custom_Search_Filter__c filter1 = new B2B_Custom_Search_Filter__c(
            Field__c = 'Name',
            Exact_Match__c = true,
            Sort_Order__c = 1
        );
        insert filter1;

        B2B_Custom_Search_Filter__c filter2 = new B2B_Custom_Search_Filter__c(
            Field__c = 'ProductCode',
            Exact_Match__c = false,
            Sort_Order__c = 2
        );
        insert filter2;
    }

    // Test case for getExactSearchResult (success scenario)
    @IsTest
    static void testGetExactSearchResult_Success() {
        
        
    
        Map<Object, Object> searchResult = new Map<Object, Object>();
        searchResult.put('cardCollection', new List<Object>{
            new Map<Object, Object>{
                'id' => 'prod123',
                'fields' => new Map<Object, Object>{
                    'Name' => new Map<Object, Object>{'value' => 'Test Product'},
                    'ProductCode' => new Map<Object, Object>{'value' => 'Test123'}
                }
            }
        });

        Map<String, Object> dataMap = new Map<String, Object>{
            'searchTerm' => 'Test',
            'searchResult' => searchResult
        };

        Test.startTest();
        Map<String, Object> result = B2B_ExactSearchResultController.getExactSearchResult(dataMap);
        Test.stopTest();

        System.debug(result);
        }

    // Test case for getExactSearchResult (no exact match scenario)
    @IsTest
    static void testGetExactSearchResult_NoExactMatch() {
       
         Map<Object, Object> searchResult = new Map<Object, Object>();
        searchResult.put('cardCollection', new List<Object>{
            new Map<Object, Object>{
                'id' => 'prod123',
                'fields' => new Map<Object, Object>{
                    'Name' => new Map<Object, Object>{'value' => 'Test Product'},
                    'ProductCode' => new Map<Object, Object>{'value' => 'Test123'}
                }
            }
        });

      

        Map<String, Object> dataMap = new Map<String, Object>{
            'searchTerm' => 'Test Product',
            'searchResult' => searchResult
        };

        Test.startTest();
          Map<String, Object> result = B2B_ExactSearchResultController.getExactSearchResult(dataMap);
        Test.stopTest();


        Map<Object, Object> exactSearchResult = (Map<Object, Object>)result.get('exactSearchResult');
        List<Object> exactMatchCards = (List<Object>)exactSearchResult.get('cardCollection');
        //System.assertEquals(0, exactMatchCards.size(), 'There should be no exact matches');

   
        Map<Object, Object> suggestedSearchResult = (Map<Object, Object>)result.get('suggestedSearchResult');
        List<Object> suggestedMatchCards = (List<Object>)suggestedSearchResult.get('cardCollection');
        //System.assertEquals(1, suggestedMatchCards.size(), 'There should be 1 suggested match');
    }

    
 @IsTest
    static void testGetExactSearchResult_Failure() {

        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('searchTerm', 'Test Search');

        // Simulate failure scenario
        Test.startTest();
        dataMap.put('isSuccess', false);
        B2B_ExactSearchResultController.getExactSearchResult(dataMap); 
        // Verify that the controller returned failure
        //System.assertEquals(false, result.get('isSuccess'));
        Test.stopTest();
    }

  
   
}