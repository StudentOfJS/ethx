const fixedSupplyToken = artifacts.require("./FixedSupplyToken.sol")
const exchange = artifacts.require("./Exchange.sol")

let myTokenInstance;
let myExchangeInstance;

beforeEach = async () => {
  myTokenInstance = await fixedSupplyToken.deployed()
  myExchangeInstance = await exchange.deployed()
}

contract('Exchange Basic Tests', accounts => {
  it("should be possible to add tokens", async () => {
    const txResult = await myExchangeInstance.addToken("FIXED", myTokenInstance.address)
    assert.equal(txResult.logs[0].event, "TokenAddedToSystem", "TokenAddedtoSystem Event should be emitted")
    const booleanHasToken = await myExchangeInstance.hasToken.call("FIXED")
    assert.equal(booleanHasToken, true, "The Token was not added")
    const booleanHasNotToken = await myExchangeInstance.hasToken.call("SOMETHING")
    assert.equal(booleanHasNotToken, false, "A Token that doesn't exist was found.")
  })

  //TRUFFLE ROUNDS GAS


  it("should be possible to Deposit and Withdraw Ether", async () => {
    const balanceBeforeTransaction = web3.eth.getBalance(accounts[0])
    const txHash = await myExchangeInstance.depositEther({ from: accounts[0], value: web3.toWei(1, "ether") })
    let gasUsed = await txHash.receipt.cumulativeGasUsed * web3.eth.getTransaction(txHash.receipt.transactionHash).gasPrice.toNumber()
    const balanceAfterDeposit = await web3.eth.getBalance(accounts[0])
    const balanceInWei = await myExchangeInstance.getEthBalanceInWei.call()
    assert.equal(balanceInWei.toNumber(), web3.toWei(1, "ether"), "There is one ether available")
    assert.isAtLeast(balanceBeforeTransaction.toNumber() - balanceAfterDeposit.toNumber(), web3.toWei(1, "ether"), "Balances of account are the same")
    const txHash2 = await myExchangeInstance.withdrawEther(web3.toWei(1, "ether"))
    const balanceAfterWithdrawal = await web3.eth.getBalance(accounts[0])
    const balanceInWei2 = await myExchangeInstance.getEthBalanceInWei.call()
    assert.equal(balanceInWei2.toNumber(), 0, "There is no ether available anymore")
    assert.isAtLeast(balanceAfterWithdrawal.toNumber(), balanceBeforeTransaction.toNumber() - gasUsed * 2, "There is one ether available")
  })


  it("should be possible to Deposit Token", async () => {
    await myTokenInstance.approve(myExchangeInstance.address, 2000)
    await myExchangeInstance.depositToken("FIXED", 2000)
    const tokenBalance = await myExchangeInstance.getBalance("FIXED")
    assert.equal(tokenBalance, 2000, "There should be 2000 tokens for the address")
  })

  it("should be possible to Withdraw Token", async () => {
    const balancedTokenInExchangeBeforeWithdrawal = await myExchangeInstance.getBalance.call("FIXED").toNumber()
    const balanceTokenInTokenBeforeWithdrawal = await myTokenInstance.balanceOf.call(accounts[0]).toNumber()
    await myExchangeInstance.withdrawToken("FIXED", balancedTokenInExchangeBeforeWithdrawal)
    const balanceTokenInExchangeAfterWithdrawal = await myExchangeInstance.getBalance.call("FIXED").toNumber()
    const balanceTokenInTokenAfterWithdrawal = await myTokenInstance.balanceOf.call(accounts[0]).toNumber()
    assert.equal(balanceTokenInExchangeAfterWithdrawal, 0, "There should be 0 tokens left in the exchange")
    assert.equal(balanceTokenInTokenAfterWithdrawal, balancedTokenInExchangeBeforeWithdrawal + balanceTokenInTokenBeforeWithdrawal, "There should be 0 tokens left in the exchange")
  })

})