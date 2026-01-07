/**
* @description       : 
* @author            : Swati Chilap
* @group             : 
* @last modified on  : 25-08-2025
* @last modified by  : Swati Chilap
**/
@isTest
public with sharing class B2B_GoogleTrackingControllerTest {
    @testSetup
    static void setupData() {
        Product2 p = new Product2(Name = 'Test Product', IsActive = true);
        insert p;
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact c = new Contact(LastName = 'Test Contact', AccountId = acc.Id, Email = 'test@example.com');
        insert c;
    }

    @isTest
    static void testCreateGMCRecord_WithContact_NotGuest() {
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Map<String, Object> params = new Map<String, Object>{
            'productId' => p.Id,
            'contactId' => c.Id,
            'gmcKey'    => 'TestKey123',
            'isGuest'   => false
        };

        Test.startTest();
        Map<String, Object> result = B2B_GoogleTrackingController.createGMCRecord(params);
        Test.stopTest();

        System.assertEquals(true, result.get('isSuccess'));
        System.assertEquals('Record created successfully', result.get('message'));
        System.assertNotEquals(null, result.get('recordId'));

        B2B_Google_Merchant_Center__c gmc = [
            SELECT Id, B2B_Product__c, B2B_Contact__c, B2B_Key__c
            FROM B2B_Google_Merchant_Center__c
            WHERE Id = : (Id)result.get('recordId')
        ];
        System.assertEquals(p.Id, gmc.B2B_Product__c);
        System.assertEquals(c.Id, gmc.B2B_Contact__c);
        System.assertEquals('TestKey123', gmc.B2B_Key__c);
    }

    @isTest
    static void testCreateGMCRecord_GuestUser_ShouldSkipContact() {
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Map<String, Object> params = new Map<String, Object>{
            'productId' => p.Id,
            'contactId' => c.Id,
            'gmcKey'    => 'GuestKey123',
            'isGuest'   => true
        };

        Map<String, Object> result = B2B_GoogleTrackingController.createGMCRecord(params);

        System.assertEquals(true, result.get('isSuccess'));
        B2B_Google_Merchant_Center__c gmc = [
            SELECT Id, B2B_Product__c, B2B_Contact__c
            FROM B2B_Google_Merchant_Center__c
            WHERE Id = : (Id)result.get('recordId')
        ];
        System.assertEquals(null, gmc.B2B_Contact__c, 'Contact should be skipped for guest user');
    }

    @isTest
    static void testCreateGMCRecord_ExceptionCase() {
        // Invalid ProductId to cause an exception
        Map<String, Object> params = new Map<String, Object>{
            'productId' => 'invalidId',
            'contactId' => null,
            'gmcKey'    => 'ErrorKey123',
            'isGuest'   => false
        };

        Map<String, Object> result = B2B_GoogleTrackingController.createGMCRecord(params);

        System.assertEquals(false, result.get('isSuccess'));
        System.assert(((String)result.get('message')).startsWith('Error:'));
    }
}