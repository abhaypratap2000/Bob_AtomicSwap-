// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
contract HashedTimelock {

    event LogHTLCNew(
        bytes32 indexed contractId,
        address indexed sender,
        address indexed receiver,
        uint amount,
        bytes32 hashlock,
        uint timelock
    );
    event LogHTLCWithdraw(bytes32 indexed contractId);
    event LogHTLCRefund(bytes32 indexed contractId);

    struct LockContract {
        address payable sender;
        address payable receiver;
        uint amount;
        bytes32 hashlock;
        uint timelock; 
        bool withdrawn;
        bool refunded;
        string preimage;
    }
    modifier fundsSent() {
        require(msg.value > 0, "msg.value must be > 0");
        _;
    }
    modifier futureTimelock(uint _time) {
        require(_time > block.timestamp, "timelock time must be in the future");
        _;
    }
    modifier contractExists(bytes32 _contractId) {
        require(haveContract(_contractId), "contractId does not exist");
        _;
    }
    modifier hashlockMatches(bytes32 _contractId, string memory _x) {
        bytes32 b = keccak256(abi.encodePacked(_x));
        require(
            contracts[_contractId].hashlock == b,
            "hashlock hash does not match"
        );
        _;
    }
    modifier withdrawable(bytes32 _contractId) {
        require(contracts[_contractId].receiver == msg.sender, "withdrawable: not receiver");
        require(contracts[_contractId].withdrawn == false, "withdrawable: already withdrawn");
        require(contracts[_contractId].timelock > block.timestamp, "withdrawable: timelock time must be in the future");
        _;
    }
    modifier refundable(bytes32 _contractId) {
        require(contracts[_contractId].sender == msg.sender, "refundable: not sender");
        require(contracts[_contractId].refunded == false, "refundable: already refunded");
        require(contracts[_contractId].withdrawn == false, "refundable: already withdrawn");
        require(contracts[_contractId].timelock <= block.timestamp, "refundable: timelock not yet passed");
        _;
    }
    mapping (bytes32 => LockContract) contracts;
    function newContract(address payable _receiver, bytes32 _hashlock, uint _timelock)
        external
        payable
        fundsSent
        futureTimelock(_timelock)
        returns (bytes32 contractId)
    {
        contractId = sha256(
            abi.encodePacked(
                msg.sender,
                _receiver,
                msg.value,
                _hashlock,
                _timelock
            )
        );
        if (haveContract(contractId))
            revert("Contract already exists");

        contracts[contractId] = LockContract(
            payable(msg.sender),
            _receiver,
            msg.value,
            _hashlock,
            _timelock,
            false,
            false,
            ""
        );

        emit LogHTLCNew(
            contractId,
            msg.sender,
            _receiver,
            msg.value,
            _hashlock,
            _timelock
        );
    }
 function balance() public view returns(uint){
     return address(this).balance;
 }
    
    function withdraw(bytes32 _contractId, string memory _preimage)
        external
        contractExists(_contractId)
        hashlockMatches(_contractId, _preimage)
        withdrawable(_contractId)
        returns (bool)
    {
        LockContract storage c = contracts[_contractId];
        c.preimage = _preimage;
        c.withdrawn = true;
        c.receiver.transfer(c.amount);
        c.amount = 0 ;
        emit LogHTLCWithdraw(_contractId);
        return true;
    }
    function refund(bytes32 _contractId)
        external
        contractExists(_contractId)
        refundable(_contractId)
        returns (bool)
    {
        LockContract storage c = contracts[_contractId];
        c.refunded = true;
        c.sender.transfer(c.amount);
        emit LogHTLCRefund(_contractId);
        return true;
    }
    function getContract(bytes32 _contractId)
        public
        view
        returns (
            address sender,
            address receiver,
            uint amount,
            bytes32 hashlock,
            uint timelock,
            bool withdrawn,
            bool refunded,
            string memory preimage
        )
    {
        if (haveContract(_contractId) == false)
            return (address(0), address(0), 0, 0, 0, false, false, "");
        LockContract storage c = contracts[_contractId];
        return (
            c.sender,
            c.receiver,
            c.amount,
            c.hashlock,
            c.timelock,
            c.withdrawn,
            c.refunded,
            c.preimage
        );
    }
    function haveContract(bytes32 _contractId)
        internal
        view
        returns (bool exists)
    {
        exists = (contracts[_contractId].sender != address(0));
    }

}