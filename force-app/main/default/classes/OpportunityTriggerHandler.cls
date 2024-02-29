public with sharing class OpportunityTriggerHandler {

    public static void beforeUpdate(List<Opportunity> triggerDotNew, Map<Id, Opportunity> triggerDotNewMap) {
        OpportunityHelper.validateOppAmount(triggerDotNew);
        OpportunityHelper.setOppPrimaryContactToCeo(triggerDotNew, triggerDotNewMap);
    }
    
    public static void beforeDelete(List<Opportunity> triggerDotOld, Map<Id, Opportunity> triggerDotOldMap) {
        OpportunityHelper.blockClosedWonBankingDeletion(triggerDotOld, triggerDotOldMap);
    }
}