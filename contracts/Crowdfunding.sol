// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
        bool ended;
    }

    mapping(uint => Campaign) public campaigns;
    uint public campaignCount;

    event CampaignCreated(uint campaignId, string title, address benefactor, uint goal, uint deadline);
    event DonationReceived(uint campaignId, address donor, uint amount);
    event CampaignEnded(uint campaignId, uint amountRaised, address benefactor);

    // Create a new crowdfunding campaign
    function createCampaign(string memory _title, string memory _description, address payable _benefactor, uint _goal, uint _durationInSeconds) public {
        require(_goal > 0, "Goal must be greater than zero");

        uint deadline = block.timestamp + _durationInSeconds;
        campaignCount++;

        campaigns[campaignCount] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: deadline,
            amountRaised: 0,
            ended: false
        });

        emit CampaignCreated(campaignCount, _title, _benefactor, _goal, deadline);
    }

    // Donate to a specific campaign
    function donateToCampaign(uint _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(!campaign.ended, "Campaign has already ended");

        campaign.amountRaised += msg.value;

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    // End a specific campaign and transfer the funds to the benefactor
    function endCampaign(uint _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign deadline has not yet passed");
        require(!campaign.ended, "Campaign has already ended");

        campaign.ended = true;
        campaign.benefactor.transfer(campaign.amountRaised);

        emit CampaignEnded(_campaignId, campaign.amountRaised, campaign.benefactor);
    }
}
