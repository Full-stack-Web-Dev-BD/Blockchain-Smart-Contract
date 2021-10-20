//SPDX-License-Identifier : MIT 

pragma  solidity ^0.8.0;


contract Lottery {
    
     address public manager ;
     address payable  []  public contributors ;
     uint lotteryPrice=1 ether;
     
     constructor(){
        manager= msg.sender;    
     }
     function getContractBalance () public view returns(uint ){
         return address(this).balance;
     }
     function sellLottery() public payable {
         require( msg.value == lotteryPrice);
         contributors.push(payable(msg.sender));
     }
     
     function getRandom () private view  returns( uint) {
         return uint (keccak256(abi.encodePacked(block.difficulty, block.timestamp, contributors.length)));
     }
     
     function selectWinner () public {
         require(contributors.length>=3,"Not  enough perticipent ");
         require(msg.sender==manager);
         uint random= getRandom();
         uint selectedWinnerIndex = random% contributors.length;
         address  payable selectedWinnerAccountAddress=   contributors[selectedWinnerIndex];
         selectedWinnerAccountAddress.transfer(getContractBalance());
         contributors= new address payable  [] (0);
     }
}