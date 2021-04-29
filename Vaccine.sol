pragma solidity ^0.4.24;


contract SupplyChain{
    
    //Declaration
    
    address Owner;
    
    struct Vaccine{
        
        bool isUidGenerated;
        uint itemId;
        string itemName;
        
        string transitStatus;
        uint orderStatus; //1=manufactured, 2=delivered, 3=vaccinated
        
        address moderator;
        uint creationTime;
        
        address distributor;
        uint distributorTime;
        
        address hospital;
        uint hospitalTime;
        
        address patient;
        uint patientTime;
    }
    
    mapping (address => Vaccine) public vaccineMapping;
    
    mapping (address => bool) public actors;
    
    //Modifiers
    constructor() public {
        Owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(Owner == msg.sender);
        _;
    }
    
    
    //Order Item function
    function manufactureVaccine(uint _itemId, string _itemName) public returns (address) {
        
        //This function only accepts a single "bytes" argument.
        //Please use "abi.encodePacked(...)" or a similar function to encode the data.
        //address uniqueId = address(sha256(abi.encodePacked(msg.sender, now)));
        
        address uniqueId = address(sha256(abi.encodePacked(msg.sender, now)));
        vaccineMapping[uniqueId].isUidGenerated = true;
        vaccineMapping[uniqueId].itemId = _itemId;
        vaccineMapping[uniqueId].itemName = _itemName;
        vaccineMapping[uniqueId].transitStatus = "Vaccine is manufactured";
        vaccineMapping[uniqueId].orderStatus = 0;
        vaccineMapping[uniqueId].moderator = msg.sender;
        vaccineMapping[uniqueId].creationTime = now;
        
        return uniqueId;
    }
    
    //Manage Actors, only owner can execute it
    function manageActors(address _actorAddress) public onlyOwner returns (string) {
        //If not authorized, authorize it
        if(!actors[_actorAddress]){
            actors[_actorAddress] = true;
        }
        //else revoke it
        else{
            actors[_actorAddress] = false;
        }
        return "Actor Updated!";
    }
    
    //actor reports
    function distributorReport(address _uniqueId) public {
        require(vaccineMapping[_uniqueId].isUidGenerated);
        require(actors[msg.sender]);
        require(vaccineMapping[_uniqueId].orderStatus == 0);
        
        vaccineMapping[_uniqueId].transitStatus = "distributor has collected the vaccine";
        vaccineMapping[_uniqueId].distributor = msg.sender;
        vaccineMapping[_uniqueId].distributorTime = now;
        vaccineMapping[_uniqueId].orderStatus = 1;
    }
    function hospitalReport(address _uniqueId) public {
        require(vaccineMapping[_uniqueId].isUidGenerated);
        require(actors[msg.sender]);
        require(vaccineMapping[_uniqueId].orderStatus == 1);
        
        vaccineMapping[_uniqueId].transitStatus = "vaccine delivered to hospital";
        vaccineMapping[_uniqueId].hospital = msg.sender;
        vaccineMapping[_uniqueId].hospitalTime = now;
        vaccineMapping[_uniqueId].orderStatus = 2;
    }
    function patientReport(address _uniqueId) public {
        require(vaccineMapping[_uniqueId].isUidGenerated);
        require(actors[msg.sender]);
        require(vaccineMapping[_uniqueId].orderStatus == 2);
        
        vaccineMapping[_uniqueId].transitStatus = "patient has been vaccinated";
        vaccineMapping[_uniqueId].patient = msg.sender;
        vaccineMapping[_uniqueId].patientTime = now;
        vaccineMapping[_uniqueId].orderStatus = 3;
    }
    
}
