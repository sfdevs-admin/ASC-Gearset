import { LightningElement,wire } from 'lwc';
import { CurrentPageReference, navigate, NavigationContext } from 'lightning/navigation';
import getProductCategory from '@salesforce/apex/B2B_PeriodicTableController.getProductCategory';
import b2bSiteCategoryUrl from '@salesforce/label/c.b2bSiteCategoryUrl';

export default class PeriodicTable extends LightningElement {
    searchTerm = null;
    
    @wire(NavigationContext)
    navContext;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        // let METHOD = 'getStateParameters'; 

        // console.log(METHOD + ' currentPageReference ' , JSON.parse(JSON.stringify(currentPageReference)))
        // console.log(METHOD + ' currentPageReference?.state?.term ' , currentPageReference?.state?.term)

        if (currentPageReference) {
            this.searchTerm = currentPageReference?.state?.term ? currentPageReference.state.term : null;
            // console.log(METHOD + ' this.searchTerm ' , this.searchTerm)
        }
    }       
    messageState = 'Please Wait';
    showSpinner = false;
    async handleNavigation(event){
        let element = event.currentTarget.dataset.element;
        console.log('handleNavigation----- '+element);
        if(element && element != ''){
            this.showSpinner = true;
            //do apex call to get the category Id.
            let mapParams = {};
            mapParams.elementVal = element;
            await getProductCategory({
                'mapParams' : mapParams
            }).then((res) => {
                let response = JSON.parse(JSON.stringify(res));
                console.log('PeriodicTable callgetProductCategory res---- '+ response);
                if(res.isSuccess){
                    // this.showSpinner = false;
                    this.goToCategory(response.elementsList[0]);
                }else{
                    //show no data found error
                    this.showSpinner = false;
                    console.log('PeriodicTable callgetProductCategory is success false---- '+ JSON.stringify(res));
                }
            }).catch((e) => {
                this.showSpinner = false;
                console.log('PeriodicTable callgetProductCategory catch---- '+ JSON.stringify(e));
            });
        }

    }

    goToCategory(e){
        let catId = e.Category_Id__c;
        
        if(catId){
            let url = b2bSiteCategoryUrl + catId;
            window.location.href = url;
            // not working
            // this.navContext &&
            // navigate(this.navContext, {
            //     type: 'comm__namedPage',
            //     attributes: {
            //         name: 'Category_Detail',
            //         recordId: catId,
            //     },
            // });
        }
    }
}