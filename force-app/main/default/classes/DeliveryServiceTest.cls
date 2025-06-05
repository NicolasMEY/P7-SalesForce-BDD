@isTest
private class DeliveryServiceTest {

    @testSetup
    static void setup() {
        // Crée un compte simple
        Account transporter = new Account(Name = 'Test Transporter', Type_of_client__c = 'Professionnel');
        insert transporter;

        // Crée une commande minimale valide
        Order order = new Order(
            AccountId = transporter.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert order;
    }

    @isTest
    static void testNoRate() {
        // Requête SOQL incluant Transporter__c (même si null)
        Order order = [SELECT Id, Transporter__c FROM Order WHERE Status = 'Draft' LIMIT 1];

        Test.startTest();
        DeliveryService.createDeliveryForOrder(order);
        Test.stopTest();

        Integer countDeliveries = [SELECT count() FROM Delivery__c WHERE Order__c = :order.Id];
        System.assertEquals(0, countDeliveries, 'Aucune livraison ne doit être créée quand il n’y a pas de tarif');
    }
}