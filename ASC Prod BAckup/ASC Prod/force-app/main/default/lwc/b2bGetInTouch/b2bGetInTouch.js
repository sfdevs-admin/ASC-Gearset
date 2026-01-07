import { LightningElement, track ,api} from 'lwc';
import Toast from 'lightning/toast';
import createCase from '@salesforce/apex/B2B_GetInTouchController.createCase';
import FirstName from '@salesforce/label/c.B2BGetInTouch_FirstName';
import LastName from '@salesforce/label/c.B2BGetInTouch_LastName';
import Email from '@salesforce/label/c.B2BGetInTouch_Email';
import PhoneNumber from '@salesforce/label/c.B2BGetInTouch_PhoneNumber';
import Message from '@salesforce/label/c.B2BGetInTouch_Message';
import Consent from '@salesforce/label/c.B2BGetInTouch_Consent'
import Submit from '@salesforce/label/c.B2BGetInTouch_Submit';
import ToastSuccess from '@salesforce/label/c.B2BGetInTouch_ToastSuccess';
import ToastError from '@salesforce/label/c.B2BGetInTouch_ToastError'


export default class B2BGetInTouch extends LightningElement {
    static renderMode = 'light';
    // Tracking input values
    recordId;
    isSampleProduct = false;
    label = {
        firstName : FirstName,
        
        lastName : LastName,
        email : Email,
        phoneNumber : PhoneNumber,
        message : Message,
        consent : Consent,
        submit : Submit,
        toastSuccess : ToastSuccess,
        toastError : ToastError

    };
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track phoneNumber = '';
    @track message = '';
    consent = false;
    showSpinner = false;
    messageState = 'Please wait while your case is being created';

    @api 
    get productDetails(){
        
    }
    set productDetails(val){
        if (val) {
            console.log('Val==>', val);
            console.log('label==>',this.label);
            this.recordId = val.id;
            this.isSampleProduct = val.fields?.B2B_Is_Simple_Product__c === 'false' ? false : true;
            console.log('recordId set to:', this.recordId);
        } else {
            console.error('Invalid value passed to productDetails:', val);
        }
    }
    // Method to handle input changes
    handleInputChange(event) {
        const field = event.target.placeholder;
        console.log('field==>', field);
        console.log('this.firstName==>', this.firstName);
        if (field === this.label.firstName) {
            this.firstName = event.target.value.trim();
            console.log('this.firstName==>', this.firstName);
        } else if (field === this.label.lastName) {
            this.lastName = event.target.value.trim();
            console.log('this.lastName==>', this.lastName);
        } else if (field === this.label.email) {
            this.email = event.target.value.trim();
            console.log('this.email==>', this.email);
        } else if (field === this.label.phoneNumber) {
            this.phoneNumber = event.target.value.trim();
            console.log('this.phoneNumber==>', this.phoneNumber);
        } else if (field === this.label.message) {
            this.message = event.target.value.trim();
            console.log('this.message==>', this.message);
        }
    }
    handleCheckboxChange(event) {
        this.consent = event.target.checked;
        console.log('Consent==>', this.consent);
        console.log('ToastSuccess==>',this.label.toastSuccess);
    }
 
    async handleSubmit() {
        
        if (!this.firstName || this.firstName == '' || 
            !this.lastName || this.lastName == '' || 
            !this.email || this.email == '' || 
            !this.phoneNumber || this.phoneNumber == '' || 
            !this.message || this.message == '' ||
            !this.consent
        ) {
            console.log('Submit button for error working');
            this.showErrorToastLWR('Error', this.label.toastError, 'error', 'dismissible');

           
        } else {
            this.showSpinner = true;
            const mapParams = {
                firstName: this.firstName,
                lastName: this.lastName,
                email: this.email,
                phoneNumber: this.phoneNumber,
                message: this.message,
                SimpleProductRecordId: this.recordId
            };
    
            await createCase({
                'mapParams' : mapParams
            }).then((res) => {
                let response = JSON.parse(JSON.stringify(res));
                console.log('B2BGetInTouch createCase res---- ', response);
                if(res.isSuccess){
                    this.showSpinner = false;
                    // this.goToCategory(response.elementsList[0]);
                    this.showSuccessToastLWR('Success', this.label.toastSuccess, 'success', 'dismissible');
                }else{
                    //show no data found error
                    this.showSpinner = false;
                    console.log('B2BGetInTouch createCase is success false---- '+ JSON.stringify(res));
                    this.showSuccessToastLWR('Error', 'There was some error, please contact admin', 'error', 'dismissible');
                }
            }).catch((e) => {
                this.showSpinner = false;
                console.log('B2BGetInTouch createCase catch---- '+ JSON.stringify(e));
                this.showSuccessToastLWR('Error', 'There was some error, please contact admin', 'error', 'dismissible');
            });
      
       
         
        }
    }

    showErrorToastLWR( label, message,  variant, mode ) {
        console.log('Error!Please check your code');
        Toast.show({
            label: label,
            message: message,
            variant: variant,
            mode: mode, //'sticky', dismissible
        }, this);
    }
   
 
    showSuccessToastLWR( label, message,  variant, mode ) {
        console.log('YAY!Succeesss!!');
        Toast.show({
            label: label,
            message: message,
            variant: variant,
            mode: mode, //'sticky', dismissible
        }, this);
    }

}