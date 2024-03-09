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
            Set<Id> accountIdsFromOpps = new Set<Id>();
            for (Opportunity opp : oppList) {
                    accountIdsFromOpps.add(opp.AccountId);
            }
            // Get Opps in the Trigger that do not have a Primary Contact with the correct Title
            List<Opportunity> oppsWithoutTitle = [
                SELECT Id, AccountId, Primary_Contact__r.Title
                FROM Opportunity
                WHERE Id IN :oppsById.keySet()
                AND Primary_Contact__r.Title != :CONTACT_TITLE_TO_QUERY
            ];
            // From the Accounts associated with the Opps in the Trigger, get all Contacts that have the correct title
            List<Contact> contactsWithTitle = [
                SELECT Id, AccountId, Title 
                FROM Contact
                WHERE AccountId IN :accountIdsFromOpps
                AND Title = :CONTACT_TITLE_TO_QUERY
            ];
            Map<Id, Contact> contactWithTitleByAccountId = new Map<Id, Contact>();
            for (Contact con : contactsWithTitle) {
                Id contactAccountId = con.AccountId;
                // If the Map doesn't already contain the Account Id and Contact with the target Title, add it to the Map
                if (contactWithTitleByAccountId.get(contactAccountId) == null) {
                    contactWithTitleByAccountId.put(contactAccountId, con);
                }
            }
            for (Opportunity opp : oppsWithoutTitle) {
                Contact accountContactWithTitle = contactWithTitleByAccountId.get(opp.AccountId);
                // If the Map contains the Account on the Opp, set the Primary Contact on the Opp to the associated Contact in the Map
                // If the Map doesn't contain the Account on the Opp, it has no Contact with the correct title, so take no action
                if (accountContactWithTitle != null) {
                    oppsById.get(opp.Id).Primary_Contact__c = accountContactWithTitle.Id;
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