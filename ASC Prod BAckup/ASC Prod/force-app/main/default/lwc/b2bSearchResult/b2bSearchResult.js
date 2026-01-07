import { LightningElement, api, track } from 'lwc';

export default class B2bSearchResult extends LightningElement {
    @api showCategoyBannerImage;
    @api recordId;
    @api resultsLayout;
    @api showProductImage;
    toggleImage = '/sfsites/c/resource/strem_css/images/buttons/slider_more.gif';
    toggleOpenText = 'Open Section';
    productCategory = 
    {
        "category": {
          "id": 123456789,
          "name": "Ligands & Chiral Ligands",
          "showProductList": false,
          "toggleImage" : this.toggleImage,
          "toggleAltText": this.toggleOpenText, 
          "showProducts" : false,
          "category" : [
            {
                "id": "65eb9540f6f44349b91f9c46",
                "name": "Ammonium ",
                "showProductList": false,
                "toggleImage" : this.toggleImage,
                "toggleAltText": this.toggleOpenText, 
                "showProducts" : false,
                "catalogNumber": "23",
                "products": [
                    {
                      "id": "65eb9540f6f44349b91f9c46",
                      "name": "Triethylarsine, 99% ",
                      "catalogNumber": "33-3400",
                      "isActive": true,
                      "description": "Qui aliqua eiusmod deserunt sit qui. Reprehenderit fugiat ullamco voluptate sunt incididunt ea et laborum deserunt ex. In officia velit sit consequat. Proident amet exercitation amet qui velit aliquip cupidatat ad occaecat.\r\n",
                      "casNumber": "617-75-4",
                      "image": "https://via.placeholder.com/250x250",
                      "isImageVisible" : false
                    },
                    {
                      "id": "65eb954007df53bf275dbd88",
                      "name": "Trimethylarsine, 99%",
                      "catalogNumber": "33-3750",
                      "isActive": true,
                      "description": "Ullamco sint dolore laborum laborum sunt in reprehenderit reprehenderit ex ad pariatur in non. Lorem eu proident magna tempor laboris eiusmod sunt dolor ad deserunt adipisicing. In nisi in sit ex dolor aute voluptate non commodo dolor sunt laborum. Ut sint cupidatat irure eiusmod laborum esse elit sint. Dolor elit nulla nostrud minim cupidatat ipsum commodo ipsum cillum reprehenderit veniam occaecat. Eiusmod et ea incididunt id est sunt nostrud eu commodo ea. Enim et amet labore commodo est nisi consequat.\r\n",
                      "casNumber": "593-88-4",
                      "image": "https://via.placeholder.com/250x250",
                      "isImageVisible" : false
                    },
                    {
                      "id": "65eb95403d4ba03cf3e847c0",
                      "name": "Trimethylarsine, elec. gr. (99.995%-As) PURATREM",
                      "catalogNumber": "98-1975",
                      "isActive": false,
                      "description": "Ut proident et sit nostrud duis. Duis ea laboris mollit eiusmod qui culpa minim eiusmod sit cupidatat. Ea aliquip commodo laboris Lorem voluptate proident cupidatat duis dolore do. Veniam eiusmod voluptate tempor velit qui.\r\n",
                      "casNumber": "593-88-4",
                      "image": "https://via.placeholder.com/250x250",
                      "isImageVisible" : false
                    },
                    {
                      "id": "65eb9540aae19d41be5ae3e3",
                      "name": "Triphenylarsine, min. 97%",
                      "catalogNumber": "33-4000",
                      "isActive": true,
                      "description": "Aute enim tempor sit quis aliquip culpa tempor ex mollit pariatur occaecat sint ipsum. Et eiusmod nulla eu do laborum elit fugiat consequat incididunt do est esse reprehenderit. Et nostrud incididunt duis tempor quis anim ut dolor sint ex deserunt commodo qui fugiat.\r\n",
                      "casNumber": "603-32-7",
                      "image": "https://via.placeholder.com/250x250",
                      "isImageVisible" : false
                    },
                    {
                      "id": "65eb954049cb38f06d479da2",
                      "name": "Tris(dimethylamino)arsine, 99%",
                      "catalogNumber": "33-5000",
                      "isActive": true,
                      "description": "Enim magna do ipsum sunt et. Culpa velit sint excepteur pariatur labore sint minim sunt do occaecat. Id voluptate do culpa anim officia officia nisi non occaecat. Elit commodo ipsum et occaecat laborum.\r\n",
                      "casNumber": "6596-96-9",
                      "image": "https://via.placeholder.com/250x250",
                      "isImageVisible" : false
                    }
                  ]                
              },
              {
                "id": "65eb954007df53bf275dbd88",
                "name": "Carbon",
                "showProductList": false,
                "toggleImage" : this.toggleImage,
                "toggleAltText": this.toggleOpenText, 
                "showProducts" : false,
                "catalogNumber": "38",
                "products": [
                  {
                    "id": "65eb9540f6f44349b91f9c46",
                    "name": "Triethylarsine, 99% ",
                    "catalogNumber": "33-3400",
                    "isActive": true,
                    "description": "Qui aliqua eiusmod deserunt sit qui. Reprehenderit fugiat ullamco voluptate sunt incididunt ea et laborum deserunt ex. In officia velit sit consequat. Proident amet exercitation amet qui velit aliquip cupidatat ad occaecat.\r\n",
                    "casNumber": "617-75-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb954007df53bf275dbd88",
                    "name": "Trimethylarsine, 99%",
                    "catalogNumber": "33-3750",
                    "isActive": true,
                    "description": "Ullamco sint dolore laborum laborum sunt in reprehenderit reprehenderit ex ad pariatur in non. Lorem eu proident magna tempor laboris eiusmod sunt dolor ad deserunt adipisicing. In nisi in sit ex dolor aute voluptate non commodo dolor sunt laborum. Ut sint cupidatat irure eiusmod laborum esse elit sint. Dolor elit nulla nostrud minim cupidatat ipsum commodo ipsum cillum reprehenderit veniam occaecat. Eiusmod et ea incididunt id est sunt nostrud eu commodo ea. Enim et amet labore commodo est nisi consequat.\r\n",
                    "casNumber": "593-88-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb95403d4ba03cf3e847c0",
                    "name": "Trimethylarsine, elec. gr. (99.995%-As) PURATREM",
                    "catalogNumber": "98-1975",
                    "isActive": false,
                    "description": "Ut proident et sit nostrud duis. Duis ea laboris mollit eiusmod qui culpa minim eiusmod sit cupidatat. Ea aliquip commodo laboris Lorem voluptate proident cupidatat duis dolore do. Veniam eiusmod voluptate tempor velit qui.\r\n",
                    "casNumber": "593-88-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb9540aae19d41be5ae3e3",
                    "name": "Triphenylarsine, min. 97%",
                    "catalogNumber": "33-4000",
                    "isActive": true,
                    "description": "Aute enim tempor sit quis aliquip culpa tempor ex mollit pariatur occaecat sint ipsum. Et eiusmod nulla eu do laborum elit fugiat consequat incididunt do est esse reprehenderit. Et nostrud incididunt duis tempor quis anim ut dolor sint ex deserunt commodo qui fugiat.\r\n",
                    "casNumber": "603-32-7",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb954049cb38f06d479da2",
                    "name": "Tris(dimethylamino)arsine, 99%",
                    "catalogNumber": "33-5000",
                    "isActive": true,
                    "description": "Enim magna do ipsum sunt et. Culpa velit sint excepteur pariatur labore sint minim sunt do occaecat. Id voluptate do culpa anim officia officia nisi non occaecat. Elit commodo ipsum et occaecat laborum.\r\n",
                    "casNumber": "6596-96-9",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  }
                ]
              },
              {
                "id": "65eb95403d4ba03cf3e847c0",
                "name": "Fluorine",
                "showProductList": false,
                "toggleImage" : this.toggleImage,
                "toggleAltText": this.toggleOpenText, 
                "showProducts" : false,
                "catalogNumber": "25",
                "products": [
                  {
                    "id": "65eb9540f6f44349b91f9c46",
                    "name": "Triethylarsine, 99% ",
                    "catalogNumber": "33-3400",
                    "isActive": true,
                    "description": "Qui aliqua eiusmod deserunt sit qui. Reprehenderit fugiat ullamco voluptate sunt incididunt ea et laborum deserunt ex. In officia velit sit consequat. Proident amet exercitation amet qui velit aliquip cupidatat ad occaecat.\r\n",
                    "casNumber": "617-75-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb954007df53bf275dbd88",
                    "name": "Trimethylarsine, 99%",
                    "catalogNumber": "33-3750",
                    "isActive": true,
                    "description": "Ullamco sint dolore laborum laborum sunt in reprehenderit reprehenderit ex ad pariatur in non. Lorem eu proident magna tempor laboris eiusmod sunt dolor ad deserunt adipisicing. In nisi in sit ex dolor aute voluptate non commodo dolor sunt laborum. Ut sint cupidatat irure eiusmod laborum esse elit sint. Dolor elit nulla nostrud minim cupidatat ipsum commodo ipsum cillum reprehenderit veniam occaecat. Eiusmod et ea incididunt id est sunt nostrud eu commodo ea. Enim et amet labore commodo est nisi consequat.\r\n",
                    "casNumber": "593-88-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb95403d4ba03cf3e847c0",
                    "name": "Trimethylarsine, elec. gr. (99.995%-As) PURATREM",
                    "catalogNumber": "98-1975",
                    "isActive": false,
                    "description": "Ut proident et sit nostrud duis. Duis ea laboris mollit eiusmod qui culpa minim eiusmod sit cupidatat. Ea aliquip commodo laboris Lorem voluptate proident cupidatat duis dolore do. Veniam eiusmod voluptate tempor velit qui.\r\n",
                    "casNumber": "593-88-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb9540aae19d41be5ae3e3",
                    "name": "Triphenylarsine, min. 97%",
                    "catalogNumber": "33-4000",
                    "isActive": true,
                    "description": "Aute enim tempor sit quis aliquip culpa tempor ex mollit pariatur occaecat sint ipsum. Et eiusmod nulla eu do laborum elit fugiat consequat incididunt do est esse reprehenderit. Et nostrud incididunt duis tempor quis anim ut dolor sint ex deserunt commodo qui fugiat.\r\n",
                    "casNumber": "603-32-7",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb954049cb38f06d479da2",
                    "name": "Tris(dimethylamino)arsine, 99%",
                    "catalogNumber": "33-5000",
                    "isActive": true,
                    "description": "Enim magna do ipsum sunt et. Culpa velit sint excepteur pariatur labore sint minim sunt do occaecat. Id voluptate do culpa anim officia officia nisi non occaecat. Elit commodo ipsum et occaecat laborum.\r\n",
                    "casNumber": "6596-96-9",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  }
                ]
              },
              {
                "id": "65eb9540aae19d41be5ae3e3",
                "name": "Ionic Liquids",
                "showProductList": false,
                "toggleImage" : this.toggleImage,
                "toggleAltText": this.toggleOpenText, 
                "showProducts" : false,
                "catalogNumber": "79",
                "products": [
                  {
                    "id": "65eb9540f6f44349b91f9c46",
                    "name": "Triethylarsine, 99% ",
                    "catalogNumber": "33-3400",
                    "isActive": true,
                    "description": "Qui aliqua eiusmod deserunt sit qui. Reprehenderit fugiat ullamco voluptate sunt incididunt ea et laborum deserunt ex. In officia velit sit consequat. Proident amet exercitation amet qui velit aliquip cupidatat ad occaecat.\r\n",
                    "casNumber": "617-75-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb954007df53bf275dbd88",
                    "name": "Trimethylarsine, 99%",
                    "catalogNumber": "33-3750",
                    "isActive": true,
                    "description": "Ullamco sint dolore laborum laborum sunt in reprehenderit reprehenderit ex ad pariatur in non. Lorem eu proident magna tempor laboris eiusmod sunt dolor ad deserunt adipisicing. In nisi in sit ex dolor aute voluptate non commodo dolor sunt laborum. Ut sint cupidatat irure eiusmod laborum esse elit sint. Dolor elit nulla nostrud minim cupidatat ipsum commodo ipsum cillum reprehenderit veniam occaecat. Eiusmod et ea incididunt id est sunt nostrud eu commodo ea. Enim et amet labore commodo est nisi consequat.\r\n",
                    "casNumber": "593-88-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb95403d4ba03cf3e847c0",
                    "name": "Trimethylarsine, elec. gr. (99.995%-As) PURATREM",
                    "catalogNumber": "98-1975",
                    "isActive": false,
                    "description": "Ut proident et sit nostrud duis. Duis ea laboris mollit eiusmod qui culpa minim eiusmod sit cupidatat. Ea aliquip commodo laboris Lorem voluptate proident cupidatat duis dolore do. Veniam eiusmod voluptate tempor velit qui.\r\n",
                    "casNumber": "593-88-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb9540aae19d41be5ae3e3",
                    "name": "Triphenylarsine, min. 97%",
                    "catalogNumber": "33-4000",
                    "isActive": true,
                    "description": "Aute enim tempor sit quis aliquip culpa tempor ex mollit pariatur occaecat sint ipsum. Et eiusmod nulla eu do laborum elit fugiat consequat incididunt do est esse reprehenderit. Et nostrud incididunt duis tempor quis anim ut dolor sint ex deserunt commodo qui fugiat.\r\n",
                    "casNumber": "603-32-7",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb954049cb38f06d479da2",
                    "name": "Tris(dimethylamino)arsine, 99%",
                    "catalogNumber": "33-5000",
                    "isActive": true,
                    "description": "Enim magna do ipsum sunt et. Culpa velit sint excepteur pariatur labore sint minim sunt do occaecat. Id voluptate do culpa anim officia officia nisi non occaecat. Elit commodo ipsum et occaecat laborum.\r\n",
                    "casNumber": "6596-96-9",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  }
                ]
              },
              {
                "id": "65eb954049cb38f06d479da2",
                "name": "Iron",
                "showProductList": false,
                "toggleImage" : this.toggleImage,
                "toggleAltText": this.toggleOpenText, 
                "showProducts" : false,
                "catalogNumber": "23",
                "products": [
                  {
                    "id": "65eb9540f6f44349b91f9c46",
                    "name": "Triethylarsine, 99% ",
                    "catalogNumber": "33-3400",
                    "isActive": true,
                    "description": "Qui aliqua eiusmod deserunt sit qui. Reprehenderit fugiat ullamco voluptate sunt incididunt ea et laborum deserunt ex. In officia velit sit consequat. Proident amet exercitation amet qui velit aliquip cupidatat ad occaecat.\r\n",
                    "casNumber": "617-75-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb954007df53bf275dbd88",
                    "name": "Trimethylarsine, 99%",
                    "catalogNumber": "33-3750",
                    "isActive": true,
                    "description": "Ullamco sint dolore laborum laborum sunt in reprehenderit reprehenderit ex ad pariatur in non. Lorem eu proident magna tempor laboris eiusmod sunt dolor ad deserunt adipisicing. In nisi in sit ex dolor aute voluptate non commodo dolor sunt laborum. Ut sint cupidatat irure eiusmod laborum esse elit sint. Dolor elit nulla nostrud minim cupidatat ipsum commodo ipsum cillum reprehenderit veniam occaecat. Eiusmod et ea incididunt id est sunt nostrud eu commodo ea. Enim et amet labore commodo est nisi consequat.\r\n",
                    "casNumber": "593-88-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb95403d4ba03cf3e847c0",
                    "name": "Trimethylarsine, elec. gr. (99.995%-As) PURATREM",
                    "catalogNumber": "98-1975",
                    "isActive": false,
                    "description": "Ut proident et sit nostrud duis. Duis ea laboris mollit eiusmod qui culpa minim eiusmod sit cupidatat. Ea aliquip commodo laboris Lorem voluptate proident cupidatat duis dolore do. Veniam eiusmod voluptate tempor velit qui.\r\n",
                    "casNumber": "593-88-4",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb9540aae19d41be5ae3e3",
                    "name": "Triphenylarsine, min. 97%",
                    "catalogNumber": "33-4000",
                    "isActive": true,
                    "description": "Aute enim tempor sit quis aliquip culpa tempor ex mollit pariatur occaecat sint ipsum. Et eiusmod nulla eu do laborum elit fugiat consequat incididunt do est esse reprehenderit. Et nostrud incididunt duis tempor quis anim ut dolor sint ex deserunt commodo qui fugiat.\r\n",
                    "casNumber": "603-32-7",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  },
                  {
                    "id": "65eb954049cb38f06d479da2",
                    "name": "Tris(dimethylamino)arsine, 99%",
                    "catalogNumber": "33-5000",
                    "isActive": true,
                    "description": "Enim magna do ipsum sunt et. Culpa velit sint excepteur pariatur labore sint minim sunt do occaecat. Id voluptate do culpa anim officia officia nisi non occaecat. Elit commodo ipsum et occaecat laborum.\r\n",
                    "casNumber": "6596-96-9",
                    "image": "https://via.placeholder.com/250x250",
                    "isImageVisible" : false
                  }
                ]
              }
          ],
        }
    }

    categoryTitle = this.productCategory?.category?.name;
    @track searchResultText = this.productCategory?.category?.category?.length > 0 ? 'Your search found ' + this.productCategory?.category?.category?.length + ' product results' : '';

    get hasCategories(){
      return this.productCategory?.category?.category?.length > 0
    }

    get getCategoryProducts(){
      // console.log('b2bSearchResult getCategoryProducts this.productCategory?.category?.category', this.productCategory?.category?.category)
      return this.productCategory?.category?.category
    }
}