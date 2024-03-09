public with sharing class AccountHelper {

    public static void setAccountTypeToProspect (List<Account> accountList) {
        if (!accountList.isEmpty()) {
            for (Account acc : accountList) {
                if (acc.Type == null) {
                    acc.Type = 'Prospect';
                }
            }
        }
    }

    public static void copyShippingToBilling (List<Account> accountList) {
        // Having an if for each address field mapping sounded annoying, so I tried this. Let me know if this isn't a good idea though!
        if (!accountList.isEmpty()) {
            Set<String> shippingFields = new Set<String>{
                'ShippingStreet', 'ShippingCity', 'ShippingState', 'ShippingCountry', 'ShippingPostalCode'};
            for (Account acc : accountList) {
                Map<String, Object> accPopulatedFields = acc.getPopulatedFieldsAsMap();
                for (String addressField : shippingFields) {
                    String shippingFieldValue = (String)accPopulatedFields.get(addressField);
                    if (shippingFieldValue != null) {
                        // If the value is not null, populate it in the corresponding Billing field
                        acc.put(addressField.replace('Shipping', 'Billing'), shippingFieldValue);
                    }
                }
            }
        }
    }

    public static void setRatingAsHot (List<Account> accountList) {
        if (!accountList.isEmpty()) {
            for (Account acc : accountList) {
                if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
                    acc.Rating = 'Hot';
                }
            }
        }
    }

    public static void createDefaultContact (List<Account> accountList) {
        final String DEFAULT_LAST_NAME = 'DefaultContact';
        final String DEFAULT_EMAIL = 'default@email.com';
        if (!accountList.isEmpty()) {
            List<Contact> newContacts = new List<Contact>();
            for (Account acc : accountList) {
                Contact defaultContact = new Contact (
                    LastName = DEFAULT_LAST_NAME,
                    Email = DEFAULT_EMAIL,
                    AccountId = acc.Id);
                newContacts.add(defaultContact);
            }
            try {
                insert newContacts;
            } catch (DmlException e) {
                System.debug('A DML exception has occurred: ' + e.getMessage());
            }
        }
    }
}