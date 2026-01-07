import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class B2bProductDetailCustomTabs extends LightningElement {
    @api displayText;

    @track tab1Active = true;
    @track tab2Active = false;
    @track tab3Active = false;
    @track tab4Active = false;
    productId;

    @wire(CurrentPageReference)
    getPageRef(res){
        console.log('B2bProductDetailCustomTabs CurrentPageReference res------- '+JSON.stringify(res));
        this.productId = res.attributes.recordId;
    }

    selectTab1() {
        this.tab1Active = true;
        this.tab2Active = false;
        this.tab3Active = false;
        this.tab4Active = false;
    }

    selectTab2() {
        this.tab1Active = false;
        this.tab2Active = true;
        this.tab3Active = false;
        this.tab4Active = false;
    }

    selectTab3() {
        this.tab1Active = false;
        this.tab2Active = false;
        this.tab3Active = true;
        this.tab4Active = false;
    }

    selectTab4(){
        this.tab1Active = false;
        this.tab2Active = false;
        this.tab3Active = false;
        this.tab4Active = true;
    }

    isInSitePreview() {
        let url = document.URL;
        
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }
}