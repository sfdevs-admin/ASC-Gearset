import { LightningElement, api, track, wire } from 'lwc';
import getCOAData from '@salesforce/apex/B2B_ProductDetailCOAController.getCOAData';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import B2B_Org_Base_URL from '@salesforce/label/c.B2B_Org_Base_URL';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import printPdf from '@salesforce/apex/B2B_ProductDetailCOAController.printPdf';
import B2B_COA_SITE_URL from '@salesforce/label/c.B2B_COA_SITE_URL';

export default class B2bProductDetailCOA extends NavigationMixin(LightningElement) {
    @api productId;
    enteredLotNumber;
    enteredCatNumber;

    showSearchResult = false;
    showNoDataError = false;
    @track coaDataList;
    displayDate;
    prodName;
    prodSku;
    showDataTableCss = 'showDataTable';

    /**
     * Whether to display the action button.
     * @type {boolean}
     * @default false
     */
    @api isPDP;

    get isPDPView(){
        console.log('B2bProductDetailCOA isPDPView this.isPDP------- '+this.isPDP);
        return this.isPDP;
    }

    @wire(CurrentPageReference)
    getPageRef(res){
        console.log('B2bProductDetailCustomTabs CurrentPageReference res------- '+JSON.stringify(res));
        this.productId = res.attributes.recordId;
        this.enteredLotNumber = '';
        this.showSearchResult = false;
    }

    handleInputBlur(event){
        this.enteredLotNumber = event.target.value;
        console.log('B2bProductDetailCOA handleInputBlur----- '+this.enteredLotNumber);
    }

    
    handleCatNumInputBlur(event){
        this.enteredCatNumber = event.target.value;
        console.log('B2bProductDetailCOA handleCatNumInputBlur----- '+this.enteredCatNumber);
    }

    // handleLotNumInputBlur(event){
    //     this.enteredLotNumber = event.target.value;
    //     console.log('B2bProductDetailCOA handleLotNumInputBlur----- '+this.enteredLotNumber);
    // }

    handleSubmitClick(){
        if( !this.isPDP ){
            this.showDataTableCss = 'showDataTable-NotPdp';
            if( (this.enteredCatNumber == undefined || this.enteredCatNumber == '') &&  (this.enteredLotNumber == undefined || this.enteredLotNumber == '')){
                this.showToastFunc('Error', 'Please enter a value in input.', 'error', 'dismissable');
            }
        }else{
            if(this.enteredLotNumber == undefined || this.enteredLotNumber == ''){
                this.showToastFunc('Error', 'Please enter a value in input.', 'error', 'dismissable');
            }
        }
        console.log('B2bProductDetailCOA handleSubmitClick this.enteredLotNumber----- '+this.enteredLotNumber);
        this.getData();
    }
    
    getData(){  
        console.log('B2bProductDetailCOA getCOAData isPDP---- '+ this.isPDP);
        let mapParams = {};
        mapParams.isPDP = this.isPDP;
        mapParams.enteredCatNumber = this.enteredCatNumber;
        mapParams.enteredLotNumber = this.enteredLotNumber;
        mapParams.productId = this.productId;
        getCOAData({
            'mapParams' : mapParams
        }).then((res) => {
            console.log('B2bProductDetailCOA getCOAData res---- '+ JSON.stringify(res));
            if(res.isSuccess){
                this.showSearchResult = true;
                var options = { year: 'numeric', month: 'long', day: 'numeric' };
                //var todayDate = new Date();
                //console.log('date value------ '+todayDate.toLocaleDateString("en-US", options));
                //this.displayDate = todayDate.toLocaleDateString("en-US", options);
                if(res.hasData){
                    // show table
                    this.showNoDataError =  false;
                    var data = JSON.parse(JSON.stringify(res));
                    console.log('B2bProductDetailCOA coaData data---- '+ JSON.stringify(data));
                    var coaData = JSON.parse(JSON.stringify(res.coaList));
                    this.productId = JSON.parse(JSON.stringify(res.productId));
                    this.coaDataList = coaData;
                    // let tempDisplayDate = new Date(data.coaListSorted[0].Date__c);
                    // console.log('B2bProductDetailCOA coaData coaData---- '+ tempDisplayDate);
                    // this.displayDate = tempDisplayDate.toLocaleDateString("en-US", options);
                    this.displayDate = data.coaListSorted[0].Display_Date__c;
                    this.prodSku = data.coaList[0].Product__r.ProductCode;
                    this.prodName = data.coaList[0].Product_Name__c;
                }else{
                    //show no data found error
                    this.showNoDataError =  true;
                }
            }else{
                this.showSearchResult = false;
                //show no data found error
                console.log('B2bProductDetailCOA getCOAData is success false---- '+ JSON.stringify(res));
            }
        }).catch((e) => {
            this.showSearchResult = false;
            console.log('B2bProductDetailCOA getCOAData catch---- '+ JSON.stringify(e));
        });
    }

    // Custom sorting function
    sortByDate = (a, b) => {
        console.log('sorting sortByDate--- '+a+' ---- '+b);
        let aDate = new Date(a.Date__c);
        let bDate = new Date(b.Date__c);
        return bDate - aDate;
    };

    async printCertificate(){
        console.log('B2bProductDetailCOA printCertificate---- ');
        console.log('ProductId---- ' + this.productId);
        console.log('enteredLotNumber---- ' + this.enteredLotNumber);
        if(this.productId && this.enteredLotNumber){
            if(! this.isPDP) this.isPDP = true;
            let url = B2B_COA_SITE_URL + '?productId=' + this.productId + '&lotNumber=' + this.enteredLotNumber + '&isPDP=' + this.isPDP;
            window.open(url);

            /*let mapParams = {};
            mapParams.isPDP = this.isPDP;
            mapParams.enteredCatNumber = this.enteredCatNumber;
            mapParams.enteredLotNumber = this.enteredLotNumber;
            mapParams.productId = this.productId;
            await printPdf({
                'mapParams' : mapParams
            }).then((res) => {
                console.log('B2bProductDetailCOA printCertificate res---- '+ JSON.stringify(res));
                if(res.isSuccess){
                    let blobPdf = res.base64Pdf;
                    this.generatePdf(blobPdf);
                }else{
                    //show no data found error
                    console.log('B2bProductDetailCOA printCertificate is success false---- '+ JSON.stringify(res));
                }
            }).catch((e) => {
                this.showSearchResult = false;
                console.log('B2bProductDetailCOA printCertificate catch---- '+ JSON.stringify(e));
            });*/



            // let url = B2B_Org_Base_URL + '/apex/B2BProductDetailCOA_pdf?productId=' + this.productId + '&lotNumber=' + this.enteredLotNumber + '&isPDP=' + this.isPDP;
            // window.open(url, '_blank');
        }else{
            console.log('B2bProductDetailCOA printCertificate errorr---- ');
        }
    }

    generatePdf(inp){
        console.log('B2bProductDetailCOA generatePdf---- '+inp);
        var fileName = 'Certificate.pdf';
        let element = document.createElement('a');
        element.setAttribute('href', 'data:application/pdf;base64,' + inp);
        element.setAttribute('download', fileName);
        element.setAttribute('sandbox', 'allow-scripts allow-downloads');
        element.style.display = 'none';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
    }

    showToastFunc(title, message, variant, mode){

        this.dispatchEvent(
            new ShowToastEvent({
                      title: 'Error',
                      message: 'Please enter a value in input.',
                      variant: 'error',
                      mode: 'dismissable'
                  })
         );

        // const evt = new ShowToastEvent({
        //     title: 'Error',
        //     message: 'Please enter a value in input.',
        //     variant: 'error',
        //     mode: 'dismissable'
        // });
        // this.dispatchEvent(evt);
    }
}