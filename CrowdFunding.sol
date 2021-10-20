//SPDX-License-Identifier : UNLICENSED
pragma solidity ^0.8.0;
contract CrowdFunding {
    //        address-->Doneted amount 
    mapping  (address=>uint) public contributors;
    address public manager ; 
    uint public minimumContribution;
    uint public deadline ;
    uint public raisedAmount ;
    uint public noOfContributors;
    uint public target ;
    
    //Struct for request,  it will use to     to get  the  collected amount by  manager .
    struct Request {
        string description ;
        address payable  receipientAccountAddress ;
        uint  value ;
        bool completed ;
        uint noOfVoters;
        mapping ( address => bool) voters ;
    }
    mapping ( uint =>Request) public allRequest ;
    uint public numberOfRequest=0 ;

    constructor(uint _target, uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumContribution=100 wei;
        manager= msg.sender;
    }
    //contributors will send   amount  by this function ;
    function sendEth ()public payable{
        require(block.timestamp <deadline, " Deadline has passed !!");
        require(msg.value>= minimumContribution , "Minimum Contribution is not meet !!");
        if(contributors[msg.sender]==0){
            noOfContributors++; // increase contributor
        }
        raisedAmount+=msg.value; //increase total raised amount
        contributors[msg.sender]+=msg.value; //increse the amount  of donner  total given amount;
    }
    function getContractBalance  () public view returns(uint)  {
        return address(this).balance;
    }

    function getRefound () public {
        require(target>=raisedAmount,"Contract successfully  made , can't refound amount !! ");
        require(block.timestamp>deadline,"Time expire , Not  able to refound !!");
        require(contributors[msg.sender]>0,"You have  not enough amount  to refound !!");
        address payable user= payable (msg.sender); //making user as payable  to  refound
        user.transfer(contributors[msg.sender]); 
        contributors[msg.sender]=0;
    }
    modifier onlyManager (){
        require(msg.sender== manager, "Only Manager can get  the founds !!");
        _;
    }
    function createRequest (string memory  _descriptoin , address payable _accountAddress , uint _amount ) public  onlyManager{
         Request  storage newRequest = allRequest[numberOfRequest];
         numberOfRequest++;
         newRequest.description=_descriptoin;
         newRequest.receipientAccountAddress=  _accountAddress;
         newRequest.completed=false ;
         newRequest.noOfVoters=0;
         newRequest.value=_amount;
    }
    
    function voteRequest (uint  _requestNo) public  {
        require(contributors[msg.sender]>0, "You must need to contribute first  to make vote");
        Request storage thisRequest= allRequest[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You alred voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }
    function makePayment (uint _requestNo) public onlyManager {
        require(raisedAmount>=target);
        Request storage thisRequest= allRequest[_requestNo];
        require(thisRequest.completed==false,"The request allready rosolved");
        require ( thisRequest.noOfVoters> noOfContributors/2, "Majority Does't Support This !!");
        thisRequest.receipientAccountAddress.transfer(thisRequest.value);
        thisRequest.completed=true;
    }
    
    
    
}