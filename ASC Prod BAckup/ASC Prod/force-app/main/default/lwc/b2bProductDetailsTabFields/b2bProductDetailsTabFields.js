import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

const YES_NO = new Map([[true, "Yes"], [false, "No"]]);
const FIELDS = ["Product2.CAS__c", "Product2.MDL_Number__c", "Product2.Index_Formula_Site__c", "Product2.Formula_weight__c", "Product2.Formula_Site__c", "Product2.Color_and_form__c", "Product2.Melting_point__c", "Product2.Boiling_point__c", "Product2.Reaction__c", "Product2.Note__c", "Product2.B2B_Is_Simple_Product__c", "Product2.Purity__c"];

export default class B2bProductDetailsTabFields extends LightningElement {
    
    productId;
    casVal;
    mdlVal;
    indexFormulaVal;
    formulaWtVal;
    formulaVal;
    colorAndFormVal;
    meltingPointVal;
    boilingPointVal;
    storeCold;
    reactionVal;
    noteVal;
    productFields;
    isSimpleProduct;
    chemicalPurity;

    @wire(CurrentPageReference)
    getPageRef(res){
        console.log('b2bProductDetailsTabFields result =>'+JSON.stringify(res));
        this.productId = res.attributes.recordId;  
    }

    @wire(getRecord, { recordId: "$productId", fields: FIELDS}) 
    wireProduct({ error, data }) {
        if(this.productId){
            if (error) {
                console.log('error => ',error);
                this.erroredOut = true;
                this.errorMsg = error;
            } else if (data) {
                console.log('b2bProductDetailsTabFields data => ',data);
                this.productFields = data?.fields;
                this.casVal = data?.fields?.CAS__c?.value;
                this.mdlVal = data?.fields?.MDL_Number__c?.value;
                this.indexFormulaVal = data?.fields?.Index_Formula_Site__c?.value;
                this.formulaWtVal = data?.fields?.Formula_weight__c?.value;
                this.formulaVal = data?.fields?.Formula_Site__c?.value;
                this.reactionVal = data?.fields?.Reaction__c?.value ? data?.fields?.Reaction__c?.value.replaceAll(';',', ') : data?.fields?.Reaction__c?.value;
                this.noteVal = data?.fields?.Note__c?.value;
                this.isSimpleProduct = data?.fields?.B2B_Is_Simple_Product__c?.value != null ? data?.fields?.B2B_Is_Simple_Product__c?.value : false;
                this.chemicalPurity = data?.fields?.Purity__c?.value;
            }
        }
        
    }

}