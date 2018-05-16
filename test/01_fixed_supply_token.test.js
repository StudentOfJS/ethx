const FixedSupplyToken = artifacts.require("FixedSupplyToken")

let myTokenInstance;
let _totalSupply;

before(async () => {
  myTokenInstance = await FixedSupplyToken.deployed()
  _totalSupply = await myTokenInstance.totalSupply.call()
})
contract('my token', async (accounts) => {

  it('has a first account that owns all tokens', async () => {
    const balanceAccountOwner = await myTokenInstance.balanceOf(accounts[0])
    assert.equal(balanceAccountOwner.toNumber(), _totalSupply.toNumber(), "Total amount of tokens is owned by owner")
  })

  it('the second account should not own any tokens', async () => {
    const secondaryAccount = await myTokenInstance.balanceOf(accounts[1])
    assert.equal(secondaryAccount.toNumber(), 0, "Total amount of tokens is owned by owner")
  })

  it('should be possible to send tokens between accounts', async () => {
    const secondaryAccountWithoutTokens = await myTokenInstance.balanceOf(accounts[1])
    myTokenInstance.transfer(accounts[1], 100)
    const seondaryAccountWithTokens = await myTokenInstance.balanceOf(accounts[1])
    assert.equal(seondaryAccountWithTokens.toNumber(), (secondaryAccountWithoutTokens.toNumber() + 100))
  })

})