/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 04-22-2024
 * @last modified by  : surya.thakur
**/
public with sharing class B2B_RequestForQuoteService {
    public B2B_RequestForQuoteService() {

    }

    public static Map<String,Object> createQuote(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        System.debug('createQuote mapParams-- '+JSON.serialize(mapParams));
        if( mapParams.containsKey('cartId') ){
            String cartId = (String) mapParams.get('cartId');
            List<WebCart> cartList = [SELECT Id, Status, CurrencyIsoCode, AccountId, CreatedBy.ContactId, WebStoreId FROM WebCart WHERE Id =: cartId LIMIT 1];
            if( ! cartList.isEmpty() ){
                WebCart cartObj = cartList[0];
                List<CartItem> cartItemList = [SELECT Id, Type, Name, Product2Id, Quantity, SalesPrice, CurrencyIsoCode FROM CartItem WHERE cartId =: cartId AND Type = 'Product'];
                if( ! cartItemList.isEmpty() ){
                    Map<String,Object> dataMap = new Map<String,Object>();
                    dataMap.put('cartObj',cartObj);
                    dataMap.put('cartItemList',cartItemList);
                    Opportunity oppObj = createOpportunity(dataMap);
                    dataMap.put('oppObj',oppObj);
                    Quote quoteObj = createQuoteObject(dataMap);
                    dataMap.put('quoteObj',quoteObj);
                    List<QuoteLineItem> quoteLineList = createQuoteLines(dataMap);
                    mapParams.put('oppObj', oppObj);
                    mapParams.put('quoteObj', quoteObj);
                    mapParams.put('quoteLineList', quoteLineList);
                    isSuccess = true;
                }else{
                    message = 'No CartItem found';
                }
            }else{
                message = 'No Cart found';
            }
        }else{
            message = 'No Cart found';
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }

    public static Opportunity createOpportunity(Map<String,Object> dataMap){
        WebCart cartObj = (WebCart)dataMap.get('cartObj');
        
        Id recordTypeSales = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        Opportunity oppToReturn = new Opportunity();
        oppToReturn.Name = 'Opp-' + cartObj.Id;
        oppToReturn.AccountId = cartObj.AccountId;
        oppToReturn.ForecastCategoryName = 'Pipeline';
        oppToReturn.Industry_Segment__c = 'Life Science';
        oppToReturn.CloseDate = System.Today() + 30;
        oppToReturn.StageName = 'Development';
        oppToReturn.Product_Family__c = 'DSBH';
        oppToReturn.CurrencyIsoCode = cartObj.CurrencyIsoCode;
        oppToReturn.RecordTypeId = recordTypeSales;
        insert oppToReturn;

        return oppToReturn;
    }

    public static Quote createQuoteObject(Map<String,Object> dataMap){
        WebCart cartObj = (WebCart)dataMap.get('cartObj');
        Opportunity oppObj = (Opportunity)dataMap.get('oppObj');
        Map<String,String> productIdVsPbeId = getPricebookEntryId(dataMap);
        String pbeId = productIdVsPbeId.get('pbeId');
        List<PricebookEntry> pbeList = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE Id =: pbeId LIMIT 1];
        Quote objToReturn = new Quote();
        objToReturn.Name = 'Quote-' + cartObj.Id;
        objToReturn.Status = 'Draft';
        objToReturn.CurrencyIsoCode = cartObj.CurrencyIsoCode;
        // objToReturn.AccountId = cartObj.AccountId;
        // objToReturn.ExpirationDate = '';
        objToReturn.Pricebook2Id = pbeList[0].Pricebook2Id;
        objToReturn.ContactId = cartObj.CreatedBy.ContactId;
        objToReturn.OpportunityId = oppObj.Id;
        insert objToReturn;

        return objToReturn;
    }

    public static List<QuoteLineItem> createQuoteLines(Map<String,Object> dataMap){
        List<QuoteLineItem> qlToReturn = new List<QuoteLineItem>();
        List<CartItem> cartItemList = (List<CartItem>)dataMap.get('cartItemList');
        Quote qObj = (Quote)dataMap.get('quoteObj');
        Map<String,String> productIdVsPbeId = getPricebookEntryId(dataMap);
        if( ! cartItemList.isEmpty() ){
            for(CartItem ci : cartItemList){
                QuoteLineItem ql = new QuoteLineItem();
                ql.Description = ci.Name;
                ql.Product2Id = ci.Product2Id;
                ql.PricebookEntryId = productIdVsPbeId.get(ci.Product2Id);
                ql.Quantity = ci.Quantity;
                ql.QuoteId = qObj.Id;
                ql.ServiceDate = Date.Today();
                ql.UnitPrice = ci.SalesPrice;
                qlToReturn.add(ql);
            }
        }
        if( ! qlToReturn.isEmpty() ){
            insert qlToReturn;
        }
        return qlToReturn;
    }

    public static Map<String,String> getPricebookEntryId(Map<String,Object> dataMap){
        Map<String,String> retMap = new Map<String,String>();
        List<CartItem> cartItemList = (List<CartItem>)dataMap.get('cartItemList');
        WebCart cartObj = (WebCart)dataMap.get('cartObj');
        ConnectApi.PricingInput priceInput = new ConnectApi.PricingInput();
        list<ConnectApi.PricingLineItemInput> pliInpList = new list<ConnectApi.PricingLineItemInput>();
        for(CartItem ci : cartItemList){
            ConnectApi.PricingLineItemInput pliInp = new ConnectApi.PricingLineItemInput();
            pliInp.productId = ci.Product2Id;
            pliInpList.add(pliInp);
        }
        priceInput.pricingLineItems = pliInpList;
        ConnectApi.PricingResult result;
        if( ! Test.isRunningTest() ){
            result = ConnectApi.CommerceStorePricing.getProductPrices(cartObj.WebStoreId,null,priceInput);
        }else{
            List<ConnectApi.PricingResultLineItem> lineItemList = new List<ConnectApi.PricingResultLineItem> ();
            ConnectApi.PricingResultLineItem lineItem = new ConnectApi.PricingResultLineItem ();
            lineItem.productId = pliInpList[0].productId;
            
            PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2Id =: pliInpList[0].productId LIMIT 1];
            lineItem.pricebookEntryId = pbe.Id;
            lineItemList.add( lineItem );
            ConnectApi.PricingResult testResult = new ConnectApi.PricingResult();
            testResult.pricingLineItemResults = lineItemList;
            testResult.error = null;
            testResult.success = true; 
            result = testResult;
        }
        System.debug('ConnectApi.PricingResult result---- '+JSON.serialize(result));
        for( ConnectApi.PricingResultLineItem item : result.pricingLineItemResults){
            retMap.put(item.productId,item.pricebookEntryId);
            retMap.put('pbeId',item.pricebookEntryId);
        }
        return retMap;
    }

}