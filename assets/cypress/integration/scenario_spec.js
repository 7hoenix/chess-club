describe('Get Scenario Test', () => {
  it('Gets scenarios on Learn page load', () => {
    cy.intercept('POST', '/api/graphql', {
      statusCode: 200,
      body: '{"data":{"scenarios":[{"id3905593358":"1"}]}}'
    }).as('scenarios')

    cy.visit('http://localhost:4000')
    cy.wait('@scenarios')

    cy.get(".scenarios").contains("1")
  })
})
