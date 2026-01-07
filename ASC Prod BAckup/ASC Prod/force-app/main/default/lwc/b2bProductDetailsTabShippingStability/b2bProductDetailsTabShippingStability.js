import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

const YES_NO = new Map([[true, "Yes"], [false, "No"]]);
const DISPLAY_VALUE = new Map([["HAZ", "Hazardous - an additional Dangerous Goods freight charge may apply"], 
                                ["BOAT", "Boat shipment. Refer to SDS."],
                                ["TRUCK","Truck shipment. Refer to SDS."],
                                ["DRY_ICE","Required for shipment"],
                                ["EXPORT_LIMITATIONS","For sale in USA only"]]);
const FIELDS = ["Product2.HAZ__c", "Product2.BOAT_Text__c", "Product2.Truck__c", "Product2.Ship_in_Dry_Ice__c", "Product2.Alternative_for_air_shipment_see__c", "Product2.For_sale_in_USA_only__c", "Product2.Pyrophoric__c", "Product2.Hygroscopic__c", "Product2.Air_Sensitive__c", "Product2.Light_Sensitive__c", "Product2.Heat_Sensitive__c", "Product2.Moisture_Sensitive__c", "Product2.Stench__c", "Product2.Store_Cold__c"];

export default class B2bProductDetailsTabShippingStability extends LightningElement {

    productId;
    productFields;
    haz;
    boat;
    truck;
    shipInDryIce;
    alternativeAirShipment;
    forSaleInUsaOnly;
    pyrophoric;
    hygroscopic;
    airSensitive;
    lightSensitive;
    heatSensitive;
    moistureSensitive;
    stench;

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
                this.haz = data?.fields?.HAZ__c?.value;
                this.boat = data?.fields?.BOAT_Text__c?.value;
                this.truck = data?.fields?.Truck__c?.value;
                this.storeCold = YES_NO.get(data?.fields?.Store_Cold__c?.value);
                this.shipInDryIce = data?.fields?.Ship_in_Dry_Ice__c?.value;
                this.alternativeAirShipment = data?.fields?.Alternative_for_air_shipment_see__c?.value;
                this.forSaleInUsaOnly = data?.fields?.For_sale_in_USA_only__c?.value;
                this.pyrophoric = YES_NO.get(data?.fields?.Pyrophoric__c?.value);
                this.hygroscopic = YES_NO.get(data?.fields?.Hygroscopic__c?.value);
                this.airSensitive = YES_NO.get(data?.fields?.Air_Sensitive__c?.value);
                this.lightSensitive = YES_NO.get(data?.fields?.Light_Sensitive__c?.value);
                this.heatSensitive = YES_NO.get(data?.fields?.Heat_Sensitive__c?.value);
                this.moistureSensitive = YES_NO.get(data?.fields?.Moisture_Sensitive__c?.value);
                this.stench = YES_NO.get(data?.fields?.Stench__c?.value);
            }
        }
        
    }

}