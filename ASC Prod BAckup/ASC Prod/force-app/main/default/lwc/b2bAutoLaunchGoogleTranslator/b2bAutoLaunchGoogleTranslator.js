import { LightningElement } from 'lwc';
export default class B2bAutoLaunchGoogleTranslator extends LightningElement {
    static renderMode = 'light';
    showTooltip = false;

    toggleTooltip() {
        this.showTooltip = !this.showTooltip;
    }
}