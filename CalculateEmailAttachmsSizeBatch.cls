public with sharing class CalculateEmailAttachmsSizeBatch implements Database.Batchable<SObject> {

    public String query;

    public CalculateEmailAttachmsSizeBatch() {
        this.query = 'SELECT Id, (SELECT Id, BodyLength from Attachments), ' +
                    '(SELECT Id, ContentDocument.ContentSize from ContentDocumentLinks) Attachments_Size__c, Record_Link__c, Number_Of_Attachments__c ' +
                    'FROM EmailMessage ';
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){
        List<EmailMessage> messages = (List<EmailMessage>)scope;
        List<EmailMessage> messagesToUpdate = new List<EmailMessage>();
        for(EmailMessage message : messages){
            Decimal attachmentsSize = 0;
            Decimal attachmentsNumber = 0;
            if(message.Attachments.size() > 0) {
                for(Attachment attachmt: message.Attachments) {
                    attachmentsSize += attachmt.BodyLength;
                    attachmentsNumber++;
                }
            }
            if(message.ContentDocumentLinks.size() > 0) {
                for(ContentDocumentLink attachmt: message.ContentDocumentLinks) {
                    attachmentsSize += attachmt.ContentDocument.ContentSize;
                    attachmentsNumber++;
                }
            } 
            EmailMessage em = new EmailMessage(
                Id = message.Id,
                Attachments_Size__c = attachmentsSize / 1000000,
                Number_Of_Attachments__c = attachmentsNumber,
                Record_Link__c = URL.getSalesforceBaseUrl().toExternalForm()+ '/' + message.Id
            );
            messagesToUpdate.add(em);       
        }
        Database.update(messagesToUpdate, false);
    }

    public void finish(Database.BatchableContext BC){
    }
}