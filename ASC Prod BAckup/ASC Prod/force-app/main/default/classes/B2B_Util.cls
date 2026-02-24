/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 02-02-2026
 * @last modified by  : Swati Chilap
 * @Testclass         : B2B_CsvExportControllerTest
**/
public with sharing class B2B_Util {
    public static User getEffectiveAccountId() {
        return [
            SELECT Id, AccountId, ContactId, Contact.Email, Contact.Name, CurrencyISOCode
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
    }

    public static Network getNetworkDetails() {
        return [
            SELECT Id
            FROM Network
            WHERE Name = 'Ascensus'
            LIMIT 1
        ];
    }

    /**
     * Returns OrgWideEmailAddress Id based on user's currency
     */
    public static Id getOrgWideEmailAddressId(User userDetails) {

        if (userDetails == null) {
            return null;
        }

        String displayName =
            userDetails.CurrencyIsoCode == 'EUR'
                ? 'Info europe'
                : 'Info';

        List<OrgWideEmailAddress> oweaList = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE DisplayName = :displayName
            LIMIT 1
        ];

        return oweaList.isEmpty() ? null : oweaList[0].Id;
    }
}