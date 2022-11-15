const Web3 = require('web3');
const conf = require('./build/contracts/HashedTimelock.json');
const Contract_address = conf.networks['80001'].address;
const Contract_ABI = conf.abi;
const web3 = new Web3(
  new Web3.providers.HttpProvider(
    'https://polygon-mumbai.g.alchemy.com/v2/T--bLJdkZ9zbQXmPjYUpwSTVC9V75jGz'
  )
);
const contract = new web3.eth.Contract(Contract_ABI, Contract_address);
const address = '0xFce453aA73177E63f24530ea106ee75d478a5cb1';
const pk = '61f84609b0c5c7cf36f01eb84af270c109bfcdd790db99af5fc4bec2315bc313';
async function newContract(){

    const nonce = await web3.eth.getTransactionCount(address);
    const gasprice = await web3.eth.getGasPrice();
    const orderhash2 = await contract.methods
      .newContract(
        '0x864C42Cce5180b7f48CeaA36672Ea698A8334248',
        '0x136e60187bf24defea230aaf47a6a0808c0ea67ce37d2e5f4f09f84b71a222cf',
        '1668664153'
      )
      .encodeABI();
    const tx= {
        from: address,
        to: Contract_address,
        gas: 1000000,                             // contract id 0xdf5f90e73986bf7e8d13e48e2670aab574a977e7b09804d301641a2531187381 string "rj"
        gasPrice:gasprice,                          // hash keccak256 0x136e60187bf24defea230aaf47a6a0808c0ea67ce37d2e5f4f09f84b71a222cf
        data:orderhash2,
        nonce,
        value : web3.utils.toWei('0.1', 'ether')
      }
      const signature = await web3.eth.accounts.signTransaction(tx,pk);
      const recepit = await web3.eth.sendSignedTransaction(signature.rawTransaction);
      console.log(recepit);
}

async function getEvents(){
let a = await contract.getPastEvents('LogHTLCNew', {
  fromBlock: 29163139,
  toBlock: '29163139',
  filter: { from: address },
});
console.log(a);
}

async function getContract(){
  const orderhash2 = await contract.methods.getContract("0x1b57f06386a9231c29b0677d570757ac0d8dd6a64656b240087cd197932afe45").call({from : address , gas : 100000})
  console.log(orderhash2);
}
// newContract();
getEvents();
// console.log(Contract_address)







