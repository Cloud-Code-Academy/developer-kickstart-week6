public with sharing class AccountTriggerHandler {

    public static void beforeInsert(List<Account> triggerDotNew) {
        AccountHelper.setAccountTypeToProspect(triggerDotNew);
        AccountHelper.copyShippingToBilling(triggerDotNew);
        AccountHelper.setRatingAsHot(triggerDotNew);
    }

    public static void afterInsert(List<Account> triggerDotNew) {
        AccountHelper.createDefaultContact(triggerDotNew);
    }
}