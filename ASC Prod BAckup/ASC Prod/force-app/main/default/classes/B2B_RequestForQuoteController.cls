/**
* @description       : 
* @author            : Usha.hj
* @group             : 
* @last modified on  : 17-12-2025
* @last modified by  : Mradul Maheshwari
**/
public without sharing class B2B_RequestForQuoteController {
    public B2B_RequestForQuoteController() {
        
    } 
    
    @AuraEnabled
    public static Map<String,Object> createQuote(Map<String,Object> mapParams){
        try {
            B2B_RequestForQuoteService.createQuote(mapParams);
        } catch (Exception e) {
            mapParams = mapParams == null ? new Map<String,Object>() : mapParams;
            mapParams.put('isSuccess',false);
            mapParams.put('message',e.getMessage());
        }
        return mapParams;
    }
    
    @AuraEnabled(cacheable=true)
    public static Product2 getProductDetails(String catalogNumber) { 
        // String userId = UserInfo.getUserId();
        
            Product2 product = [SELECT Id, parent_Sku__c,CurrencyIsoCode, CAS__c, Product_Description__c ,StockKeepingUnit 
                                FROM Product2 
                                WHERE parent_Sku__c = :catalogNumber
                                OR StockKeepingUnit = :catalogNumber
                                LIMIT 1];
            System.debug('product details'+product);
            return product;
        } 
    
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, List<String>>> getPicklist(Map<String, List<String>> objectFieldMap) {
        Map<String, Map<String, List<String>>> picklistValuesMap = new Map<String, Map<String, List<String>>>();
        
        try {
            for (String objectName : objectFieldMap.keySet()) {
            
                Map<String, List<String>> fieldValuesMap = new Map<String, List<String>>();
                List<String> fieldNames = objectFieldMap.get(objectName);
                
                Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
                Schema.DescribeSObjectResult describeSObjectResult = sObjectType.getDescribe();
                Map<String, Schema.SObjectField> fieldMap = describeSObjectResult.fields.getMap();
                
                for (String fieldName : fieldNames) {
                    List<String> picklistValues = new List<String>();
                    Schema.SObjectField sObjectField = fieldMap.get(fieldName);
                    Schema.DescribeFieldResult describeFieldResult = sObjectField.getDescribe();
                    List<Schema.PicklistEntry> picklistEntries = describeFieldResult.getPicklistValues();
                    
                    for (Schema.PicklistEntry picklistEntry : picklistEntries) {
                        picklistValues.add(picklistEntry.getLabel());
                    }
                    fieldValuesMap.put(fieldName, picklistValues);
                }
                picklistValuesMap.put(objectName, fieldValuesMap);
            }
         
        } catch (Exception e) {
             Map<String, Object> inputParams = new Map<String, Object>{
                'objectFieldMap' => objectFieldMap
             };
             AscensusHandleCustomException.LogCustomException(e, inputParams, 'B2B_RequestForQuoteController', 'getPicklist');
            // AscensusHandleCustomException.LogException(e, 'B2B_RequestForQuoteController', 'getPicklist');
            System.debug('Error fetching picklist values: ' + e.getMessage());
        }
        System.debug('picklistValuesMap' + picklistValuesMap);
        return picklistValuesMap;
    }
    
    // public static String getUserAccountID(String userId) {
    public static String getUserAccountID() {
        String userId = UserInfo.getUserId(); 
        String contactId = [SELECT ContactId FROM User WHERE Id = :userId]?.ContactId;
        String accountId = [SELECT AccountId FROM Contact WHERE Id = :contactId]?.AccountId;
        System.debug('accountId'+accountId);
        return accountId;
    }
    
    @AuraEnabled
    public static Map<String, Object> createAccountAndContact(String quoteJson) {
        
        System.debug('quoteJson: ' + quoteJson);  
        
        // Deserialize JSON string to QuoteWrapper object
        QuoteWrapper quoteWrapper = (QuoteWrapper) JSON.deserialize(quoteJson, QuoteWrapper.class);
        // String currencyIsoCode = 'USD';
        //SCC-25 changes start
        String currencyIsoCode;
        currencyIsoCode = quoteWrapper.currencyCode;
        //SCC-25 changes end

        String quoteState = quoteWrapper.State != NULL || quoteWrapper.State != '' ? quoteWrapper.State : quoteWrapper.Province;
        try {
            Account newAcc = new Account(
                Name = quoteWrapper.CompanyName,
                CurrencyIsoCode = currencyIsoCode,
                BillingStreet = quoteWrapper.Address,
                ShippingStreet = quoteWrapper.Address,
                BillingCity = quoteWrapper.City,
                ShippingCity = quoteWrapper.City,
                BillingState = quoteState,
                ShippingState = quoteState,
                BillingPostalCode = quoteWrapper.PostalCode,
                ShippingPostalCode = quoteWrapper.PostalCode,
                BillingCountry = quoteWrapper.Country,
                ShippingCountry = quoteWrapper.Country
            );
            System.debug('newAcc: ' + newAcc);
            upsert newAcc;
            
            // Create Contact
            Contact newCon = new Contact(
                AccountId = newAcc.Id,
                LastName = quoteWrapper.LastName,
                CurrencyIsoCode = currencyIsoCode,
                MailingStreet = quoteWrapper.Address,
                OtherStreet = quoteWrapper.Address,
                MailingCity = quoteWrapper.City,
                OtherCity = quoteWrapper.City,
                MailingState = quoteState,
                OtherState = quoteState,
                MailingPostalCode = quoteWrapper.PostalCode,
                OtherPostalCode = quoteWrapper.PostalCode,
                MailingCountry = quoteWrapper.Country,
                OtherCountry = quoteWrapper.Country
                // Set other fields
            );
            upsert newCon;
            
            // Return both the Quote and the QuoteLineItems
            Map<String, Object> returnData = new Map<String, Object>();
            returnData.put('account', newAcc);
            returnData.put('contact', newCon);
            return returnData;
            
        }catch (Exception e) {
             Map<String, Object> inputParams = new Map<String, Object>{
                'quoteWrapper' => quoteWrapper
             };
             AscensusHandleCustomException.LogCustomException(e, inputParams, 'B2B_RequestForQuoteController', 'createAccountAndContact');
         //AscensusHandleCustomException.LogException(e, 'B2B_RequestForQuoteController', 'createAccountAndContact');
          throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Boolean isGuestUser() {
        return UserInfo.getUserType() == 'Guest';
    }
    
    @AuraEnabled
    // public static Quote saveQuoteWithLineItems(String quoteJson , String quoteLineJson) {
    public static Map<String, Object> saveQuoteWithLineItems(String quoteJson) {
        
        System.debug('quoteJson: ' + quoteJson);  
        
        // Deserialize JSON string to QuoteWrapper object
        QuoteWrapper quoteWrapper = (QuoteWrapper) JSON.deserialize(quoteJson, QuoteWrapper.class);
        system.debug('quoteWrapper => '+ quoteWrapper);
        String accountIdofuser;
        String accountId;
        String currencyIsoCode;
        system.debug('UserInfo.getUserType => '+UserInfo.getUserType());
        system.debug('UserInfo.getUserType => '+isGuestUser());
        try{
            if( (quoteWrapper.isGuest && isGuestUser()) || String.isEmpty(getUserAccountID()) ){
                //if guest user, create new account and get id
                Map<String, Object> accMap = createAccountAndContact(quoteJson);
                Account acc = (Account) accMap.get('account');
                accountIdofuser = acc.Id;
            }else{
                //if logged in user, get accountId
                accountIdofuser = getUserAccountID();
            }
            
            accountId = accountIdofuser;
            System.debug('AccountId: ' + accountId);
            //SCC-25 changes start
            // currencyIsoCode = 'USD';
            currencyIsoCode = quoteWrapper.currencyCode;
            //SCC-25 changes end
        }catch(Exception e){
              Map<String, Object> inputParams = new Map<String, Object>{
                'quoteWrapper' => quoteWrapper
             };
             AscensusHandleCustomException.LogCustomException(e, inputParams, 'B2B_RequestForQuoteController', 'saveQuoteWithLineItems');
           // AscensusHandleCustomException.LogException(e, 'B2B_RequestForQuoteController', 'saveQuoteWithLineItems');
            //throw new AuraHandledException(e.getMessage());
              Map<String, Object> returnData = new Map<String, Object>();
              returnData.put('isSuccess', false);
                returnData.put('errorMessage', e.getMessage());
                return returnData;
        }
        
        
        try {
            Quote newQuote = new Quote();
            List<QuoteLineItem> quoteLineItemsToInsert = new List<QuoteLineItem>();
            
            newQuote.Company_Name__c = quoteWrapper.CompanyName;
            newQuote.Address__c = quoteWrapper.Address;
            newQuote.City__c = quoteWrapper.City;
            newQuote.Province__c = quoteWrapper.Province;
            newQuote.Postal_Code__c = quoteWrapper.PostalCode;//create field in quote
            newQuote.QuoteCountry__c = quoteWrapper.Country;
            newQuote.Email = quoteWrapper.Email;
            newQuote.Phone = quoteWrapper.Phone;
            // newQuote.Fax = quoteWrapper.Fax;
            // newQuote.Salutation__c = quoteWrapper.Salutation;
            newQuote.First_Name__c = quoteWrapper.FirstName;
            // newQuote.Middle_initial__c = quoteWrapper.MiddleInitial;
            newQuote.Last_Name__c = quoteWrapper.LastName;
            newQuote.QuoteState__c = quoteWrapper.State;
            //ticket STACK-293 starts
            newQuote.Quote_Source__c = 'Ascensus Store';
            newQuote.Customer_Account_Number__c = quoteWrapper.AccountNumber;
            newQuote.Billing_Address__c = quoteWrapper.BillingAddress;
            newQuote.Billing_City__c = quoteWrapper.BillingCity;
            newQuote.BillingState__c = quoteWrapper.BillingState;
            newQuote.Billing_Postal_Code__c = quoteWrapper.BillingPostalCode;
            newQuote.BillingCountry__c	 = quoteWrapper.BillingCountry;
            newQuote.Billing_Province__c = quoteWrapper.BillingProvince;
            newQuote.Desired_Shipment_Date__c = quoteWrapper.DesiredShipmentDate;
            //ticket STACK-293 ends
            newQuote.B2B_Cart_Id__c = quoteWrapper.cartId;
            newQuote.CurrencyIsoCode = currencyIsoCode;
            
            // Fetch PricebookEntries for products in quoteLineItems
            List<String> catalogNumbers = new List<String>();
            for (QuoteLineItemWrapper qliWrapper : quoteWrapper.quoteLineItems) {
                if(qliWrapper.CatalogNumber != null){
                    catalogNumbers.add(qliWrapper.CatalogNumber);
                    System.debug('catalogNumbers1'+catalogNumbers);
                }
            }
            System.debug('catalogNumbers'+catalogNumbers);
            
            Map<String, String> productIdToPbeId = new Map<String, String>();
            String defaultProductId = System.label.B2B_Request_a_Quote_Default_Product;
            //SCC-25 changes start
            // List<PricebookEntry> pricebookEntries = Test.isRunningTest() ? [SELECT Id, Product2Id,Product2.parent_Sku__c,CurrencyIsoCode,Pricebook2Id, UnitPrice FROM PricebookEntry WHERE Product2.parent_Sku__c IN :catalogNumbers LIMIT 1] : [SELECT Id, Product2Id,Product2.parent_Sku__c,CurrencyIsoCode,Pricebook2Id, UnitPrice FROM PricebookEntry WHERE (Product2.parent_Sku__c IN :catalogNumbers OR Product2.Id = :defaultProductId) AND IsActive = true AND CurrencyIsoCode = 'USD' AND Pricebook2.isStandard = true]; // Replace 'YOUR_PRICEBOOK_ID' with the appropriate Pricebook ID
            List<PricebookEntry> pricebookEntries = Test.isRunningTest() ? [SELECT Id, Product2Id,Product2.parent_Sku__c,Product2.StockKeepingUnit,CurrencyIsoCode,Pricebook2Id, UnitPrice FROM PricebookEntry WHERE Product2.parent_Sku__c IN :catalogNumbers LIMIT 1] 
                                                                    : [SELECT Id, Product2Id,Product2.parent_Sku__c,CurrencyIsoCode,Pricebook2Id, UnitPrice FROM PricebookEntry WHERE (Product2.parent_Sku__c IN :catalogNumbers OR Product2.Id = :defaultProductId OR Product2.StockKeepingUnit IN :catalogNumbers)  AND IsActive = true AND CurrencyIsoCode = :currencyIsoCode AND Pricebook2.isStandard = true]; // Replace 'YOUR_PRICEBOOK_ID' with the appropriate Pricebook ID
            //SCC-25 changes end
            System.debug('pricebookEntries'+pricebookEntries);
            for(PricebookEntry pbe: pricebookEntries){
                productIdToPbeId.put(pbe.Product2Id, pbe.Id);
            }
            System.debug('productIdToPbeId'+productIdToPbeId);
            // Check if OpportunityId is provided
            if (newQuote.OpportunityId == null) {
                // Creating a new Opportunity
                Id recordTypeSales = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
                Opportunity opp = new Opportunity(
                    Name = 'Auto-generated Opportunity',
                    AccountId = accountId,
                    ForecastCategoryName = 'Pipeline',
                    CloseDate = System.Today() + 30,
                    StageName = 'Development',
                    Product_Family__c = 'DSBH',
                    // Pricebook2Id = '01sVB0000007FaDYAU', 
                    Pricebook2Id = pricebookEntries[0].Pricebook2Id,
                    CurrencyIsoCode = currencyIsoCode,
                    //ticket STACK-293 starts
                    LeadSource = 'Ascensus Store',
                    //ticket STACK-293 ends
                    RecordTypeId = recordTypeSales
                );
                System.debug('Opp: ' + opp);
                insert opp;
                
                newQuote.OpportunityId = opp.Id;
                System.debug('newQuote.OpportunityId: ' + newQuote.OpportunityId);
            }
            
            // Populate the Quote Name if it is blank
            if (String.isBlank(newQuote.Name)) {
                newQuote.Name = 'Quote-' + newQuote.OpportunityId;
                System.debug('Name: ' + newQuote.Name);
            }
            
            // Insert the Quote
            insert newQuote;

            for (QuoteLineItemWrapper qliWrapper : quoteWrapper.quoteLineItems) {
                if(qliWrapper!=null){
                    
                    if(qliWrapper.LineItemId !=null && !String.isEmpty(qliWrapper.LineItemId)){ //&& qliWrapper.Id != '01t2E00000OXVDFQA5'
                        Decimal unitPriceFromApi = 0;
                        if (qliWrapper.unitPrice != null && qliWrapper.unitPrice != 0) {
                            unitPriceFromApi = qliWrapper.unitPrice;
                        }

                        QuoteLineItem qli = new QuoteLineItem(
                            QuoteId = newQuote.Id,
                            Product2Id = qliWrapper.LineItemId,
                            // Product2Id = pricebookEntries[1].Product2Id, // Assign Product2Id
                            Catalog_Number__c = qliWrapper.CatalogNumber,
                            CAS_Number__c = qliWrapper.CasNumber,
                            Description = qliWrapper.ProductDescription,
                            Unit_of_Measure__c = qliWrapper.SelectedUnityOfMeasure,
                            Quantity = qliWrapper.TotalQuantity,
                            CommentPurity__c = qliWrapper.CommentPurity,
                            Special_Instructions__c = qliWrapper.SpecialInstructions,
                            Chemical_Structure_SMILES_Code__c =  qliWrapper.ChemicalStructure,
                            Molecular_Formula__c = qliWrapper.MolecularFormula,
                            Molecular_Weight__c = Decimal.valueOf(qliWrapper.MolecularWeight != '' ? qliWrapper.MolecularWeight : '0'),
                            Grade__c = qliWrapper.SelectedGrade,
                            Demand_Type__c = qliWrapper.SelectedDemandType,
                            Technical_Publication_Reference__c = qliWrapper.TechnicalPublicationReference,
                            // UnitPrice = 0,
                            UnitPrice = unitPriceFromApi,
                            // if(!pricebookEntries.isEmpty()){
                            //PricebookEntryId = pricebookEntries[1].Id // Assign PricebookEntryId
                            // }
                            PricebookEntryId = productIdToPbeId.get(qliWrapper.LineItemId)
                        );
                        quoteLineItemsToInsert.add(qli);
                        System.debug('quoteLineItemsToInsert-->'+quoteLineItemsToInsert);
                    }
                    // else {
                    //     // Handle missing PricebookEntry
                    //     System.debug('PricebookEntry not found for CatalogNumber: ' + qliWrapper.CatalogNumber);
                    // }
                    
                    else if(qliWrapper.LineItemId == null || String.isBlank(qliWrapper.LineItemId)){ //|| qliWrapper.Id == '01t2E00000OXVDFQA5'
                        
                        System.debug('product not found'+qliWrapper.CatalogNumber);
                        String defaultPbeIdUSD = System.label.B2B_Request_a_Quote_Default_Product_Pricebook_Entry;
                        String defaultPbeIdEUR = System.label.B2B_Request_a_Quote_Default_Product_Pricebook_Entry_EUR;
                        String defaultPriceBookEntryId = quoteWrapper.currencyCode == 'EUR' ?  defaultPbeIdEUR  : defaultPbeIdUSD;
                        System.debug('defaultPbeIdUSD ='+defaultPbeIdUSD);
                        System.debug('qliWrapper.MolecularWeight' + qliWrapper.MolecularWeight);

                        QuoteLineItem qli = new QuoteLineItem(
                            QuoteId = newQuote.Id,
                            Product2Id = defaultProductId, // Assigning PlaceHolder productId
                            Catalog_Number__c = qliWrapper.CatalogNumber,
                            CAS_Number__c = qliWrapper.CasNumber,
                            Description = qliWrapper.ProductDescription,
                            Unit_of_Measure__c = qliWrapper.SelectedUnityOfMeasure,
                            Quantity = qliWrapper.TotalQuantity,
                            CommentPurity__c = qliWrapper.CommentPurity,
                            Special_Instructions__c = qliWrapper.SpecialInstructions,
                             Chemical_Structure_SMILES_Code__c =  qliWrapper.ChemicalStructure,
                            Molecular_Formula__c = qliWrapper.MolecularFormula,
                            Molecular_Weight__c =Decimal.valueOf(qliWrapper.MolecularWeight != '' ? qliWrapper.MolecularWeight : '0'),
                            Grade__c = qliWrapper.SelectedGrade,
                            Demand_Type__c = qliWrapper.SelectedDemandType,
                           Technical_Publication_Reference__c = qliWrapper.TechnicalPublicationReference,
                            UnitPrice = 0,
                            // if(!pricebookEntries.isEmpty()){
                            //PricebookEntryId = pricebookEntries[1].Id // Assign PricebookEntryId
                            // }
                            PricebookEntryId = !String.isBlank(defaultPriceBookEntryId) ? defaultPriceBookEntryId : productIdToPbeId.get(qliWrapper.LineItemId)
                        );
                        quoteLineItemsToInsert.add(qli);
                        System.debug('quoteLineItemsToInsert inside else --->'+quoteLineItemsToInsert);
                    }
                }
            }
            
            // Insert QuoteLineItems  
            if (!quoteLineItemsToInsert.isEmpty()) {
                System.debug('QuoteLineItems inserted: ' + quoteLineItemsToInsert);
                insert quoteLineItemsToInsert;
                
            }
            
            // Return both the Quote and the QuoteLineItems
            Map<String, Object> returnData = new Map<String, Object>();
            returnData.put('quote', newQuote);
            returnData.put('quoteLineItems', quoteLineItemsToInsert);
            returnData.put('isSuccess', true);
            
            return returnData;
        } catch (Exception e) {
              Map<String, Object> inputParams = new Map<String, Object>{
                'quoteWrapper' => quoteWrapper
             };
             AscensusHandleCustomException.LogCustomException(e, inputParams, 'B2B_RequestForQuoteController', 'saveQuoteWithLineItems');
            //AscensusHandleCustomException.LogException(e, 'B2B_RequestForQuoteController', 'saveQuoteWithLineItems');
            System.debug('exception ' + e.getMessage());
              Map<String, Object> returnData = new Map<String, Object>();
              returnData.put('isSuccess', false);
                returnData.put('errorMessage', e.getMessage());
                return returnData;

           // throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    public class QuoteWrapper {
        public Boolean isGuest { get; set; }
        public String CompanyName { get; set; }
        public String Address { get; set; }
        public String BillingAddress {get ; set;}
        // public String Salutation { get; set; }
        public String FirstName { get; set; }
        public String City { get; set; }
        public String BillingCity {get; set;}
        
        // public String MiddleInitial { get; set; }
        public String LastName { get; set; }
        public String Province { get; set; }
        public String BillingProvince {get; set;}
        public String Email { get; set; }
        public String Phone { get; set; }
        public String PostalCode { get; set; }
        public String BillingPostalCode {get; set;}
        public Date  DesiredShipmentDate { get; set; }
       

        public String AccountNumber { get; set; }
        // public String Fax { get; set; }
        public String Country { get; set; }
        public String BillingCountry {get; set;}

        public String State { get; set; }
        public String BillingState {get; set;}

        public List<QuoteLineItemWrapper> quoteLineItems { get; set; } // Add this field
        //SCC-25 changes start
        public String currencyCode { get; set; }
        //SCC-25 changes end

        public String cartId { get; set; }
    }
    
    public class QuoteLineItemWrapper {
        public String CatalogNumber { get; set; }
        public String CasNumber { get; set; }
        public String ProductDescription { get; set; }
        public String SelectedUnityOfMeasure { get; set; }
        public Decimal TotalQuantity { get; set; }
        public String CommentPurity { get; set; }
        public String SpecialInstructions { get; set; }
        public String molecularFormula { get; set; }
        public String selectedGrade  {get; set; }
        public String selectedDemandType { get; set; }
        public String chemicalStructure { get; set; }
        public String molecularWeight { get; set; }
        public String technicalPublicationReference {get; set;}
        public Decimal unitPrice {get; set;}

        public String LineItemId { get; set; }
    }

}