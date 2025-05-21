import { LightningElement, api } from 'lwc';
// importattion d'une variable booléen liée à la Custom Permission SF ==> Can_Send_Order
import hasPermission from '@salesforce/customPermission/Can_Send_Order';

export default class ChooseTransporter extends LightningElement {
    @api recordId; // id de l'Order puisque l'on passe une commande
    selectedOption = null; // Stock l'option radio sélectionnée
    hasPermission = hasPermission; // Stocke la valeur importée pour simplifier l'accès dans le template

    options = [
        { label: 'Option la plus rapide', value: 'fastest' },
        { label: 'Option la moins chère', value: 'cheapest' }
    ]; // Choix à afficher dans le radio group

    handleChange(event) {
        this.selectedOption = event.target.value;
    } // Stocke l'option radio dans selectedOption

    handleSubmit() {
        if (!this.hasPermission) {
            alert("Vous n'avez pas la permission d'envoyer une commande.");
            return;
        } // Méthode déclenchée au clic sur le bouton "Envoyer la commande"
        // logique d’envoi ou de sauvegarde du transporteur
        console.log('Commande envoyée avec :', this.selectedOption);
        // !!!!!!!!! APEX ici pour enregistrer le choix !!!!!!!!!!!!!!
    }
}