import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ["Product2.Color_and_form__c", "Product2.Purity__c", "Product2.Density_Site__c", "Product2.Melting_point__c", "Product2.Boiling_point__c", "Product2.Flash_point__c", "Product2.Vapor_pressure__c", "Product2.Surface_Area_Site__c", "Product2.Pore_volume__c", "Product2.Spec_Rotation__c"];

export default class B2bProductDetailsTabPhysicalProperties extends LightningElement {

    productId;
    productFields;
    colorAndForm;
    purity;
    density;
    meltingPoint;
    boilingPoint;
    flashPoint;
    vaporPressure;
    surfaceArea;
    poreVolume;
    specRotation;

    @wire(CurrentPageReference)
    getPageRef(res){
        console.log('result =>'+JSON.stringify(res));
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
                console.log('data => ',data);
                this.productFields = data?.fields;
                this.colorAndForm = data?.fields?.Color_and_form__c?.value;
                this.purity = data?.fields?.Purity__c?.value;
                this.density = data?.fields?.Density_Site__c?.value;
                this.meltingPoint = data?.fields?.Melting_point__c?.value;
                this.boilingPoint = data?.fields?.Boiling_point__c?.value;
                this.flashPoint = data?.fields?.Flash_point__c?.value;
                this.vaporPressure = data?.fields?.Vapor_pressure__c?.value;
                this.surfaceArea = data?.fields?.Surface_Area_Site__c?.value;
                this.poreVolume = data?.fields?.Pore_volume__c?.value;
                this.specRotation = data?.fields?.Spec_Rotation__c?.value;
            }
        }
        
    }

}