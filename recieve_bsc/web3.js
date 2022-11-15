const Web3 = require('web3');
const conf = require('./build/contracts/HashedTimelock.json');
const Contract_address = conf.networks['97'].address;
const Contract_ABI = conf.abi;
const web3 = new Web3(new Web3.providers.HttpProvider("https://data-seed-prebsc-2-s1.binance.org:8545/"));
const contract = new web3.eth.Contract(Contract_ABI, Contract_address);
const address = '0xFce453aA73177E63f24530ea106ee75d478a5cb1';
const pk = '61f84609b0c5c7cf36f01eb84af270c109bfcdd790db99af5fc4bec2315bc313';

async function getEvents(){
let a = await contract.getPastEvents('LogHTLCNew',{fromBlock:0,toBlock:'latest',filter:{from:address}})
console.log(a);
}

async function getContract(){
  const orderhash2 = await contract.methods.getContract("0x1b57f06386a9231c29b0677d570757ac0d8dd6a64656b240087cd197932afe45").call({from : address , gas : 100000})
  console.log(orderhash2);
}

async function withdrawal() {
  const nonce = await web3.eth.getTransactionCount(address);
  const gasprice = await web3.eth.getGasPrice();
  const orderhash2 = await contract.methods
    .withdraw(
      '0xdf5591130eb3f1e1f169115df0dba7e13690ea6eb87e37ada3cc8ee3d5149d6e',
      'rj'
    )
    .encodeABI();
  
  const tx = {
    from:address,
    to: Contract_address,
    gas: 1000000,
    gasPrice: gasprice,
    data: orderhash2,
    nonce,
  };

  const signature = await web3.eth.accounts.signTransaction(tx,pk);
  const recepit = await web3.eth.sendSignedTransaction(signature.rawTransaction);
  console.log("Signed Transaction ",recepit );
}


// getEvents();
// getContract();
withdrawal();
// console.log(Contract_address);




