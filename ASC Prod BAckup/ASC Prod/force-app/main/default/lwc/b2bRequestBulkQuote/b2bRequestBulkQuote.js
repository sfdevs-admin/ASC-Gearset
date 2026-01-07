/**
 * @description       :
 * @author            : Swati Chilap
 * @group             :
 * @last modified on  : 10-06-2025
 * @last modified by  : Swati Chilap
 **/
import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { CartItemsAdapter } from 'commerce/cartApi';
import BULK_QUANTITY_LABEL from '@salesforce/label/c.B2B_Cart_Bulk_Quote_Quantity';

export default class B2bRequestBulkQuote extends NavigationMixin (LightningElement) {
    @track cartItems = [];
    cartId;
    showButton = false;

    handleCreateQuote() {
        this.navigateToQuotePage();
    }

    navigateToQuotePage() {
        this[NavigationMixin.Navigate](
            {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Request_Quote__c'
                },
                state: {
                    cartid: this.cartId
                }
            },
            true
        );
    }

    @wire(CartItemsAdapter)
    setCartItems({ data, error }) {
        if (data) {
            this.cartId = data?.cartSummary?.cartId;
            this.cartItems = data?.cartItems;

            this.showButton = this.cartItems.some(item => {
                let qty = Number(item?.cartItem?.quantity || 0);
                return qty >= BULK_QUANTITY_LABEL;
            });            
        } else if (error) {
            console.error('error cart Items::: ', error);
        }
        
    }
}