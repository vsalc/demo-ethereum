// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract PayChain {

    // admin (me)
    address payable admin;

    // users
    uint256 public total_users;
    mapping(address => bool) users;
    mapping(address => Account) accounts;  

    // contract settings (admin can manage)
    uint256 public registration_fee = 0.0025 ether;  
    uint256 public minimum_deposit = 0.0025 ether;  
    uint256 public minimum_withdraw = 0.0025 ether;  

    uint256 public maximum_deposit = 999999999 ether;  
    uint256 public maximum_withdraw = 999999999 ether;  

    uint256 public maximum_requests = 50;
    uint256 public maximum_contacts = 50;

    // structs
    struct Account {
        uint256 active_wallet;
        uint256 cold_wallet;
        uint256 total_transactions;
        Request[] open_requests;
        Contact[] contact_list;
    }

    struct Request {
        address recipient;
        uint256 amount;
    }

    struct Contact {
        string first_name;
        string last_name;
        string about;
        address contact_address;
    }

    // modifiers
    modifier isAdmin {
        require(msg.sender == admin, "ERR: This action can only be completed by the contract administrator.");
        _;
    }

    modifier isUser {
        require(users[msg.sender], "ERR: This action can only be completed by a registered user.");
        _;
    }

    modifier feePaid {
        require(msg.value == registration_fee, "ERR: The value of the transaction must be equal to the registration fee.");
        _;
    }

    modifier validDeposit {
        require(msg.value >= minimum_deposit, "ERR: The value of the transaction must be greater than or equal to the minimum deposit.");
        require(msg.value <= maximum_deposit, "ERR: The value of the transaction must be less than or equal to the maximum deposit.");
        _;
    }

    modifier validWithdraw(uint256 withdraw_amount) {
        require(withdraw_amount >= minimum_withdraw, "ERR: The amount of the transaction must be greater than or equal to the minimum withdraw.");
        require(withdraw_amount <= maximum_withdraw, "ERR: The amount of the transaction must be less than or equal to the maximum withdraw.");
        _;
    }

    // constructor 
    constructor() {
        admin = payable(msg.sender);
    }

    // admin functions
    function updateRegistrationFee(uint256 new_registration_fee) public isAdmin {
        require(new_registration_fee >= 0, "ERR: Fee cannot be less than zero.");
        registration_fee = new_registration_fee;
    }

    function updateMinimumDeposit(uint256 new_minimum_deposit) public isAdmin {
        require(new_minimum_deposit >= 1, "ERR: Minimum deposit cannot be less than one.");
        require(new_minimum_deposit <= maximum_deposit, "ERR: Minimum deposit cannot be greater than the maximum deposit.");
        minimum_deposit = new_minimum_deposit;
    }

    function updateMinimumWithdraw(uint256 new_minimum_withdraw) public isAdmin {
        require(new_minimum_withdraw >= 1, "ERR: Minimum withdraw cannot be less than one.");
        require(new_minimum_withdraw <= maximum_withdraw, "ERR: Minimum withdraw cannot be greater than the maximum withdraw.");
        minimum_withdraw = new_minimum_withdraw;
    }

    function updateMaximumDeposit(uint256 new_maximum_deposit) public isAdmin {
        require(new_maximum_deposit >= 1, "ERR: Maximum deposit cannot be less than one.");
        require(new_maximum_deposit >= minimum_deposit, "ERR: Maximum deposit cannot be less than the minimum deposit.");
        maximum_deposit = new_maximum_deposit;
    }

    function updateMaximumWithdraw(uint256 new_maximum_withdraw) public isAdmin {
        require(new_maximum_withdraw >= 1, "ERR: Maximum withdraw cannot be less than one.");
        require(new_maximum_withdraw >= minimum_withdraw, "ERR: Maximum withdraw cannot be less than the minimum withdraw.");
        maximum_withdraw = new_maximum_withdraw;
    }  

    function updateMaximumRequests(uint256 new_maximum_requests) public isAdmin {
        require(new_maximum_requests >= 0, "ERR: Maximum requests cannot be less than zero.");
        maximum_requests = new_maximum_requests;
    }

    function updateMaximumContacts(uint256 new_maximum_contacts) public isAdmin {
        require(new_maximum_contacts >= 0, "ERR: Maximum contacts cannot be less than zero.");
        maximum_contacts = new_maximum_contacts;
    }

    // non-user functions
    function register() public payable feePaid {
        require(!users[msg.sender], "ERR: The address used has already been registered with PayChain.");

        Account storage account_setup = accounts[msg.sender];
        account_setup.total_transactions = 1;
        users[msg.sender] = true;
        total_users++;
    }

    // user functions 
    function deposit(bool wallet) public payable isUser validDeposit {
        Account storage current = accounts[msg.sender];
        
        if (wallet) {
            current.active_wallet += msg.value;
        } else {
            current.cold_wallet += msg.value;
        }

        current.total_transactions++;
    }

    function withdraw(bool wallet, uint256 withdraw_amount) public isUser validWithdraw(withdraw_amount) {
        Account storage current = accounts[msg.sender];

        if (wallet) {
            require(current.active_wallet >= withdraw_amount, "ERR: Not enough funds in this wallet to complete the withdraw.");
            current.active_wallet -= withdraw_amount;
        } else {
            require(current.cold_wallet >= withdraw_amount, "ERR: Not enough funds in this wallet to complete the withdraw.");
            current.cold_wallet -= withdraw_amount;
        }

        payable(msg.sender).transfer(withdraw_amount);
        current.total_transactions++;
    }

    function send(bool wallet, uint256 amount, address to) public isUser {
        require(users[to], "ERR: The address you are trying to send ETH to is not a registered user.");
        Account storage sender = accounts[msg.sender];
        Account storage receiver = accounts[to];

        if (wallet) {
            require(sender.active_wallet >= amount, "ERR: Not enough funds in this wallet to complete this transaction.");
            sender.active_wallet -= amount;
        } else {
            require(sender.cold_wallet >= amount, "ERR: Not enough funds in this wallet to complete this transaction.");
            sender.cold_wallet -= amount;
        }

        receiver.active_wallet += amount;

        sender.total_transactions++;
        receiver.total_transactions++;
    }

    function transferBetweenWallets(bool wallet, uint256 amount) public isUser {
        Account storage current = accounts[msg.sender];

        if (wallet) {
            require(current.active_wallet >= amount, "ERR: Not enough funds in this wallet to complete the transfer.");
            current.active_wallet -= amount;
            current.cold_wallet += amount;
        } else {
            require(current.cold_wallet >= amount, "ERR: Not enough funds in this wallet to complete the transfer.") ;
            current.cold_wallet -= amount;
            current.active_wallet += amount;
        }

        current.total_transactions++;
    }

    function createContact(string memory first_name, string memory last_name, string memory about, address contact_address) public isUser {
        require(users[contact_address], "ERR: The address must be a registered user to be added as a contact.");

        Account storage current = accounts[msg.sender];
        require(current.contact_list.length < maximum_contacts, "ERR: You have reached the maximum number of contacts possible.");

        current.contact_list.push(Contact(first_name, last_name, about, contact_address));
    }

    function deleteContact(uint256 contact_index) public isUser {
        Contact[] storage current = accounts[msg.sender].contact_list;
        require(contact_index >= 0 && contact_index < current.length, "ERR: Invalid contact index provided.");

        current[contact_index] = current[current.length - 1];
        current.pop();
    }

    function createRequest(address from, uint256 amount) public isUser {
        require(users[from], "ERR: This address is not a registered user of PayChain.");
        Request[] storage current = accounts[from].open_requests; 

        current.push(Request(msg.sender, amount));
    }

    function completeRequest(bool wallet, uint256 request_index) public isUser {
        Account storage current = accounts[msg.sender];
        require(request_index >= 0 && request_index < current.open_requests.length, "ERR: Invalid request index.");
        Request storage request = current.open_requests[request_index];

        if (wallet) {
            require(current.active_wallet >= request.amount, "ERR: Not enough funds in this wallter to complete the request.");
            current.active_wallet -= request.amount;
        } else {
            require(current.cold_wallet >= request.amount, "ERR: Not enough funds in this wallet to complete the request.");
            current.cold_wallet -= request.amount;
        }

        Account storage receiver = accounts[request.recipient];
        receiver.active_wallet += request.amount;

        // delete request
        current.open_requests[request_index] = current.open_requests[current.open_requests.length - 1];
        current.open_requests.pop();

        current.total_transactions++;
        receiver.total_transactions++;
    }

    function deactivateAccount() public isUser {
        Account storage current = accounts[msg.sender];
        payable(msg.sender).transfer(current.active_wallet + current.cold_wallet);
        users[msg.sender] = false;
        total_users--;
    }
}