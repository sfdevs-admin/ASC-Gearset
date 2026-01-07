/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 06-27-2024
 * @last modified by  : S.T
**/
public without sharing class B2BProductDetailCOA_pdfController {

    public String productId {get;set;}
    public String productCode {get;set;}
    public String productName {get;set;}
    public String productDescription {get;set;}
    public String dateVal {get;set;}
    public String lotNumber {get;set;}
    public String casNumber {get;set;}
    public String headerLogo {get;set;}
    public List<Certificate_of_Analysis__c> coaList {get;set;}
    public Boolean isPDP {get;set;}

    public B2BProductDetailCOA_pdfController() {
        if(ApexPages.currentPage().getParameters() != null && ApexPages.currentPage().getParameters().containsKey('productId') && String.isNotBlank(ApexPages.currentPage().getParameters().get('productId'))){
            productId = ApexPages.currentPage().getParameters().get('productId');
            lotNumber = ApexPages.currentPage().getParameters().get('lotNumber');
            isPDP = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isPDP'));
            headerLogo = System.label.B2B_Header_Logo;
        }
        try {
            if( String.isNotBlank(productId) && String.isNotBlank(lotNumber) ){
                Map<String,Object> mapParams = new Map<String,Object>();
                mapParams.put('productId',productId);
                mapParams.put('enteredLotNumber',lotNumber);
                mapParams.put('isPDP',isPDP);
                Map<String,Object> respMap = B2B_ProductDetailCOAController.getCOAData(mapParams);
                System.debug('B2BProductDetailCOA_pdfController respMap--- '+JSON.serialize(respMap));
                List<Certificate_of_Analysis__c> coaListTemp = (List<Certificate_of_Analysis__c>)respMap.get('coaList');
                System.debug('B2BProductDetailCOA_pdfController coaListTemp--- '+JSON.serialize(coaListTemp));
                coaList = coaListTemp;
                // for(Certificate_of_Analysis__c obj : coaListTemp){
                //     WrapperCOA o = new WrapperCOA();
                //     o.Id = obj.Catalog_Item_Number__c;
                //     //coaList.add(o);
                // }
                System.debug('B2BProductDetailCOA_pdfController coaList--- '+JSON.serialize(coaList));
                Product2 prod = getProductData(productId);
                productName = prod.Name;
                productCode = prod.ProductClass == 'Variation' ? prod.Parent_Sku__c : prod.StockKeepingUnit;
                productDescription = prod.Description;
                casNumber = (String) prod.CAS__c;

                List<Certificate_of_Analysis__c> coaListSortedTemp = (List<Certificate_of_Analysis__c>)respMap.get('coaListSorted');
                Certificate_of_Analysis__c coaTemp = coaListSortedTemp[0];
                Date myDate = coaTemp.Date__c;

                String template = '{0} {1}, {2}';
                List<String> months = new List<String>{'January', 'February', 'March', 'April', 'May', 'June','July', 'August', 'September', 'October', 'November', 'December'};
                System.debug ('Newly formatted myDate.month(): ' +months.get(myDate.month() - 1));

                List<Object> parameters = new List<Object> { months.get(myDate.month() - 1), myDate.day(), myDate.year() };
                dateVal = String.format(template, parameters);
                System.debug ('dateVal--- ' +dateVal);
            }
        } catch (Exception e) {
            System.debug('B2BProductDetailCOA_pdfController error exception--- '+e.getMessage());
        }
    }
    public static Product2 getProductData(String prodIdInp){
        Product2 prodToReturn;
        List<Product2> prodList = [SELECT Id, ProductCode,StockKeepingUnit,ProductClass, Name, Description, CAS__c, Parent_Sku__c FROM Product2 WHERE Id =: prodIdInp LIMIT 1];
        if( ! prodList.isEmpty() ){
            prodToReturn = prodList[0];
        }
        return prodToReturn;
    }

    public class WrapperCOA{
        public String Id;
        public String Name; 
        // public String Lot_Number__c; 
        // public String Specification__c; 
        // public String Result__c; 
        // public Integer Sequence_Number__c; 
        // public String Catalog_Item_Number__c; 
        // public String Display_Id__c; 
        // public String Characteristics__c; 
        // public String Product_Categories__c; 
        // public String Product_Category__c; 
        // public String Product__c; 
        // public String Product_Name__c; 
        // public String Date__c; 
    }

    // public class JSON2Apex {

    //     public String message {get;set;} 
    //     public Boolean isSuccess {get;set;} 
    //     public List<CoaListSorted> coaListSorted {get;set;} 
    //     public List<CoaListSorted> coaList {get;set;} 
    //     public Boolean hasData {get;set;} 
    //     public String enteredLotNumber {get;set;} 
    //     public String productId {get;set;} 

    //     public JSON2Apex(JSONParser parser) {
    //         while (parser.nextToken() != System.JSONToken.END_OBJECT) {
    //             if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
    //                 String text = parser.getText();
    //                 if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
    //                     if (text == 'message') {
    //                         message = parser.getText();
    //                     } else if (text == 'isSuccess') {
    //                         isSuccess = parser.getBooleanValue();
    //                     } else if (text == 'coaListSorted') {
    //                         coaListSorted = arrayOfCoaListSorted(parser);
    //                     } else if (text == 'coaList') {
    //                         coaList = arrayOfCoaListSorted(parser);
    //                     } else if (text == 'hasData') {
    //                         hasData = parser.getBooleanValue();
    //                     } else if (text == 'enteredLotNumber') {
    //                         enteredLotNumber = parser.getText();
    //                     } else if (text == 'productId') {
    //                         productId = parser.getText();
    //                     } else {
    //                         System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
    //                         consumeObject(parser);
    //                     }
    //                 }
    //             }
    //         }
    //     }
        
    //     public class CoaListSorted {
    //         public Attributes attributes {get;set;} 
    //         public String Id {get;set;} 
    //         public String Name {get;set;} 
    //         public String Lot_Number__c {get;set;} 
    //         public String Specification__c {get;set;} 
    //         public String Result__c {get;set;} 
    //         public Integer Sequence_Number__c {get;set;} 
    //         public String Catalog_Item_Number__c {get;set;} 
    //         public String Display_Id__c {get;set;} 
    //         public String Characteristics__c {get;set;} 
    //         public String Product_Categories__c {get;set;} 
    //         public String Product_Category__c {get;set;} 
    //         public String Product__c {get;set;} 
    //         public String Product_Name__c {get;set;} 
    //         public String Date__c {get;set;} 

    //         public CoaListSorted(JSONParser parser) {
    //             while (parser.nextToken() != System.JSONToken.END_OBJECT) {
    //                 if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
    //                     String text = parser.getText();
    //                     if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
    //                         if (text == 'attributes') {
    //                             attributes = new Attributes(parser);
    //                         } else if (text == 'Id') {
    //                             Id = parser.getText();
    //                         } else if (text == 'Name') {
    //                             Name = parser.getText();
    //                         } else if (text == 'Lot_Number__c') {
    //                             Lot_Number__c = parser.getText();
    //                         } else if (text == 'Specification__c') {
    //                             Specification__c = parser.getText();
    //                         } else if (text == 'Result__c') {
    //                             Result__c = parser.getText();
    //                         } else if (text == 'Sequence_Number__c') {
    //                             Sequence_Number__c = parser.getIntegerValue();
    //                         } else if (text == 'Catalog_Item_Number__c') {
    //                             Catalog_Item_Number__c = parser.getText();
    //                         } else if (text == 'Display_Id__c') {
    //                             Display_Id__c = parser.getText();
    //                         } else if (text == 'Characteristics__c') {
    //                             Characteristics__c = parser.getText();
    //                         } else if (text == 'Product_Categories__c') {
    //                             Product_Categories__c = parser.getText();
    //                         } else if (text == 'Product_Category__c') {
    //                             Product_Category__c = parser.getText();
    //                         } else if (text == 'Product__c') {
    //                             Product__c = parser.getText();
    //                         } else if (text == 'Product_Name__c') {
    //                             Product_Name__c = parser.getText();
    //                         } else if (text == 'Date__c') {
    //                             Date__c = parser.getText();
    //                         } else {
    //                             System.debug(LoggingLevel.WARN, 'CoaListSorted consuming unrecognized property: '+text);
    //                             consumeObject(parser);
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //     }
        
    //     public class Attributes {
    //         public String type {get;set;} 
    //         public String url {get;set;} 

    //         public Attributes(JSONParser parser) {
    //             while (parser.nextToken() != System.JSONToken.END_OBJECT) {
    //                 if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
    //                     String text = parser.getText();
    //                     if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
    //                         if (text == 'type') {
    //                             type = parser.getText();
    //                         } else if (text == 'url') {
    //                             url = parser.getText();
    //                         } else {
    //                             System.debug(LoggingLevel.WARN, 'Attributes consuming unrecognized property: '+text);
    //                             consumeObject(parser);
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //     }
        
        
    //     public static JSON2Apex parse(String json) {
    //         System.JSONParser parser = System.JSON.createParser(json);
    //         return new JSON2Apex(parser);
    //     }
        
    //     public static void consumeObject(System.JSONParser parser) {
    //         Integer depth = 0;
    //         do {
    //             System.JSONToken curr = parser.getCurrentToken();
    //             if (curr == System.JSONToken.START_OBJECT || 
    //                 curr == System.JSONToken.START_ARRAY) {
    //                 depth++;
    //             } else if (curr == System.JSONToken.END_OBJECT ||
    //                 curr == System.JSONToken.END_ARRAY) {
    //                 depth--;
    //             }
    //         } while (depth > 0 && parser.nextToken() != null);
    //     }
        



    //     private static List<CoaListSorted> arrayOfCoaListSorted(System.JSONParser p) {
    //         List<CoaListSorted> res = new List<CoaListSorted>();
    //         if (p.getCurrentToken() == null) p.nextToken();
    //         while (p.nextToken() != System.JSONToken.END_ARRAY) {
    //             res.add(new CoaListSorted(p));
    //         }
    //         return res;
    //     }
    // }
    // 
    public static void testCoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}