@isTest
private class AccountSelectorTest {

    static Account testAccount;

    @testSetup
    static void setup() {
        // Créer un compte fictif
        testAccount = new Account(
            Name = 'Test Account',
            Type = 'Prospect',
            Industry = 'Technology',
            BillingCity = 'Paris',
            BillingCountry = 'France',
            Phone = '0102030405',
            Website = 'www.test.com',
            Type_of_client__c = 'Professionnel'
        );
        insert testAccount;
    }

    @isTest
    static void testGetAccountById_returnsAccount() {

        // Récupérer le compte fictif via requête
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Appeler la méthode à tester
        Account result = AccountSelector.getAccountById(acc.Id);

        // Vérifier que l’account retourné est bien celui qu’on a inséré ==> cas positif
        System.assertNotEquals(null, result);
        System.assertEquals(acc.Id, result.Id);
        System.assertEquals('Test Account', result.Name);
    }

    @isTest
    static void testGetAccountById_withNullId() {
        // Appeler la méthode avec un ID null
        Account result = AccountSelector.getAccountById(null);

        // Vérifier que ça retourne bien null ==> cas négatif
        System.assertEquals(null, result);
    }
}