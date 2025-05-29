// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title CrowdFund
 * @dev A simple crowdfunding contract where contributors can send ETH,
 * and the owner can withdraw if the goal is reached by the deadline.
 * If the goal is not reached, contributors can request refunds.
 */
contract CrowdFund {
    // State variables
    address public owner;
    uint256 public goal;
    uint256 public deadline;
    uint256 public totalRaised;
    uint256 public contributorCount;
    bool public goalReached;
    bool public fundsClaimed;
    
    // Mapping to track contributions by address
    mapping(address => uint256) public contributions;
    
    // Events as required in the assignment
    event FundReceived(address contributor, uint256 amount);
    event GoalReached(uint256 totalAmount);
    event Refunded(address contributor, uint256 amount);
    
    // Minimum contribution amount in wei (0.01 ETH)
    uint256 public constant MIN_CONTRIBUTION = 0.01 ether;
    
    /**
     * @dev Modifier to restrict function access to the contract owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    /**
     * @dev Modifier to check if the deadline has passed
     */
    modifier deadlinePassed() {
        require(block.timestamp > deadline, "Deadline has not passed yet");
        _;
    }
    
    /**
     * @dev Modifier to check if the deadline is still active
     */
    modifier deadlineActive() {
        require(block.timestamp <= deadline, "Deadline has passed");
        _;
    }
    
    /**
     * @dev Constructor to initialize the crowdfunding campaign
     * @param _goal Funding goal in wei
     * @param _durationInDays Duration of the campaign in days
     */
    constructor(uint256 _goal, uint256 _durationInDays) {
        require(_goal > 0, "Goal must be greater than 0");
        require(_durationInDays > 0, "Duration must be greater than 0");
        
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
        totalRaised = 0;
        contributorCount = 0;
        goalReached = false;
        fundsClaimed = false;
    }
    
    /**
     * @dev Function to contribute funds to the campaign
     */
    function contribute() public payable deadlineActive {
        require(msg.value >= MIN_CONTRIBUTION, "Contribution must be at least 0.01 ETH");
        
        // If this is the contributor's first contribution, increment count
        if (contributions[msg.sender] == 0) {
            contributorCount++;
        }
        
        // Update contribution record and total raised
        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
        
        // Check if the goal has been reached
        if (totalRaised >= goal && !goalReached) {
            goalReached = true;
            emit GoalReached(totalRaised);
        }
        
        // Emit event for the contribution
        emit FundReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev Function to check the current balance of the contract
     * @return The current contract balance in wei
     */
    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Function for the owner to withdraw funds if the goal is reached
     */
    function withdraw() public onlyOwner {
        require(goalReached, "Funding goal has not been reached");
        require(!fundsClaimed, "Funds have already been claimed");
        require(address(this).balance > 0, "No funds to withdraw");
        
        fundsClaimed = true;
        
        // Transfer all funds to the owner
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
    /**
     * @dev Function for contributors to request a refund if the goal is not met
     */
    function refund() public deadlinePassed {
        require(!goalReached, "Goal was reached, refunds not available");
        require(contributions[msg.sender] > 0, "No contributions to refund");
        
        uint256 refundAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        
        // Transfer the refund amount to the contributor
        (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
        require(success, "Refund transfer failed");
        
        emit Refunded(msg.sender, refundAmount);
    }
    
    /**
     * @dev Function to get details about the crowdfunding campaign
     * @return _goal The funding goal in wei
     * @return _deadline The campaign deadline as a Unix timestamp
     * @return _totalRaised The total amount raised in wei
     * @return _contributorCount The number of unique contributors
     * @return _goalReached Whether the goal has been reached
     * @return _fundsClaimed Whether the funds have been claimed by the owner
     */
    function getDetails() public view returns (
        uint256 _goal,
        uint256 _deadline,
        uint256 _totalRaised,
        uint256 _contributorCount,
        bool _goalReached,
        bool _fundsClaimed
    ) {
        return (
            goal,
            deadline,
            totalRaised,
            contributorCount,
            goalReached,
            fundsClaimed
        );
    }
    
    /**
     * @dev Function to check time remaining until deadline
     * @return Seconds remaining until the deadline, or 0 if deadline has passed
     */
    function timeRemaining() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }
    
    /**
     * @dev Function to check the contribution amount of a specific address
     * @param _contributor Address of the contributor
     * @return Contribution amount in wei
     */
    function getContribution(address _contributor) public view returns (uint256) {
        return contributions[_contributor];
    }
    
    /**
     * @dev Fallback function to handle direct sends to the contract
     */
    receive() external payable {
        contribute();
    }
}
