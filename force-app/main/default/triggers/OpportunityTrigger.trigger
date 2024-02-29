trigger OpportunityTrigger on Opportunity (before update, before delete) {
    switch on Trigger.operationType.name() {
        when 'BEFORE_UPDATE' {
            OpportunityTriggerHandler.beforeUpdate(Trigger.new, Trigger.newMap);
        }
        when 'BEFORE_DELETE' {
            OpportunityTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
    }
}