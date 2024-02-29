public with sharing class OpportunityHelper {

    public static void validateOppAmount (List<Opportunity> oppList) {
        if (!oppList.isEmpty()) {
            final String ERROR_MESSAGE = 'Opportunity amount must be greater than 5000';
            for (Opportunity opp : oppList) {
                if (opp.Amount <= 5000) {
                    opp.addError(ERROR_MESSAGE);
                }
            }
        }
    }

    public static void setOppPrimaryContactToCeo (List<Opportunity> oppList, Map<Id, Opportunity> oppsById) {
        if (!oppList.isEmpty()) {
            final String CONTACT_TITLE_TO_QUERY = 'CEO';
            Set<Id> oppIds = new Set<Id>(oppsById.keySet());
            Set<Id> accountIdsFromOpps = new Set<Id>();
            for (Opportunity opp : oppList) {
                    accountIdsFromOpps.add(opp.AccountId);
            }
            List<Account> accCeoContactAndOppsToUpdate = [
                // This query took some work trial / error, so I'm definitely curious if there is a better way
                // Get Accounts associated with the Opps in the Trigger
                SELECT Id, 
                    // Get 1 Contact associated with each Account that has the target Title
                    (SELECT Id, Title
                    FROM Contacts
                    WHERE Title = :CONTACT_TITLE_TO_QUERY
                    LIMIT 1), 
                    // Get all child Opps from the Trigger that don't have a Primary Contact with the target Title
                    (SELECT Id, Primary_Contact__c
                    FROM Opportunities
                    WHERE Id IN :oppIds
                    AND Primary_Contact__r.Title != :CONTACT_TITLE_TO_QUERY)
                FROM Account
                WHERE Id IN :accountIdsFromOpps
                // Filter so Accounts (+ their child records) are only returned if the Account has a Contact with the target Title...
                AND Id IN (
                    SELECT AccountId
                    FROM Contact
                    WHERE Title = :CONTACT_TITLE_TO_QUERY)
                // ... and at least 1 Opp from the Trigger that doesn't have a Primary Contact with the target title (the opps to update)
                AND Id IN (
                    SELECT AccountId
                    FROM Opportunity
                    WHERE Id IN :oppIds
                    AND Primary_Contact__r.Title != :CONTACT_TITLE_TO_QUERY)
            ];
            // Loop the Accounts and their respective Opps to set the Primary Contact to the CEO Contact
            if (!accCeoContactAndOppsToUpdate.isEmpty()) {
                for (Account account : accCeoContactAndOppsToUpdate) {
                    for (Opportunity opportunity : account.Opportunities) {
                        oppsById.get(opportunity.Id).Primary_Contact__c = account.Contacts.get(0).Id;
                    }
                }
            }
        }
    }
    
    public static void blockClosedWonBankingDeletion (List<Opportunity> oppList, Map<Id, Opportunity> oppsById) {
        if (!oppList.isEmpty()) {
            final String OPP_STAGE_TO_BLOCK = 'Closed Won';
            final String INDUSTRY_TO_BLOCK = 'Banking';
            Set<Id> oppIds = oppsById.keySet();
            List<Opportunity> oppsToBlockDeletion = [
                SELECT Id, StageName, Account.Industry
                FROM Opportunity
                WHERE Id IN :oppIds
                AND StageName = :OPP_STAGE_TO_BLOCK
                AND Account.Industry = :INDUSTRY_TO_BLOCK
            ];
            if (!oppsToBlockDeletion.isEmpty()) {
                final String NO_DELETION_MESSAGE = 'Cannot delete closed opportunity for a banking account that is won';
                for (Opportunity opportunity : oppsToBlockDeletion) {
                    oppsById.get(opportunity.Id).addError(NO_DELETION_MESSAGE);
                }
            }
        }
    }
}