@isTest
private class OrderServiceTest {

    @testSetup
    static void setup() {
        // Crée un compte particulier
        Account acc = new Account(Name = 'Compte Test', Type_of_client__c = 'Particulier');
        insert acc;

        // Création des produits nécessaires
        Product2 prod = new Product2(Name = 'Produit Test', IsActive = true);
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 10,
            IsActive = true
        );
        insert pbe;

        // Créer une commande associée au compte
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = pricebookId
        );
        insert ord;

        // Ajouter 2 produits (pas assez pour un particulier)
        OrderItem item1 = new OrderItem(OrderId = ord.Id, Quantity = 1, UnitPrice = 10, PricebookEntryId = pbe.Id);
        OrderItem item2 = new OrderItem(OrderId = ord.Id, Quantity = 1, UnitPrice = 10, PricebookEntryId = pbe.Id);
        insert new List<OrderItem>{ item1, item2 };
    }

    @isTest
    static void testValidateOrder_particulierNotEnoughItems() {
        // Requête pour récupérer les données créées en setup
        Account acc = [SELECT Id FROM Account WHERE Name = 'Compte Test' LIMIT 1];
        Id pricebookId = Test.getStandardPricebookId();
        Order ord = [SELECT Id, Status FROM Order WHERE AccountId = :acc.Id AND Status = 'Draft' LIMIT 1];

        // Changer le statut à 'Activated' pour déclencher le trigger
        ord.Status = 'Activated';

        Test.startTest();
        try {
            update ord;
            System.assert(false, 'Une erreur aurait dû être levée pour un particulier avec moins de 3 produits');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Un particulier doit commander au moins 3 produits'), 'Message d’erreur attendu manquant');
        }
        Test.stopTest();
    }
}