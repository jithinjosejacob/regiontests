describe('Check Microsoft Website', () => {

    it('Check Microsoft Website for every region', () => {
        cy.visit('https://www.microsoft.com/en-'+Cypress.env('region')+'/');
        // Wait for 2 mins
        cy.wait(120000);
    })
})
