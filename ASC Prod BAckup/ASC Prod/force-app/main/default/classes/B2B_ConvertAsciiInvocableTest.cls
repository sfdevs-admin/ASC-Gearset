@isTest
public class B2B_ConvertAsciiInvocableTest {
    
    @isTest
    static void testConvertProductFormulas() {
        // Create test data
        Product2 testProduct = new Product2(Name='Test Product', Index_Formula__c='TestöIndexòFormula', Formula__c='TestûFormula');
        insert testProduct;
        
        // Create a request with the test Product2 record
        B2B_ConvertAsciiInvocable.Request request = new B2B_ConvertAsciiInvocable.Request();
        request.product = testProduct;
        
        // Create a list to pass to the invocable method
        List<B2B_ConvertAsciiInvocable.Request> requests = new List<B2B_ConvertAsciiInvocable.Request>();
        requests.add(request);
        
        // Invoke the method
        Test.startTest();
        B2B_ConvertAsciiInvocable.convertProductFormulas(requests);
        Test.stopTest();
        
        // Retrieve the updated product
        Product2 updatedProduct = [SELECT Index_Formula_Site__c, Index_Formula_Text__c, Formula_Site__c, Formula_Text__c 
                                   FROM Product2 WHERE Id = :testProduct.Id];
        
        // Verify the results
        String expectedIndexFormulaSite = 'Test\u2080Index\u2081Formula';
        String expectedIndexFormulaText = 'Test0Index1Formula';
        String expectedFormulaSite = 'Test\u2082Formula';
        String expectedFormulaText = 'Test2Formula';
        
        System.assertEquals(expectedIndexFormulaSite, updatedProduct.Index_Formula_Site__c);
        System.assertEquals(expectedIndexFormulaText, updatedProduct.Index_Formula_Text__c);
        System.assertEquals(expectedFormulaSite, updatedProduct.Formula_Site__c);
        System.assertEquals(expectedFormulaText, updatedProduct.Formula_Text__c);
    }
    
    @isTest
    static void testEmptyFields() {
        // Create test data with empty fields
        Product2 testProduct = new Product2(Name='Empty Fields Product');
        insert testProduct;
        
        // Create a request with the test Product2 record
        B2B_ConvertAsciiInvocable.Request request = new B2B_ConvertAsciiInvocable.Request();
        request.product = testProduct;
        
        // Create a list to pass to the invocable method
        List<B2B_ConvertAsciiInvocable.Request> requests = new List<B2B_ConvertAsciiInvocable.Request>();
        requests.add(request);
        
        // Invoke the method
        Test.startTest();
        B2B_ConvertAsciiInvocable.convertProductFormulas(requests);
        Test.stopTest();
        
        // Retrieve the updated product
        Product2 updatedProduct = [SELECT Name, Index_Formula_Site__c, Index_Formula_Text__c, Formula_Site__c, Formula_Text__c 
                                   FROM Product2 WHERE Id = :testProduct.Id];
        
        // Verify the results
        System.assertEquals('Empty Fields Product', updatedProduct.Name);
        System.assertEquals(null, updatedProduct.Index_Formula_Site__c);
        System.assertEquals(null, updatedProduct.Index_Formula_Text__c);
        System.assertEquals(null, updatedProduct.Formula_Site__c);
        System.assertEquals(null, updatedProduct.Formula_Text__c);
    }
}