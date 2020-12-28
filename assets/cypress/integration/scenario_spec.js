describe('Get Scenario Test', () => {
  it('Gets scenarios on Learn page load', () => {
    cy.intercept('POST', '/api/graphql', {
      statusCode: 200,
      body: '{"data":{"scenarios":[{"id3905593358":"1","startingState3832528868":"hello-cypress"}]}}'
    }).as('scenarios')

    cy.visit('http://localhost:4000')
    cy.wait('@scenarios')

    cy.get(".starting-state").contains("hello-cypress")
  })
})
