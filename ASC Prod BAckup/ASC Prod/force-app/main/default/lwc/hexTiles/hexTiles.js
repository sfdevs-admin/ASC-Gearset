/**
 * @description       : 
 * @author            : Mradul Maheshwari
 * @group             : 
 * @last modified on  : 14-07-2025
 * @last modified by  : Mradul Maheshwari
**/
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class HexTiles extends NavigationMixin(LightningElement) {
  tiles = [
    { label: 'ALD/CVD', style: 'background-color: #00A5A8; color: white;', url: '/cvd-ald' },
    { label: 'Catalysis', style: 'background-color: #E69F00; color: black;', url: '/catalysis' },
    { label: 'Materials Science', style: 'background-color: #00A5A8; color: white;', url: '/catalog/products/material-science/0ZGVN00000000uT4AQ' },
    { label: 'Screening Kits', style: 'background-color: #E69F00; color: black;', url: '/catalog/kits' },
    { label: 'New Products', style: 'background-color: #00A5A8; color: white;', url: '/catalog/products/new-products/0ZGVN00000000w54AA' }
  ];

  handleTileClick(event) {
    const url = event.currentTarget.dataset.url;

    this[NavigationMixin.Navigate](
      {
        type: 'standard__webPage',
        attributes: {
          url: url
        }
      },
      true // open in same tab
    );
  }
}