import { LightningElement,api } from 'lwc';
/**
 * @slot productDetails ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "tabSlot1", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot productDetailsSimple ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "tabSlot1Simple", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot technicalNoteSimple ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "tabSlot2Simple", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot technicalNote ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "tabSlot2", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot safetyDataSheets ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "tabSlot3", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot certificateOfAnalysis ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "tabSlot4", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] }) 
 */
export default class TabsComponent extends LightningElement {
    static renderMode = "light"; // the default is 'shadow'
    isSampleProduct ;
    recordId;
    selectedTab;
    @api 
    get productDetails(){
        
    }
    set productDetails(val){
        if (val) {
           
        } else {
            console.error('Invalid value passed to productDetails:', val);
        }
    }
    @api 
    get isSimple(){

    }
    set isSimple(val){
        console.log('isSimple set to:',val);
        this.isSampleProduct = val;
    }

    connectedCallback(){
        if( this.isSampleProduct ){
            this.selectedTab = 'Tab Simple 1';
            let tempReset = this.tabSimple1Selected;
        }else{
            this.selectedTab = 'Tab 1';
        }
    }
    handleActive(event) {
        const tabName = event.target.value;
        if( this.selectedTab != tabName ){
            this.selectedTab = tabName;
        }
        // console.log(`Clicked on ${tabName}`);
        console.log("Clicked on ", tabName);
        
    }

    get tab1Selected(){
        if( this.selectedTab == 'Tab 1' ){
            return true;
        }
        return false;
    }

    get tab2Selected(){
        if( this.selectedTab == 'Tab 2' ){
            return true;
        }
        return false;
    }

    get tab3Selected(){
        if( this.selectedTab == 'Tab 3' ){
            return true;
        }
        return false;
    }

    get tab4Selected(){
        if( this.selectedTab == 'Tab 4' ){
            return true;
        }
        return false;
    }

    get tabSimple1Selected(){
        if( this.selectedTab == 'Tab Simple 1' ){
            return true;
        }
        return false;
    }

    get tabSimple2Selected(){
        if( this.selectedTab == 'Tab Simple 2' ){
            return true;
        }
        return false;
    }
}