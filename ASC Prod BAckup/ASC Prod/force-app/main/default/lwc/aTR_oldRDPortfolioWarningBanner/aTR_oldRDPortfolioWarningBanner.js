import { LightningElement, api, wire } from 'lwc';
import oldPortfolioWarningLabel from '@salesforce/label/c.oldPortfolioWarningLabel';
import oldPortfolioRedirectMessage from '@salesforce/label/c.oldPortfolioRedirectMessage';
import getChildOpportunity from '@salesforce/apex/ATR_oldRDPortfolioWarningBannerCont.getChildOpportunity';
import { CurrentPageReference } from 'lightning/navigation';

export default class ATR_oldRDPortfolioWarningBanner extends LightningElement {
    warningLabel = oldPortfolioWarningLabel;
    redirectMessage = oldPortfolioRedirectMessage;
    showWarningBanner = true;
    opportunityName = '';
    opportunityLink = '';
    @api recordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
            console.log('recordId witre', this.recordId);
        }
    }

    connectedCallback() {
        this.checkForChildOpportunities();
    }

    checkForChildOpportunities() {
        getChildOpportunity({ portfolioId: this.recordId })
            .then((result) => {
                if (result) {
                    this.showWarningBanner = true;
                    this.opportunityName = result.Name;
                    this.opportunityLink = '/' + result.Id;
                } else {
                    this.showWarningBanner = false;
                }
            })
            .catch((error) => {
                console.error('Error fetching child opportunities:', error);
            });
    }
}