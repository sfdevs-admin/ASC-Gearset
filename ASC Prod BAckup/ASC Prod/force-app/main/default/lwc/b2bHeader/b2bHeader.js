import { LightningElement, track, wire } from 'lwc';
import getCountries from '@salesforce/apex/b2bCountryController.getCountries';
import getUserType from '@salesforce/apex/b2bCountryController.getUserType';
import updateUserCountry from '@salesforce/apex/b2bCountryController.updateUserCountry';
import getLoggedInUserCountry from '@salesforce/apex/b2bCountryController.getLoggedInUserCountry';
import updateAccountCountry from '@salesforce/apex/b2bCountryController.updateAccountCountry';
import { publish, MessageContext } from 'lightning/messageService';
import MY_MESSAGE_CHANNEL from '@salesforce/messageChannel/countrySelector__c';




export default class B2bHeader extends LightningElement {
    @track countryOptions = [];
    @track selectedCountry;
    @track selectedCountryName = 'Select Country';
    @track showCountryList = false;
    // @track selectedCountry = 'USA'; // Default to 'US'
    // @track selectedCountryName = 'United States of America'; // Default to 'United States'
    
    @wire(MessageContext)
    messageContext;

    @wire(getCountries)
    wiredCountries({ error, data }) {
        if (data) {
            console.log('country data',data);
            this.countryOptions = data.map(value => {
           // console.log('Mapping country:', value.Country_Name__c, 'Currency ISO:', value.Currency_Code__c);
                // return { label: value.Country_Name__c
                //     , value: value.ISO_code__c //ISO_code__c
                // };
                return { 
                    label: value.Country_Name__c, 
                    value: JSON.stringify({ countryName: value.Country_Name__c, currencyISOCode: value.Currency_Code__c }) 
                };

            });
            console.log('this.countryOptions-->',this.countryOptions);
            //this.fetchUserCountry();
            this.checkUserTypeAndFetchCountry();
        } else if (error) {
            // Handle error
            console.error('error message',error);
        }
    }

    //guest user
    checkUserTypeAndFetchCountry() {
        getUserType()
            .then(result => {
                this.userType = result;
                if (this.userType !== 'Guest') {
                    this.fetchUserCountry();
                }
                else {
                    alert('this.selectedCountry'+this.selectedCountry);
                    // Handle guest user case by showing default or previously selected value
                    this.showCountryList = true;
                    if(this.selectedCountry){
                        console.log('inside if');
                        this.selectedCountry = result.CurrencyIsoCode;
                        this.selectedCountryName = result.Country;
                    }else{
                        console.log('inside else');
                        this.selectedCountry = 'USD';
                        this.selectedCountryName = 'United States of America';
                    }
                    
                    
                    const params = new URLSearchParams(window.location.search);
                    params.set('country', this.selectedCountryName);
                    //const newUrl = `${window.location.origin}${window.location.pathname}?${params.substring(0, 2)}`;
                    console.log('newurl of loggedinuser',params);
                    window.history.replaceState({}, '', params);
                }
            })
            .catch(error => {
                console.error('Error fetching user type', error);
            });
    }
    
    //loggedIn user details
    fetchUserCountry() {
        getLoggedInUserCountry()
            .then(result => {
                if (result) {
                    console.log('result of LoggedInUserCountry--->',result);
                    this.selectedCountry = result.CurrencyIsoCode;
                    this.selectedCountryName = result.Country;
                    //const newUrl = `${window.location.origin}${window.location.pathname}?country=${this.selectedCountry}`;
                    //window.location.href = newUrl;
                    // }

                    const params = new URLSearchParams(window.location.search);
                    params.set('country', this.selectedCountry);
                    const newUrl = `${window.location.origin}${window.location.pathname}?${params.substring(0, 2)}`;
                    console.log('newurl of loggedinuser',newUrl);
                    window.history.replaceState({}, '', newUrl);
                }
            })
            .catch(error => {
                console.error('Error fetching logged-in user country', error);
            });
    }

     handleChange(event) { 
       console.log('events',event);
        const selectedValue = JSON.parse(event.detail.value);
        console.log('selectedValue',selectedValue);

        this.selectedCountryName =selectedValue.countryName;
        console.log('selectedCountry',this.selectedCountryName);

        this.selectedCountry = selectedValue.currencyISOCode;
        console.log('selectedcountry code-->', this.selectedCountry);
       
        this.showCountryList = false; // Close the overlay after selection
        
        //Reload page with new URL.
        //const newUrl = `${window.location.origin}${window.location.pathname}?country=${this.selectedCountry.substring(0, 2)}`;
        // const newUrl = `${window.location.origin}${window.location.pathname}/en-${this.selectedCountry.substring(0, 2)}`;
        //const newUrl = `${window.location.origin}${window.location.pathname.$(this.selectedCountry)}`
        //console.log('newURL---->',newUrl);
       // window.location.href = newUrl;

           updateUserCountry({ country:  this.selectedCountryName })
           // updateUserCountry({ countryWrapperJson: JSON.stringify(countryWrapper) })
              .then(result => {
                    console.log('user country ISO code updated successfully',result);
                    // Reload the page with the new URL including the selected country ISO code
                    // const newUrl = `${window.location.origin}${window.location.pathname}?country=${this.selectedCountry}`;
                    // window.location.href = newUrl;
                })
                .catch(error => {
                    console.error('Error updating account or user country ISO code', error);
                });

            updateAccountCountry({ countryIsoCode: this.selectedCountry })
                .then(result => {
                    console.log('Account country ISO code updated successfully',result);
                })
                .catch(error => {
                    console.error('Error updating account or user country ISO code', error);
                });
                
                console.log('Publishing message:', selectedValue);
                publish(this.messageContext, MY_MESSAGE_CHANNEL, selectedValue);
                
                const params = new URLSearchParams(window.location.search);
                params.set('country', this.selectedCountry);
                const paramString = params.toString();

                // Extract the substring
                const newUrl = `${window.location.origin}${window.location.pathname}?${paramString.substring(0, 2)}`;
                console.log('newurl of loggedinuser', newUrl);
                window.history.replaceState({}, '', newUrl);

    }

    openCountryList() {
        this.showCountryList = true;
        console.log('openCountryList',this.showCountryList);
    }

    closeCountryList() {
        this.showCountryList = false;
    }
}